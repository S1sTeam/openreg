<p align="center">
  <img src="https://i.postimg.cc/qMbPD48Q/Max-a-Sdelaj-fotku-razrese.png" alt="openreg"/>
</p>

<h3 align="center">Управление Cloudflare WARP из терминала</h3>
<p align="center">
  Автоматический прокси для opencode — обход лимитов запросов
</p>

<p align="center">
  <a href="https://github.com/S1sTeam/openreg/blob/EN/LICENSE">
    <img src="https://img.shields.io/badge/%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F-MIT-green?style=flat-square" alt="License"/>
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/platform-linux%20%7C%20win-blue?style=flat-square" alt="Platform"/>
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/WARP-Cloudflare-orange?style=flat-square" alt="WARP"/>
  </a>
  <a href="https://github.com/sponsors/S1sTeam">
    <img src="https://img.shields.io/badge/sponsor-%F0%9F%92%96-dc143c?style=flat-square" alt="Sponsor"/>
  </a>
  <a href="https://github.com/S1sTeam/openreg/releases">
    <img src="https://img.shields.io/github/v/release/S1sTeam/openreg?style=flat-square" alt="Release"/>
  </a>
</p>

<p align="center">
  <a href="https://github.com/S1sTeam/openreg">🇬🇧 English version</a>
  &nbsp;&middot;&nbsp;
  <a href="https://github.com/S1sTeam/openreg/wiki">📖 Wiki</a>
</p>

<br>

## Зачем это нужно

**opencode** (и другие AI-инструменты) имеют лимиты на количество запросов. Cloudflare WARP меняет ваш выходной IP, что позволяет **обходить эти лимиты**.

openreg автоматизирует всё:
- ✅ Установка и настройка WARP
- ✅ Настройка proxychains (`socks5 127.0.0.1:40000`)
- ✅ Авто-включение WARP при каждом запуске opencode

<br>

## Быстрая установка

**Linux — deb:**
```bash
wget https://github.com/S1sTeam/openreg/releases/download/v2.1.0/openreg_2.1.0_all.deb
sudo dpkg -i openreg_2.1.0_all.deb
openreg install
```

**Linux — скрипт:**
```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

**Windows — PowerShell:**
```powershell
irm https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.ps1 -OutFile openreg.ps1
.\openreg.ps1 install
```

<br>

## Команды

| Команда | Действие |
|---------|----------|
| `openreg` / `openreg status` | Дашборд + Health Check |
| `openreg on` | Включить WARP |
| `openreg off` | Выключить WARP |
| `openreg toggle` | Переключить WARP |
| `openreg chip` | Сменить IP |
| `openreg auto on/off` | Авто-WARP для opencode |
| `openreg install` | Установка с нуля |

### Авто-режим

```bash
openreg auto on
```

Теперь каждый запуск opencode автоматически:
1. Включает WARP (если выключен)
2. Запускает через proxychains
3. Оставляет WARP включённым после выхода

```bash
openreg auto off    # отключить
openreg auto status # проверить
```

<br>

## Проверка системы

`openreg status` проверяет **все компоненты**:

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
│                           ВСЁ РАБОТАЕТ                                │
└──────────────────────────────────────────────────────────────────────┘
```

| Проверка | Что тестирует |
|----------|---------------|
| WARP прокси | Порт `40000` — слушает ли WARP |
| Настройка proxychains | `/etc/proxychains.conf` |
| Маршрут proxychains | Меняется ли IP через прокси |
| Klox API | `127.0.0.1:26406` — отвечает ли API |
| Подключение WARP | Туннель Cloudflare |

<br>

## Как это работает

```
opencode ──▶ proxychains ──▶ WARP SOCKS5 ──▶ Cloudflare ──▶ API
терминал      LD_PRELOAD       :40000          туннель       без лимитов
```

### Компоненты

| Компонент | Роль |
|-----------|------|
| **WARP** | Бесплатный VPN-туннель Cloudflare — SOCKS5 на `:40000` |
| **proxychains** | Перехватывает TCP через `LD_PRELOAD`, направляет в WARP |
| **openreg** | Одна CLI для управления всем |

<br>

## Требования

- **Linux**: bash, sudo, `warp-cli`, `proxychains4`
- **Windows**: PowerShell 5+, [Cloudflare WARP](https://developers.cloudflare.com/warp-client/get-started/windows/)
- **opencode** установлен (`~/.opencode/bin/opencode`)

<br>

## Репозиторий

```
openreg/
├── openreg.sh     # Linux (bash)
├── openreg.ps1    # Windows (PowerShell)
├── README.md
└── LICENSE
```

<br>

## Поддержать проект

<p align="center">
  <a href="https://github.com/sponsors/S1sTeam">
    <img src="https://img.shields.io/badge/sponsor-GitHub-dc143c?style=for-the-badge" alt="Sponsor"/>
  </a>
  <a href="https://www.donationalerts.com/r/sysik_zhida">
    <img src="https://img.shields.io/badge/donate-DonationAlerts-ff69b4?style=for-the-badge" alt="Donate"/>
  </a>
</p>

<br>

## Лицензия

<p align="center">
  MIT — делайте что хотите.
</p>
