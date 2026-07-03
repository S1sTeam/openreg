# openreg

Управление Cloudflare WARP прокси для opencode.

## Установка

```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

## Использование

| Команда | Описание |
|---------|----------|
| `openreg` | Справка |
| `openreg on` | Включить WARP |
| `openreg off` | Выключить WARP |
| `openreg toggle` | Переключить WARP |
| `openreg status` | Статус |
| `openreg auto on/off` | Авто-WARP для opencode |

### Авто-режим

```bash
openreg auto on
```

После этого каждый запуск opencode автоматически идёт через WARP.

## Как это работает

WARP (Cloudflare) → SOCKS5 прокси `127.0.0.1:40000` → proxychains перехватывает трафик opencode через `LD_PRELOAD`.

## Требования

- Linux (amd64/arm64), sudo
- opencode (`~/.opencode/bin/opencode`)

## Лицензия

MIT
