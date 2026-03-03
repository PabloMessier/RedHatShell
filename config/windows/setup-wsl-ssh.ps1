# setup-wsl-ssh.ps1
# Run this script in an elevated PowerShell on Windows to configure SSH access to WSL RHEL
# Usage: .\setup-wsl-ssh.ps1

#Requires -RunAsAdministrator

$WSL_DISTRO = "RHEL"
$SSH_PORT = 22

Write-Host "=== WSL SSH Setup Script ===" -ForegroundColor Cyan

# Get WSL IP address
Write-Host "`n[1/4] Getting WSL IP address..." -ForegroundColor Yellow
$wslIp = (wsl -d $WSL_DISTRO -- bash -lc "hostname -I | awk '{print `$1}'").Trim()
if (-not $wslIp) {
    Write-Error "Failed to get WSL IP address. Is $WSL_DISTRO running?"
    exit 1
}
Write-Host "WSL IP: $wslIp" -ForegroundColor Green

# Configure port proxy
Write-Host "`n[2/4] Configuring port proxy..." -ForegroundColor Yellow
netsh interface portproxy delete v4tov4 listenport=$SSH_PORT listenaddress=0.0.0.0 2>$null
netsh interface portproxy add v4tov4 listenport=$SSH_PORT listenaddress=0.0.0.0 connectport=$SSH_PORT connectaddress=$wslIp
Write-Host "Port proxy configured: 0.0.0.0:$SSH_PORT -> ${wslIp}:$SSH_PORT" -ForegroundColor Green

# Configure firewall
Write-Host "`n[3/4] Configuring Windows Firewall..." -ForegroundColor Yellow
$ruleName = "WSL SSH"
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($existingRule) {
    Set-NetFirewallRule -DisplayName $ruleName -Profile Any -Enabled True
    Write-Host "Updated existing firewall rule: $ruleName" -ForegroundColor Green
} else {
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort $SSH_PORT -Protocol TCP -Action Allow -Profile Any | Out-Null
    Write-Host "Created firewall rule: $ruleName" -ForegroundColor Green
}

# Verify setup
Write-Host "`n[4/4] Verifying setup..." -ForegroundColor Yellow
Write-Host "`nPort proxy configuration:" -ForegroundColor Cyan
netsh interface portproxy show all

Write-Host "`nFirewall rule:" -ForegroundColor Cyan
Get-NetFirewallRule -DisplayName "$ruleName*" | Format-Table DisplayName, Enabled, Profile

Write-Host "`nListening ports:" -ForegroundColor Cyan
netstat -an | Select-String ":$SSH_PORT "

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Connect from LAN: ssh root@<windows-lan-ip>" -ForegroundColor White
Write-Host "Note: WSL IP may change after restart. Re-run this script to update." -ForegroundColor Yellow
