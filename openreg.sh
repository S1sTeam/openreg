#!/bin/bash

# ── Colors ──
R="\e[31m"; G="\e[32m"; Y="\e[33m"; B="\e[34m"; C="\e[36m"; M="\e[35m"; W="\e[97m"; N="\e[0m"
BOLD="\e[1m"; DIM="\e[2m"; ERR="\e[41m\e[97m"; OK="\e[42m\e[97m"; INFO="\e[44m\e[97m"; WARN="\e[43m\e[97m"
CHECK="${G}✓${N}"; CROSS="${R}✗${N}"

OPENCODE_BIN="$HOME/.opencode/bin/opencode"
AUTO_FILE="/tmp/.openreg_auto"

log()  { echo -e " ${INFO} ${N} ${BOLD}$1${N}"; }
ok()   { echo -e "  ${CHECK} ${G}$1${N}"; }
fail() { echo -e "  ${CROSS} ${R}$1${N}"; }
warn() { echo -e " ${WARN} ${N} ${Y}$1${N}"; }
sep()  { echo -e " ${DIM}────────────────────────────────────────${N}"; }

# ── Install WARP ──
install_warp() {
  log "Установка Cloudflare WARP..."
  if command -v warp-cli &>/dev/null; then
    ok "WARP уже установлен"
    return
  fi
  local ARCH=$(dpkg --print-architecture)
  local WARP_DEB="/tmp/warp.deb"
  local WARP_URL="https://pkg.cloudflareclient.com/packages/cloudflare-warp"
  case "$ARCH" in
    amd64) WARP_URL+="_${ARCH}.deb" ;;
    arm64) WARP_URL+="_${ARCH}.deb" ;;
    *) fail "Архитектура $ARCH не поддерживается"; return 1 ;;
  esac
  echo -e "  ${DIM}Загрузка WARP для ${ARCH}...${N}"
  if curl -sL "$WARP_URL" -o "$WARP_DEB"; then
    dpkg -i "$WARP_DEB" &>/dev/null || apt-get install -f -y &>/dev/null
    ok "WARP установлен"
    rm -f "$WARP_DEB"
  else
    warn "Не удалось загрузить WARP. Установи вручную: https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/download-warp/"
    return 1
  fi
}

# ── Setup proxychains ──
setup_proxychains() {
  log "Настройка proxychains..."
  local PC_CONF="/etc/proxychains4.conf"
  if [ ! -f "$PC_CONF" ]; then
    apt-get install -y proxychains4 &>/dev/null
  fi
  if ! grep -q "socks5.*127.0.0.1.*40000" "$PC_CONF" 2>/dev/null; then
    cat > "$PC_CONF" << 'PCEOF'
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5 127.0.0.1 40000
PCEOF
  fi
  ok "proxychains настроен (socks5 127.0.0.1:40000)"
}

# ── Init WARP ──
init_warp() {
  log "Инициализация WARP..."
  if ! warp-cli status &>/dev/null; then
    warp-cli registration new &>/dev/null && ok "Регистрация WARP" || fail "Ошибка регистрации WARP"
  else
    ok "WARP уже зарегистрирован"
  fi
  local MODE=$(warp-cli settings 2>/dev/null | grep "Mode:" | awk '{print $NF}')
  if [ "$MODE" != "WarpProxy" ]; then
    warp-cli mode proxy &>/dev/null && ok "Режим: WarpProxy (порт 40000)"
  fi
  # Exclude localhost from proxy
  warp-cli tunnel ip add-range 127.0.0.0/8 &>/dev/null 2>&1
  warp-cli tunnel ip add-range 10.0.0.0/8 &>/dev/null 2>&1
  warp-cli tunnel ip add-range 172.16.0.0/12 &>/dev/null 2>&1
  warp-cli tunnel ip add-range 192.168.0.0/16 &>/dev/null 2>&1
  ok "Локальные сети исключены из прокси"
}

# ── Connect WARP ──
warp_on() {
  local S=$(warp-cli status 2>/dev/null)
  if echo "$S" | grep -q "Connected"; then
    return 0
  fi
  echo -e "  ${DIM}Подключение WARP...${N}"
  warp-cli connect &>/dev/null
  sleep 2
  if warp-cli status 2>/dev/null | grep -q "Connected"; then
    ok "WARP подключен"
    return 0
  else
    fail "Не удалось подключить WARP"
    return 1
  fi
}

# ── Disconnect WARP ──
warp_off() {
  local S=$(warp-cli status 2>/dev/null)
  if echo "$S" | grep -q "Disconnected"; then
    return 0
  fi
  warp-cli disconnect &>/dev/null
  ok "WARP отключен"
}

# ── Show status ──
show_status() {
  clear
  echo -e " ${BOLD}${W}╔══════════════════════════════════════╗${N}"
  echo -e " ${BOLD}${W}║       ${C}OPENREG${W} — WARP Controller    ║${N}"
  echo -e " ${BOLD}${W}╚══════════════════════════════════════╝${N}"
  echo

  # WARP status
  local WS=$(warp-cli status 2>/dev/null)
  if echo "$WS" | grep -q "Connected"; then
    echo -e "  ${G}●${N} WARP: ${BOLD}${G}Connected${N}"
  else
    echo -e "  ${R}●${N} WARP: ${BOLD}${R}Disconnected${N}"
  fi

  # Mode
  local MODE=$(warp-cli settings 2>/dev/null | grep "Mode:" | sed 's/.*Mode://' | xargs)
  echo -e "  ${DIM}Режим:${N} ${MODE:-unknown}"

  # Proxy check
  if [ -n "$LD_PRELOAD" ] && echo "$LD_PRELOAD" | grep -q "proxychains"; then
    echo -e "  ${G}●${N} proxychains: ${BOLD}${G}активен${N}"
  else
    echo -e "  ${DIM}⊙${N} proxychains: ${BOLD}${DIM}не активен${N}"
  fi

  # Auto mode
  if [ -f "$AUTO_FILE" ]; then
    echo -e "  ${G}●${N} Auto-mode: ${BOLD}${G}ON${N} ${DIM}(opencode → WARP)${N}"
  else
    echo -e "  ${DIM}⊙${N} Auto-mode: ${BOLD}${DIM}OFF${N}"
  fi

  # opencode version
  if [ -x "$OPENCODE_BIN" ]; then
    local VER=$("$OPENCODE_BIN" --version 2>/dev/null)
    echo -e "  ${DIM}opencode:${N} ${VER:-unknown} ${DIM}($OPENCODE_BIN)${N}"
  fi
  echo
}

# ── Wrapper for opencode ──
opencode_wrapper() {
  if [ -f "$AUTO_FILE" ]; then
    if ! warp_on; then
      echo -e " ${WARN} ${Y}Не удалось включить WARP, но продолжаю...${N}"
    fi
  fi
  if [ -n "$LD_PRELOAD" ] && echo "$LD_PRELOAD" | grep -q "proxychains"; then
    exec "$OPENCODE_BIN" "$@"
  else
    exec env LD_PRELOAD="libproxychains.so.3${LD_PRELOAD:+:$LD_PRELOAD}" "$OPENCODE_BIN" "$@"
  fi
}

# ── Main ──
case "${1:-help}" in
  install|setup)
    echo
    install_warp
    setup_proxychains
    init_warp
    echo
    show_status
    ;;
  on|connect)
    warp_on
    ;;
  off|disconnect)
    warp_off
    ;;
  toggle)
    if warp-cli status 2>/dev/null | grep -q "Connected"; then
      warp_off
    else
      warp_on
    fi
    ;;
  auto)
    case "${2:-status}" in
      on|enable|1)
        touch "$AUTO_FILE"
        echo -e " ${OK} ${N} ${G}Auto-mode ВКЛЮЧЕН${N}"
        echo -e " ${DIM}  Все команды opencode будут идти через WARP${N}"
        # Install wrapper
        if ! grep -q "openreg opencode" "$HOME/.bashrc" 2>/dev/null; then
          echo 'opencode() { openreg opencode "$@"; }' >> "$HOME/.bashrc"
          echo 'export -f opencode' >> "$HOME/.bashrc"
          echo -e " ${DIM}  Добавлен wrapper в ~/.bashrc (перезайди в shell)${N}"
        fi
        # Create /usr/local/bin/opencode wrapper
        cat > /usr/local/bin/opencode << 'WEOF'
#!/bin/bash
AUTO_FILE="/tmp/.openreg_auto"
OPENCODE_BIN="$HOME/.opencode/bin/opencode"
if [ -f "$AUTO_FILE" ]; then
  if warp-cli status 2>/dev/null | grep -q "Disconnected"; then
    warp-cli connect &>/dev/null
    sleep 1
  fi
fi
if [ -n "$LD_PRELOAD" ] && echo "$LD_PRELOAD" | grep -q "proxychains"; then
  exec "$OPENCODE_BIN" "$@"
else
  exec env LD_PRELOAD="libproxychains.so.3${LD_PRELOAD:+:$LD_PRELOAD}" "$OPENCODE_BIN" "$@"
fi
WEOF
        chmod +x /usr/local/bin/opencode
        ok "Wrapper установлен: /usr/local/bin/opencode"
        ;;
      off|disable|0)
        rm -f "$AUTO_FILE"
        echo -e " ${WARN} ${Y}Auto-mode ВЫКЛЮЧЕН${N}"
        ;;
      status)
        if [ -f "$AUTO_FILE" ]; then
          echo -e " ${G}●${N} Auto-mode: ${BOLD}${G}ON${N}"
        else
          echo -e " ${DIM}⊙${N} Auto-mode: ${BOLD}${DIM}OFF${N}"
        fi
        ;;
      *)
        echo -e " ${WARN} ${Y}Использование:${N} openreg auto ${G}on${N}|${R}off${N}|${C}status${N}"
        ;;
    esac
    ;;
  opencode)
    shift
    opencode_wrapper "$@"
    ;;
  status|stat)
    show_status
    ;;
  help|--help|-h)
    echo -e " ${BOLD}${C}openreg${N} — управление WARP прокси для opencode${N}"
    echo
    echo -e " ${G}openreg${N}              ${DIM}вкл/выкл WARP${N}"
    echo -e " ${G}openreg on${N}           ${DIM}включить WARP${N}"
    echo -e " ${G}openreg off${N}          ${DIM}выключить WARP${N}"
    echo -e " ${G}openreg status${N}       ${DIM}показать статус${N}"
    echo -e " ${G}openreg auto on${N}      ${DIM}авто-WARP для opencode${N}"
    echo -e " ${G}openreg auto off${N}     ${DIM}отключить авто-WARP${N}"
    echo -e " ${G}openreg install${N}      ${DIM}установить/настроить WARP${N}"
    echo
    echo -e " ${DIM}После ${C}openreg auto on${DIM} все команды opencode${N}"
    echo -e " ${DIM}автоматически идут через WARP прокси.${N}"
    ;;
  *)
    echo -e " ${WARN} ${Y}Неизвестная команда:${N} $1"
    echo -e " ${DIM}Используй:${N} openreg ${G}on${N}|${R}off${N}|${C}status${N}|${M}auto on/off${N}|${B}install${N}"
    ;;
esac
