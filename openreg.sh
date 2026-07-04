#!/bin/bash

R="\e[31m"; G="\e[32m"; Y="\e[33m"; B="\e[34m"; C="\e[36m"; M="\e[35m"; W="\e[97m"; N="\e[0m"
BOLD="\e[1m"; DIM="\e[2m"
CHECK="${G}✓${N}"; CROSS="${R}✗${N}"

OPENCODE_BIN="$HOME/.opencode/bin/opencode"
AUTO_FILE="/tmp/.openreg_auto"

VERSION="2.1.0"

# strip ANSI codes
strip_ansi() { printf '%s' "$1" | sed 's/\x1b\[[0-9;]*[mK]//g'; }

# visible width
vwidth() { printf '%s' "$1" | sed 's/\x1b\[[0-9;]*[mK]//g' | wc -m; }

BW=56
IW=52

box_top()    { echo -e " ${DIM}┌──────────────────────────────────────────────────────────────────────┐${N}"; }
box_mid()    { echo -e " ${DIM}├──────────────────────────────────────────────────────────────────────┤${N}"; }
box_bot()    { echo -e " ${DIM}└──────────────────────────────────────────────────────────────────────┘${N}"; }

box_line() {
  local vis=$(vwidth "$1")
  local pad=$(( IW - vis ))
  (( pad < 0 )) && pad=0
  echo -e " ${DIM}│${N} $1$(printf '%*s' $pad '') ${DIM}│${N}"
}

box_title() {
  local vis=$(vwidth "${BOLD}$1${N}")
  local pad=$(( IW - vis - 2 ))
  (( pad < 0 )) && pad=0
  echo -e " ${DIM}│${N}  ${BOLD}$1${N}$(printf '%*s' $pad '') ${DIM}│${N}"
}

logo() {
  echo
  echo -e "                                   ${DIM}▄${N}"
  echo -e "       ${BOLD}${C}█▀▀█ █▀▀█ ▀▀█▀▀ █▀▀▀ █▀▀▀ █▀▀█ █▀▀█${N}"
  echo -e "       ${BOLD}${C}█  █ █▀▀▀   █   █▀▀▀ █    █  █ █▀▀▀${N}"
  echo -e "       ${BOLD}${C}▀▀▀▀ ▀     ▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀${N}"
  echo
}

version() { echo "openreg v${VERSION}"; }

install_warp() {
  echo -e " ${BOLD}Installing WARP...${N}"
  if command -v warp-cli &>/dev/null; then
    echo -e "   ${CHECK} ${G}WARP already installed${N}"; return
  fi
  local ARCH=$(dpkg --print-architecture)
  local WARP_DEB="/tmp/warp.deb"
  local WARP_URL="https://pkg.cloudflareclient.com/packages/cloudflare-warp"
  case "$ARCH" in
    amd64|arm64) WARP_URL+="_${ARCH}.deb" ;;
    *) echo -e "   ${CROSS} ${R}Unsupported: $ARCH${N}"; return 1 ;;
  esac
  curl -sL "$WARP_URL" -o "$WARP_DEB" && dpkg -i "$WARP_DEB" &>/dev/null || apt-get install -f -y &>/dev/null
  echo -e "   ${CHECK} ${G}WARP installed${N}"; rm -f "$WARP_DEB"
}

setup_proxychains() {
  [ ! -f /etc/proxychains4.conf ] && apt-get install -y proxychains4 &>/dev/null
  grep -q "socks5.*127.0.0.1.*40000" /etc/proxychains4.conf 2>/dev/null && return
  cat > /etc/proxychains4.conf << 'PCEOF'
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5 127.0.0.1 40000
PCEOF
}

init_warp() {
  warp-cli status &>/dev/null || warp-cli registration new &>/dev/null
  local MODE=$(warp-cli settings 2>/dev/null | grep "Mode:" | awk '{print $NF}')
  [ "$MODE" != "WarpProxy" ] && warp-cli mode proxy &>/dev/null
  warp-cli tunnel ip add-range 127.0.0.0/8 &>/dev/null 2>&1
  warp-cli tunnel ip add-range 10.0.0.0/8 &>/dev/null 2>&1
  warp-cli tunnel ip add-range 172.16.0.0/12 &>/dev/null 2>&1
  warp-cli tunnel ip add-range 192.168.0.0/16 &>/dev/null 2>&1
}

warp_on() {
  warp-cli status 2>/dev/null | grep -q "Connected" && return 0
  warp-cli connect &>/dev/null; sleep 2
  if warp-cli status 2>/dev/null | grep -q "Connected"; then
    echo -e "   ${CHECK} ${G}WARP connected${N}"; return 0
  else
    echo -e "   ${CROSS} ${R}Failed to connect${N}"; return 1
  fi
}

warp_off() {
  warp-cli status 2>/dev/null | grep -q "Disconnected" && return 0
  warp-cli disconnect &>/dev/null
  echo -e "   ${CHECK} ${G}WARP disconnected${N}"
}

get_ip() {
  local ip=$(curl -s --max-time 3 https://ipinfo.io/ip 2>/dev/null)
  [ -n "$ip" ] && echo "$ip" || echo "—"
}

chip_ip() {
  local OLD=$(get_ip)
  echo -e "   ${DIM}Old IP:${N} $OLD"
  echo -e "   ${DIM}Rotating WARP identity...${N}"
  warp-cli disconnect &>/dev/null
  sleep 1
  warp-cli registration new &>/dev/null
  sleep 2
  warp-cli connect &>/dev/null
  sleep 3
  local NEW=$(get_ip)
  if [ "$NEW" != "—" ]; then
    echo -e "   ${CHECK} ${G}New IP:${N} $NEW"
    [ "$OLD" != "$NEW" ] && [ "$OLD" != "—" ] && echo -e "   ${CHECK} ${G}IP changed successfully${N}" || echo -e "   ${Y}IP unchanged, try again${N}"
  else
    echo -e "   ${CROSS} ${R}Failed to get new IP${N}"
  fi
}

dashboard() {
  clear
  logo

  local WS=$(warp-cli status 2>/dev/null)
  local CON=false; echo "$WS" | grep -q "Connected" && CON=true
  local MODE=$(warp-cli settings 2>/dev/null | grep "Mode:" | sed 's/.*Mode://' | xargs)
  local IP=$($CON && get_ip || echo "—")
  local AUTO=$([ -f "$AUTO_FILE" ] && echo "${G}ON${N}" || echo "${DIM}OFF${N}")
  local PC=$([ -n "$LD_PRELOAD" ] && echo "$LD_PRELOAD" | grep -q "proxychains" && echo "${G}active${N}" || echo "${DIM}inactive${N}")
  local STAT=$($CON && echo "${G}● Connected${N}" || echo "${R}● Disconnected${N}")

  box_top
  box_title "WARP STATUS"
  box_mid
  box_line "Status                         ${STAT}"
  box_line "Mode                           ${MODE:-N/A}"
  box_line "Proxy                          ${DIM}127.0.0.1:40000${N}"
  box_line "Current IP                     ${IP}"
  box_line "Auto-mode                      ${AUTO}"
  box_line "proxychains                    ${PC}"
  box_bot
  echo
  box_top
  box_title "AI SERVICES"
  box_mid
  if curl -sf http://127.0.0.1:26406/v1/models -o /dev/null; then
    box_line "Klox API      ${G}●${N} ${G}online${N}  ${DIM}:26406${N}"
  else
    box_line "Klox API      ${R}●${N} ${R}offline${N} ${DIM}:26406${N}"
  fi
  box_line "opencode      ${BOLD}$("$OPENCODE_BIN" --version 2>/dev/null || echo "N/A")${N}"
  box_bot
  echo
  echo -e "       ${DIM}openreg v${VERSION} — ${C}on${N}${DIM}|${C}off${N}${DIM}|${C}toggle${N}${DIM}|${C}chip${N}${DIM}|${C}auto${N}${DIM}|${C}status${N}"
  echo
}

opencode_wrapper() {
  if [ -f "$AUTO_FILE" ]; then
    warp_on 2>/dev/null || true
  fi
  if [ -n "$LD_PRELOAD" ] && echo "$LD_PRELOAD" | grep -q "proxychains"; then
    exec "$OPENCODE_BIN" "$@"
  else
    exec env LD_PRELOAD="libproxychains.so.3${LD_PRELOAD:+:$LD_PRELOAD}" "$OPENCODE_BIN" "$@"
  fi
}

case "${1:-dashboard}" in
  install|setup)
    install_warp; setup_proxychains; init_warp
    dashboard
    ;;
  on|connect)
    warp_on
    ;;
  off|disconnect)
    warp_off
    ;;
  toggle)
    if warp-cli status 2>/dev/null | grep -q "Connected"; then warp_off; else warp_on; fi
    ;;
  chip|rotate|newip)
    chip_ip
    ;;
  auto)
    case "${2:-status}" in
      on|enable|1)
        touch "$AUTO_FILE"
        echo -e "   ${CHECK} ${G}Auto-mode ON${N}"
        grep -q "openreg opencode" "$HOME/.bashrc" 2>/dev/null || {
          echo 'opencode() { openreg opencode "$@"; }' >> "$HOME/.bashrc"
          echo 'export -f opencode' >> "$HOME/.bashrc"
        }
        cat > /usr/local/bin/opencode << 'WEOF'
#!/bin/bash
AUTO_FILE="/tmp/.openreg_auto"
OPENCODE_BIN="$HOME/.opencode/bin/opencode"
if [ -f "$AUTO_FILE" ]; then
  if warp-cli status 2>/dev/null | grep -q "Disconnected"; then
    warp-cli connect &>/dev/null; sleep 1
  fi
fi
if [ -n "$LD_PRELOAD" ] && echo "$LD_PRELOAD" | grep -q "proxychains"; then
  exec "$OPENCODE_BIN" "$@"
else
  exec env LD_PRELOAD="libproxychains.so.3${LD_PRELOAD:+:$LD_PRELOAD}" "$OPENCODE_BIN" "$@"
fi
WEOF
        chmod +x /usr/local/bin/opencode
        echo -e "   ${CHECK} ${G}Wrapper: /usr/local/bin/opencode${N}"
        ;;
      off|disable|0)
        rm -f "$AUTO_FILE"
        echo -e "   ${CHECK} ${Y}Auto-mode OFF${N}"
        ;;
      status)
        [ -f "$AUTO_FILE" ] && echo -e "   ${G}●${N} ${BOLD}${G}ON${N}" || echo -e "   ${DIM}⊙${N} ${BOLD}${DIM}OFF${N}"
        ;;
      *) echo -e " ${Y}Usage:${N} openreg auto ${G}on${N}|${R}off${N}|${C}status${N}" ;;
    esac
    ;;
  opencode)
    shift; opencode_wrapper "$@"
    ;;
  status|dashboard|stat)
    dashboard
    ;;
  version|--version|-v)
    version
    ;;
  help|--help|-h)
    logo
    echo -e " ${DIM}openreg — WARP proxy manager for opencode${N}"
    echo
    echo -e " ${BOLD}Commands:${N}"
    echo -e "   openreg ${G}status${N}               show WARP dashboard"
    echo -e "   openreg ${G}on${N}                   enable WARP"
    echo -e "   openreg ${G}off${N}                  disable WARP"
    echo -e "   openreg ${G}toggle${N}               toggle WARP"
    echo -e "   openreg ${G}auto${N} ${C}on/off${N}           auto-WARP for opencode"
    echo -e "   openreg ${G}chip${N}                 rotate IP"
    echo -e "   openreg ${G}install${N}              install & configure WARP"
    echo
    echo -e " ${BOLD}Options:${N}"
    echo -e "   ${DIM}-h, --help${N}                   show help"
    echo -e "   ${DIM}-v, --version${N}                show version"
    echo
    echo -e " ${DIM}After ${C}openreg auto on${DIM}, all opencode commands${N}"
    echo -e " ${DIM}automatically route through WARP proxy.${N}"
    echo
    ;;
  *)
    echo -e " ${Y}Unknown command:${N} $1"
    echo -e " ${DIM}Try:${N} openreg ${G}on${N}|${R}off${N}|${C}status${N}|${M}chip${N}|${M}auto${N}|${B}install${N}"
    ;;
esac
