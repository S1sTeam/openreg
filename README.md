# openreg
<p align="center">
  <img src="https://i.postimg.cc/qMbPD48Q/Max-a-Sdelaj-fotku-razrese.png" alt="openreg banner"/>
</p>

> Управление Cloudflare WARP из терминала. Автоматический прокси для opencode — обход лимитов запросов.

[![License](https://img.shields.io/badge/%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F-MIT-green)](https://github.com/S1sTeam/openreg/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/%D0%BF%D0%BB%D0%B0%D1%82%D1%84%D0%BE%D1%80%D0%BC%D0%B0-linux%20%7C%20win-blue)]()
[![WARP](https://img.shields.io/badge/WARP-Cloudflare-orange)]()
[![Sponsor](https://img.shields.io/badge/sponsor-%F0%9F%92%96-dc143c)](https://github.com/sponsors/S1sTeam)

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

### Linux — deb-пакет (Debian/Ubuntu)

```bash
# Скачать и установить .deb
wget https://github.com/S1sTeam/openreg/releases/download/v2.1.0/openreg_2.1.0_all.deb
sudo dpkg -i openreg_2.1.0_all.deb
openreg install
```

### Linux — скрипт (любой дистрибутив)

```bash
# Одной строкой
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

### Windows (PowerShell)

```powershell
# Скачать и запустить
irm https://raw.githubusercontent.com/S1sTeam/openreg/main/openreg.ps1 -OutFile openreg.ps1
.\openreg.ps1 install
```

> Требуется [Cloudflare WARP](https://developers.cloudflare.com/warp-client/get-started/windows/) для Windows.  
> После установки WARP добавьте `openreg.ps1` в PATH или создайте алиас:
> ```powershell
> Set-Alias openreg C:\путь\к\openreg.ps1
> ```

---

## Использование

### Базовые команды

| Команда | Действие |
|---------|----------|
| `openreg` / `openreg status` | Дашборд + Health Check |
| `openreg on` | Включить WARP |
| `openreg off` | Выключить WARP |
| `openreg toggle` | Переключить WARP |
| `openreg chip` | Сменить IP (перерегистрация) |
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

## Проверка системы

`openreg status` проверяет **все компоненты** и показывает итоговый статус:

| Проверка | Что тестирует |
|----------|---------------|
| WARP прокси | Порт `40000` — слушает ли WARP |
| Настройка proxychains | Файл `/etc/proxychains.conf` — правильная конфигурация |
| Маршрут proxychains | Трафик через proxychains — меняется ли IP |
| Klox API | `127.0.0.1:26406` — отвечает ли ваш API |
| Подключение WARP | Cloudflare — работает ли туннель |

В конце — **ВСЁ РАБОТАЕТ** или **ЕСТЬ ПРОБЛЕМЫ**.

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

- **Linux**: bash, sudo, warp-cli, proxychains
- **Windows**: PowerShell 5+, [Cloudflare WARP](https://developers.cloudflare.com/warp-client/get-started/windows/)
- **opencode** — установлен (`~/.opencode/bin/opencode`)

---

## Структура репозитория

```
openreg/
├── openreg.sh     # Linux (bash)
├── openreg.ps1    # Windows (PowerShell)
├── README.md
└── LICENSE
```

---

## Поддержать проект

[![Sponsor](https://img.shields.io/badge/sponsor-GitHub-dc143c)](https://github.com/sponsors/S1sTeam)
[![Donate](https://img.shields.io/badge/donate-DonationAlerts-ff69b4)](https://www.donationalerts.com/r/klox)

Любая поддержка помогает проекту жить и развиваться.

## Лицензия

MIT — делайте что хотите.
