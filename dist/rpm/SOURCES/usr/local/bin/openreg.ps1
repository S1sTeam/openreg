<#
 .SYNOPSIS
  openreg — WARP proxy manager for opencode (Windows)

 .DESCRIPTION
  Управление Cloudflare WARP прокси для opencode на Windows.

  Команды:
    openreg, openreg help    — справка
    openreg status           — дашборд
    openreg on               — включить WARP
    openreg off              — выключить WARP
    openreg toggle           — переключить WARP
    openreg chip             — сменить IP
    openreg auto on/off      — авто-WARP для opencode
#>

$VERSION = "1.0.0"
$AUTO_FILE = "$env:TEMP\.openreg_auto"

function Logo {
  Write-Host ""
  Write-Host "       openreg v$VERSION" -ForegroundColor Cyan
  Write-Host ""
}

function Get-WarpStatus {
  try {
    $result = warp-cli status 2>&1 | Out-String
    return $result
  } catch {
    return $null
  }
}

function Get-WarpMode {
  try {
    $mode = warp-cli settings 2>&1 | Select-String "Mode:" | ForEach-Object { $_ -replace '.*Mode:\s*', '' }
    if (-not $mode) { return "—" }
    return $mode.Trim()
  } catch {
    return "—"
  }
}

function Get-PublicIP {
  try {
    return (Invoke-WebRequest -Uri "https://ipinfo.io/ip" -TimeoutSec 3 -UseBasicParsing).Content.Trim()
  } catch {
    return "—"
  }
}

function Is-Connected {
  $ws = Get-WarpStatus
  return $ws -match "Connected"
}

function Show-Status {
  Clear-Host
  Logo

  $connected = Is-Connected
  $mode = Get-WarpMode
  $ip = if ($connected) { Get-PublicIP } else { "—" }
  $auto = if (Test-Path $AUTO_FILE) { "ON" } else { "OFF" }
  $statusIcon = if ($connected) { "● Connected" } else { "● Disconnected" }
  $statusColor = if ($connected) { "Green" } else { "Red" }

  Write-Host " ┌──────────────────────────────────────────────────────┐"
  Write-Host " │  WARP STATUS                                        │"
  Write-Host " ├──────────────────────────────────────────────────────┤"
  Write-Host " │ Status                $(" " * (50 - "Status ".Length - $statusIcon.Length))$statusIcon │" -NoNewline
  Write-Host ""
  Write-Host " │ Mode                  $(" " * (50 - "Mode ".Length - $mode.Length))$mode │"
  Write-Host " │ Proxy                 $(" " * 28)127.0.0.1:40000 │"
  Write-Host " │ Current IP            $(" " * (50 - "Current IP ".Length - $ip.Length))$ip │"
  Write-Host " │ Auto-mode             $(" " * (50 - "Auto-mode ".Length - $auto.Length))$auto │"
  Write-Host " └──────────────────────────────────────────────────────┘"
  Write-Host ""
}

function Warp-On {
  if (Is-Connected) { return }
  Write-Host "   Connecting WARP..." -NoNewline
  warp-cli connect 2>&1 | Out-Null
  Start-Sleep -Seconds 2
  if (Is-Connected) {
    Write-Host " ✓" -ForegroundColor Green
  } else {
    Write-Host " ✗ Failed" -ForegroundColor Red
  }
}

function Warp-Off {
  if (-not (Is-Connected)) { return }
  warp-cli disconnect 2>&1 | Out-Null
  Write-Host "   ✓ WARP disconnected" -ForegroundColor Green
}

function Chip-IP {
  $old = Get-PublicIP
  Write-Host "   Old IP: $old"
  Write-Host "   Rotating WARP identity..."
  warp-cli disconnect 2>&1 | Out-Null
  Start-Sleep -Seconds 1
  warp-cli registration new 2>&1 | Out-Null
  Start-Sleep -Seconds 2
  warp-cli connect 2>&1 | Out-Null
  Start-Sleep -Seconds 3
  $new = Get-PublicIP
  if ($new -ne "—") {
    Write-Host "   ✓ New IP: $new" -ForegroundColor Green
  } else {
    Write-Host "   ✗ Failed to get new IP" -ForegroundColor Red
  }
}

function Show-Help {
  Clear-Host
  Logo
  Write-Host " openreg — WARP proxy manager for opencode (Windows)"
  Write-Host ""
  Write-Host " Commands:"
  Write-Host "   openreg status              show WARP dashboard"
  Write-Host "   openreg on                  enable WARP proxy"
  Write-Host "   openreg off                 disable WARP proxy"
  Write-Host "   openreg toggle              toggle WARP proxy"
  Write-Host "   openreg chip                rotate IP identity"
  Write-Host "   openreg auto on/off         auto-WARP for opencode"
  Write-Host ""
  Write-Host " Options:"
  Write-Host "   -h, --help                  show this help"
  Write-Host "   -v, --version               show version"
  Write-Host ""
}

# ── Main ──
$cmd = $args[0]
if (-not $cmd) { $cmd = "status" }

switch ($cmd) {
  "on" { Warp-On }
  "off" { Warp-Off }
  "toggle" {
    if (Is-Connected) { Warp-Off } else { Warp-On }
  }
  "chip" { Chip-IP }
  "status" { Show-Status }
  "dashboard" { Show-Status }
  "version" { Write-Host "openreg v$VERSION" }
  "help" { Show-Help }
  "auto" {
    $sub = $args[1]
    if (-not $sub) { $sub = "status" }
    switch ($sub) {
      "on" {
        New-Item -Path $AUTO_FILE -ItemType File -Force | Out-Null
        Write-Host "   ✓ Auto-mode ON" -ForegroundColor Green
      }
      "off" {
        Remove-Item -Path $AUTO_FILE -Force -ErrorAction SilentlyContinue
        Write-Host "   ✓ Auto-mode OFF" -ForegroundColor Yellow
      }
      "status" {
        if (Test-Path $AUTO_FILE) {
          Write-Host "   ● Auto-mode: ON" -ForegroundColor Green
        } else {
          Write-Host "   ○ Auto-mode: OFF"
        }
      }
      default { Write-Host " Usage: openreg auto on|off|status" }
    }
  }
  default {
    Write-Host " Unknown command: $cmd"
    Write-Host " Try: openreg on|off|status|chip|auto"
  }
}
