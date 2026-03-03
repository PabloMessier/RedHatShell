# refresh-portproxy.ps1
# Quick script to refresh port proxy when WSL IP changes
# Run in elevated PowerShell: .\refresh-portproxy.ps1

#Requires -RunAsAdministrator

$WSL_DISTRO = "RHEL"
$SSH_PORT = 22

$wslIp = (wsl -d $WSL_DISTRO -- bash -lc "hostname -I | awk '{print `$1}'").Trim()
if (-not $wslIp) {
    Write-Error "Failed to get WSL IP. Is $WSL_DISTRO running?"
    exit 1
}

netsh interface portproxy delete v4tov4 listenport=$SSH_PORT listenaddress=0.0.0.0 2>$null
netsh interface portproxy add v4tov4 listenport=$SSH_PORT listenaddress=0.0.0.0 connectport=$SSH_PORT connectaddress=$wslIp

Write-Host "Port proxy updated: 0.0.0.0:$SSH_PORT -> ${wslIp}:$SSH_PORT" -ForegroundColor Green
