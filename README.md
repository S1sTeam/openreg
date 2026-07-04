<p align="center">
  <img src="https://i.postimg.cc/qMbPD48Q/Max-a-Sdelaj-fotku-razrese.png" alt="openreg"/>
</p>

<h3 align="center">Cloudflare WARP manager for your terminal</h3>
<p align="center">
  Auto-proxy for opencode — bypass rate limits
</p>

<p align="center">
  <a href="https://github.com/S1sTeam/openreg/blob/EN/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License"/>
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
  <a href="https://github.com/S1sTeam/openreg/tree/RU">🇷🇺 Русская версия</a>
  &nbsp;&middot;&nbsp;
  <a href="https://github.com/S1sTeam/openreg/wiki">📖 Wiki</a>
</p>

<br>

## Why

**opencode** (and other AI tools) have request rate limits. Cloudflare WARP changes your outbound IP, letting you **bypass those limits**.

openreg automates everything:
- ✅ WARP installation & configuration
- ✅ proxychains setup (`socks5 127.0.0.1:40000`)
- ✅ Auto-enable WARP every time you run opencode

<br>

## Quick install

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

**Windows — PowerShell:**
```powershell
irm https://raw.githubusercontent.com/S1sTeam/openreg/EN/openreg.ps1 -OutFile openreg.ps1
.\openreg.ps1 install
```

<br>

## Commands

| Command | Action |
|---------|--------|
| `openreg` / `openreg status` | Dashboard + Health Check |
| `openreg on` | Enable WARP |
| `openreg off` | Disable WARP |
| `openreg toggle` | Toggle WARP |
| `openreg chip` | Rotate IP (re-register) |
| `openreg auto on/off` | Auto-WARP for opencode |
| `openreg install` | One-command setup |

### Auto mode

```bash
openreg auto on
```

Every opencode launch will now automatically:
1. Enable WARP (if disabled)
2. Run through proxychains
3. Leave WARP on after exit

```bash
openreg auto off    # disable
openreg auto status # check status
```

<br>

## Health Check

`openreg status` checks **all components** end-to-end:

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
│                           ALL SYSTEMS OK                              │
└──────────────────────────────────────────────────────────────────────┘
```

| Check | What it tests |
|-------|---------------|
| WARP proxy | Port `40000` — is WARP listening |
| proxychains config | `/etc/proxychains.conf` |
| proxychains route | Does IP change through proxy |
| Klox API | `127.0.0.1:26406` — is API responding |
| WARP connectivity | Cloudflare tunnel |

<br>

## How it works

```
opencode ──▶ proxychains ──▶ WARP SOCKS5 ──▶ Cloudflare ──▶ API
terminal      LD_PRELOAD       :40000          tunnel        no limits
```

### Architecture

| Component | Role |
|-----------|------|
| **WARP** | Free Cloudflare VPN tunnel — SOCKS5 on `:40000` |
| **proxychains** | Intercepts TCP via `LD_PRELOAD`, routes through WARP |
| **openreg** | One CLI to manage it all |

<br>

## Requirements

- **Linux**: bash, sudo, `warp-cli`, `proxychains4`
- **Windows**: PowerShell 5+, [Cloudflare WARP](https://developers.cloudflare.com/warp-client/get-started/windows/)
- **opencode** installed (`~/.opencode/bin/opencode`)

<br>

## Repository

```
openreg/
├── openreg.sh     # Linux (bash)
├── openreg.ps1    # Windows (PowerShell)
├── README.md
└── LICENSE
```

<br>

## Support

<p align="center">
  <a href="https://github.com/sponsors/S1sTeam">
    <img src="https://img.shields.io/badge/sponsor-GitHub-dc143c?style=for-the-badge" alt="Sponsor"/>
  </a>
  <a href="https://www.donationalerts.com/r/sysik_zhida">
    <img src="https://img.shields.io/badge/donate-DonationAlerts-ff69b4?style=for-the-badge" alt="Donate"/>
  </a>
</p>

<br>

## License

<p align="center">
  MIT — do whatever you want.
</p>
