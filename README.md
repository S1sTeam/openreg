# openreg

> Управление Cloudflare WARP из терминала. Автоматический прокси для opencode — обход лимитов запросов.

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux-amd64%20|%20arm64-blue)]()
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

### Одной строкой

```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh \
  && sudo chmod +x /usr/local/bin/openreg \
  && openreg install
```

### Вручную

```bash
# Скачать
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.sh
sudo chmod +x /usr/local/bin/openreg

# Установить WARP и настроить
openreg install
```

---

## Использование

### Базовые команды

| Команда | Действие |
|---------|----------|
| `openreg` |显示 справку |
| `openreg on` | Включить WARP |
| `openreg off` | Выключить WARP |
| `openreg toggle` | Переключить WARP (вкл/выкл) |
| `openreg status` | Показать статус |

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
opencode → openreg wrapper → proxychains → WARP SOCKS5 (:40000) → Cloudflare → opencode API
```

```
┌─────────────────┐     ┌──────────────┐     ┌──────────────────┐
│ opencode        │────▶│ proxychains  │────▶│ WARP (SOCKS5)    │
│ (ваш терминал)  │     │ LD_PRELOAD   │     │ 127.0.0.1:40000  │
└─────────────────┘     └──────────────┘     └────────┬─────────┘
                                                       │
                                                       ▼
                                              ┌──────────────────┐
                                              │ Cloudflare WARP  │
                                              │ (разные IP)      │
                                              └────────┬─────────┘
                                                       │
                                                       ▼
                                              ┌──────────────────┐
                                              │ opencode API     │
                                              │ (лимиты сброшены)│
                                              └──────────────────┘
```

**Ключевые компоненты:**

- **WARP** — туннель Cloudflare, даёт выходной IP из сети Cloudflare
- **proxychains** — перехватывает сетевые вызовы через `LD_PRELOAD` и направляет их в WARP
- **openreg** — управляет всем этим хозяйством

---

## Требования

- **Linux** (Ubuntu/Debian, amd64 или arm64)
- **sudo** / root-доступ
- **opencode** — установлен (`~/.opencode/bin/opencode`)

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
