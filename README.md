# openreg — WARP Proxy Toggle for opencode

Автоматическое управление Cloudflare WARP для обхода лимитов opencode.

## Установка

```bash
curl -sL https://raw.githubusercontent.com/eutur/openreg/main/openreg.sh | sudo bash
```

Или вручную:

```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/eutur/openreg/main/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

## Использование

| Команда | Описание |
|---------|----------|
| `openreg` | вкл/выкл WARP |
| `openreg on` | включить WARP |
| `openreg off` | выключить WARP |
| `openreg status` | показать статус |
| `openreg auto on` | авто-WARP для opencode |
| `openreg auto off` | отключить авто-WARP |
| `openreg install` | установить/настроить WARP с нуля |

## Как работает

`openreg auto on` создаёт wrapper для `opencode`, который автоматически
включает WARP прокси перед каждым запуском. Все запросы к API opencode
идут через разные IP, что позволяет обходить лимиты.

## Требования

- Linux (amd64/arm64)
- opencode
- sudo/root
