# SSH Setup for RedHat Shell

This document describes how to configure SSH access between the RedHat Shell container (Podman on macOS) and a RHEL WSL instance on Windows, as well as LAN access from other machines.

## Architecture

```
┌─────────────────┐     ┌─────────────────────────────────────────────┐
│  macOS Host     │     │  Windows Host (<WINDOWS_IP>)               │
│                 │     │                                             │
│  ┌───────────┐  │     │  ┌─────────────┐    ┌───────────────────┐  │
│  │ Podman VM │  │     │  │ Port Proxy  │    │ WSL RHEL          │  │
│  │           │  │ SSH │  │ 0.0.0.0:22  │───▶│ <WSL_IP>:22       │  │
│  │ redhat-   │──┼────▶│  └─────────────┘    │                   │  │
│  │ shell     │  │     │                     │ sshd running      │  │
│  │ 10.88.0.2 │  │     │  Windows Firewall   │ root key auth     │  │
│  └───────────┘  │     │  allows TCP/22      └───────────────────┘  │
└─────────────────┘     └─────────────────────────────────────────────┘
```

## Quick Start

### From the redhat-shell container
```bash
ssh -i /root/.ssh/id_ed25519 root@<WINDOWS_IP>
```

### From macOS
```bash
ssh root@<WINDOWS_IP>
```
(Requires adding your Mac's public key to WSL - see below)

## SSH Keys

### Container Key (redhat-shell)
- **Private key**: `/root/.ssh/id_ed25519` (inside container)
- **Public key**: `/root/.ssh/id_ed25519.pub`
- **Backup location**: `ssh-keys/` in this repository

The public key is installed in `/root/.ssh/authorized_keys` on the WSL RHEL instance.

### Adding Your Mac's Key
```bash
# Generate key if needed
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519

# Copy to WSL (via Windows)
cat ~/.ssh/id_ed25519.pub | ssh root@<WINDOWS_IP> 'cat >> ~/.ssh/authorized_keys'
```

## Windows Configuration

### Port Proxy
Windows uses `netsh` port proxy to forward SSH connections from the LAN to WSL:
```powershell
netsh interface portproxy add v4tov4 listenport=22 listenaddress=0.0.0.0 connectport=22 connectaddress=<WSL_IP>
```

### Firewall
A firewall rule named "WSL SSH" allows inbound TCP port 22 on all profiles (Private, Public, Domain).

### Setup Scripts
Use the provided PowerShell scripts in `config/windows/`:
- `setup-wsl-ssh.ps1` - Full setup (port proxy + firewall)
- `refresh-portproxy.ps1` - Update port proxy when WSL IP changes

Run in elevated PowerShell:
```powershell
.\setup-wsl-ssh.ps1
```

## WSL RHEL Configuration

### SSHD Settings
The following settings are configured in `/etc/ssh/sshd_config.d/`:

| File | Setting | Purpose |
|------|---------|---------|
| `50-permit-root.conf` | `PermitRootLogin prohibit-password` | Allow root login with keys only |

### Restart SSHD
```bash
sudo systemctl restart sshd
```

### Check SSHD Status
```bash
sudo systemctl status sshd
ss -tlnp | grep :22
```

## Troubleshooting

### Connection Timeout
1. Check WSL IP hasn't changed: `wsl -d RHEL -- hostname -I`
2. Refresh port proxy: Run `refresh-portproxy.ps1` on Windows
3. Verify firewall rule: `Get-NetFirewallRule -DisplayName "WSL SSH*"`

### Permission Denied
1. Verify key is correct: `ssh -v -i /path/to/key root@<WINDOWS_IP>`
2. Check `PermitRootLogin` setting in WSL
3. Ensure public key is in `/root/.ssh/authorized_keys` on WSL

### WSL IP Changes
WSL2 assigns dynamic IPs. After Windows restart:
1. Run `refresh-portproxy.ps1` in elevated PowerShell
2. Or run the full `setup-wsl-ssh.ps1`

## Security Notes

- Root login is restricted to public key authentication only
- Passwords are disabled for root SSH access
- For production use, consider:
  - Creating a non-root user
  - Disabling root login entirely (`PermitRootLogin no`)
  - Using `config/sshd/60-harden.conf` template

## Network Details

| Component | IP Address | Port |
|-----------|------------|------|
| Windows Host (LAN) | <WINDOWS_IP> | 22 |
| WSL RHEL | <WSL_IP> | 22 |
| Podman container | 10.88.0.2 | - |
| Podman gateway | 10.88.0.1 | - |
