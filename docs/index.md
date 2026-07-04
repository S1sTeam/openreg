# openreg

> Управление Cloudflare WARP из терминала. Автоматический прокси для opencode — обход лимитов запросов.

## Установка

**Linux — deb:**
```bash
wget https://github.com/S1sTeam/openreg/releases/download/v2.1.0/openreg_2.1.0_all.deb
sudo dpkg -i openreg_2.1.0_all.deb
openreg install
```

**Linux — скрипт:**
```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.ps1 -OutFile openreg.ps1
.\openreg.ps1 install
```

## Команды

| Команда | Действие |
|---------|----------|
| `openreg` / `openreg status` | Дашборд + Health Check |
| `openreg on` | Включить WARP |
| `openreg off` | Выключить WARP |
| `openreg toggle` | Переключить WARP |
| `openreg chip` | Сменить IP |
| `openreg auto on/off` | Авто-WARP для opencode |
| `openreg install` | Установка и настройка WARP |

## Проверка системы

`openreg status` проверяет все компоненты:

- WARP прокси (порт `40000`)
- Настройка proxychains (`/etc/proxychains.conf`)
- Маршрут proxychains (меняется ли IP)
- Klox API (`127.0.0.1:26406`)
- Подключение WARP (Cloudflare)

В конце: **ВСЁ РАБОТАЕТ** или **ЕСТЬ ПРОБЛЕМЫ**.

## Как это работает

```
opencode ──▶ proxychains ──▶ WARP SOCKS5 ──▶ Cloudflare ──▶ API
терминал      LD_PRELOAD       :40000          туннель       без лимитов
```

## Health Check скриншот

```
┌──────────────────────────────────────────────────────────────────────┐
│  HEALTH CHECK                                                         │
├──────────────────────────────────────────────────────────────────────┤
│ WARP proxy        ● passing                                           │
│ proxychains conf  ● passing                                           │
│ proxychains route ● passing                                           │
│ Klox API          ● passing                                           │
│ WARP connectivity ● passing                                           │
├──────────────────────────────────────────────────────────────────────┤
│                           ВСЁ РАБОТАЕТ                               │
└──────────────────────────────────────────────────────────────────────┘
```
