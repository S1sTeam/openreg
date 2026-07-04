# openreg
<p align="center">
  <img src="https://i.postimg.cc/qMbPD48Q/Max-a-Sdelaj-fotku-razrese.png" alt="openreg banner"/>
</p>

> Управление Cloudflare WARP из терминала. Автоматический прокси для opencode — обход лимитов запросов.

[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/S1sTeam/openreg/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20wsl-blue)]()
[![WARP](https://img.shields.io/badge/WARP-Cloudflare-orange)]()

---

## Зачем это нужно

**opencode** (и другие AI-инструменты) имеют лимиты на количество запросов.  
Cloudflare WARP меняет ваш выходной IP, что позволяет **обходить эти лимиты**.

Этот скрипт автоматизирует всё:

- установка WARP
- настройка proxychains
- авто-включение WARP при каждом запуске opencode

---

## Установка

### Linux (Ubuntu/Debian)

**Одной строкой:**
```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh \
  && sudo chmod +x /usr/local/bin/openreg \
  && openreg install
```

**Вручную:**
```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

### macOS

```bash
# Скачать скрипт
sudo curl -o /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh
sudo chmod +x /usr/local/bin/openreg

# Установить WARP (https://developers.cloudflare.com/warp-client/get-started/macos/)
# После установки WARP:
openreg install
```

### Windows (WSL)

```bash
# В терминале Ubuntu/Debian под WSL:
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

> **Важно:** openreg работает только на Linux-ядре. На чистом Windows без WSL скрипт не запустится.

---

## Использование

### Базовые команды

| Команда | Действие |
|---------|----------|
| `openreg` | Показать дашборд |
| `openreg on` | Включить WARP |
| `openreg off` | Выключить WARP |
| `openreg toggle` | Переключить WARP |
| `openreg chip` | Сменить IP (перерегистрация) |
| `openreg status` | Показать дашборд |
| `openreg auto on/off` | Авто-WARP для opencode |
| `openreg install` | Установка и настройка WARP |
| `openreg help` | Справка |
| `openreg version` | Версия |

### Авто-режим для opencode

```bash
openreg auto on
```

После этой команды **каждый запуск opencode** автоматически:

1. Включает WARP (если выключен)
2. Запускает opencode через proxychains (весь трафик через WARP)
3. После выхода из opencode WARP остаётся включённым

```bash
openreg auto off   # отключить авто-режим
openreg auto status # проверить статус
```

### Установка с нуля

```bash
openreg install
```

Скрипт сделает всё сам:

1. Скачает и установит Cloudflare WARP
2. Зарегистрирует устройство
3. Настроит proxychains (socks5 `127.0.0.1:40000`)
4. Переведёт WARP в режим прокси
5. Исключит локальные сети из прокси

---

## Как это работает

```
opencode ──▶ proxychains ──▶ WARP SOCKS5 ──▶ Cloudflare ──▶ API
терминал      LD_PRELOAD       :40000          туннель       без лимитов
```

**Ключевые компоненты:**

- **WARP** — туннель Cloudflare, даёт выходной IP из сети Cloudflare
- **proxychains** — перехватывает сетевые вызовы через `LD_PRELOAD` и направляет их в WARP
- **openreg** — управляет всем этим хозяйством

---

## Требования

- **Linux** (Ubuntu/Debian, amd64 или arm64) — нативное выполнение
- **macOS** — через Homebrew или ручную установку WARP
- **Windows** — требуется WSL (Windows Subsystem for Linux)
- **sudo** / root-доступ
- **opencode** — установлен (`~/.opencode/bin/opencode`)

> `openreg.sh` — bash-скрипт, работает на любой POSIX-системе с Linux-ядром.

---

## Структура репозитория

```
openreg/
├── openreg.sh    # Главный скрипт
├── README.md     # Этот файл
└── LICENSE       # MIT
```

---

## Лицензия

MIT — делайте что хотите.
