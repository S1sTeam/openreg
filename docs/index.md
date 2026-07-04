# openreg

> Cloudflare WARP manager for your terminal. Auto-proxy for opencode — bypass rate limits.

## Install

**Linux — deb:**
```bash
wget https://github.com/S1sTeam/openreg/releases/download/v2.1.0/openreg_2.1.0_all.deb
sudo dpkg -i openreg_2.1.0_all.deb
openreg install
```

**Linux — script:**
```bash
sudo wget -O /usr/local/bin/openreg https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.sh
sudo chmod +x /usr/local/bin/openreg
openreg install
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.ps1 -OutFile openreg.ps1
.\openreg.ps1 install
```

## Commands

| Command | Action |
|---------|--------|
| `openreg` / `openreg status` | Dashboard + Health Check |
| `openreg on` | Enable WARP |
| `openreg off` | Disable WARP |
| `openreg toggle` | Toggle WARP |
| `openreg chip` | Rotate IP |
| `openreg auto on/off` | Auto-WARP for opencode |
| `openreg install` | Setup WARP |

## Health Check

`openreg status` checks all components:

- **WARP proxy** — port `40000`
- **proxychains config** — configuration file
- **proxychains route** — does IP change
- **Klox API** — API endpoint
- **WARP connectivity** — Cloudflare tunnel

## How it works

```
opencode ──▶ proxychains ──▶ WARP SOCKS5 ──▶ Cloudflare ──▶ API
```
