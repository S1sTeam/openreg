# openreg
<p align="center">
  <img src="https://i.postimg.cc/qMbPD48Q/Max-a-Sdelaj-fotku-razrese.png" alt="openreg banner"/>
</p>

> Cloudflare WARP manager for your terminal. Auto-proxy for opencode — bypass rate limits.

[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/S1sTeam/openreg/blob/EN/LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20win-blue)]()
[![WARP](https://img.shields.io/badge/WARP-Cloudflare-orange)]()
[![Sponsor](https://img.shields.io/badge/sponsor-%F0%9F%92%96-dc143c)](https://github.com/sponsors/S1sTeam)

[🇷🇺 Русская версия](https://github.com/S1sTeam/openreg/tree/RU)

---

## Why

**opencode** (and other AI tools) have request rate limits.  
Cloudflare WARP changes your outbound IP, letting you **bypass those limits**.

This script automates everything:
- WARP installation
- proxychains configuration
- auto-enable WARP every time you run opencode

---

## Install

### Linux — deb package (Debian/Ubuntu)

```bash
wget https://github.com/S1sTeam/openreg/releases/download/v2.1.0/openreg_2.1.0_all.deb
sudo dpkg -i openreg_2.1.0_all.deb
openreg install
```

### Linux — script (any distro)

```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

**Manual:**
```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.ps1 -OutFile openreg.ps1
.\openreg.ps1 install
```

> Requires [Cloudflare WARP](https://developers.cloudflare.com/warp-client/get-started/windows/) for Windows.  
> After WARP is installed, add `openreg.ps1` to PATH or create an alias:
> ```powershell
> Set-Alias openreg C:\path\to\openreg.ps1
> ```

---

## Usage

### Commands

| Command | Action |
|---------|--------|
| `openreg` / `openreg status` | Dashboard + Health Check |
| `openreg on` | Enable WARP |
| `openreg off` | Disable WARP |
| `openreg toggle` | Toggle WARP |
| `openreg chip` | Rotate IP |
| `openreg auto on/off` | Auto-WARP for opencode |
| `openreg install` | Setup WARP |

### Auto mode

```bash
openreg auto on
```

After this, **every opencode launch** automatically:
1. Enables WARP (if disabled)
2. Runs opencode through proxychains
3. Leaves WARP on after exit

```bash
openreg auto off
openreg auto status
```

---

## Health Check

`openreg status` checks all components:

| Check | What it tests |
|-------|---------------|
| WARP proxy | Port `40000` — is WARP listening |
| proxychains config | `/etc/proxychains.conf` |
| proxychains route | Does IP change through proxy |
| Klox API | `127.0.0.1:26406` |
| WARP connectivity | Cloudflare tunnel |

Result: **ALL SYSTEMS OK** or **ISSUES DETECTED**.

---

## How it works

```
opencode ──▶ proxychains ──▶ WARP SOCKS5 ──▶ Cloudflare ──▶ API
terminal      LD_PRELOAD       :40000          tunnel        no limits
```

---

## Requirements

- **Linux**: bash, sudo, warp-cli, proxychains
- **Windows**: PowerShell 5+, [Cloudflare WARP](https://developers.cloudflare.com/warp-client/get-started/windows/)
- **opencode** installed (`~/.opencode/bin/opencode`)

---

## Repository structure

```
openreg/
├── openreg.sh     # Linux (bash)
├── openreg.ps1    # Windows (PowerShell)
├── README.md
└── LICENSE
```

---

## Support

[![Sponsor](https://img.shields.io/badge/sponsor-GitHub-dc143c)](https://github.com/sponsors/S1sTeam)
[![Donate](https://img.shields.io/badge/donate-DonationAlerts-ff69b4)](https://www.donationalerts.com/r/sysik_zhida)

Any support helps keep the project alive.

---

## License

MIT — do whatever you want.
