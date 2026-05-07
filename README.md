# RHEL Shell for macOS

A WSL-like experience for running a RHEL shell environment on macOS using Podman containers. This project provides a persistent, systemd-enabled **Red Hat Enterprise Linux 10 (UBI)** container that mimics the Windows Subsystem for Linux (WSL) experience — including auto-mirroring your macOS username and UID inside the container so file ownership on bind mounts just works.

## 🎯 Features

- **Systemd-enabled container** - Full systemd support for running services
- **Persistent environment** - Container persists across reboots
- **User-friendly CLI** - Simple commands to enter and manage the shell
- **macOS Application** - Double-clickable app with Red Hat icon for easy access
- **macOS volume mounting** - Access your macOS `/Users` directory from inside the container
- **Auto-mirrored host user** - Your macOS username, UID, and GID are auto-provisioned inside the container on first launch (WSL-style)
- **Non-root user** - Auto-created account with passwordless sudo (via the `wheel` group)
- **Development tools** - Pre-installed with gcc, git, python, node.js, and more
- **Multiple shell options** - bash, zsh, and fish available

## 📋 Requirements

- macOS (tested on Apple Silicon M4)
- [Podman](https://podman.io/) installed
- At least 2GB of free disk space

## 🚀 Quick Start

### 1. Install Podman (if not already installed)

```bash
brew install podman
podman machine init
podman machine start
```

### 2. Clone this project

```bash
git clone https://github.com/PabloMessier/RedHatShell.git
cd RedHatShell
```

### 3. Install the scripts

```bash
./bin/install
```

This will copy the scripts to `~/bin` and make them executable.

### 4. Add `~/bin` to your PATH (if not already)

Add this line to your `~/.zshrc`:

```bash
export PATH="$HOME/bin:$PATH"
```

Then reload:

```bash
source ~/.zshrc
```

### 5. Build the container image

```bash
build-image
```

This will build the RHEL 10 UBI image with all necessary tools.

### 6. Launch the RHEL shell

**Option A: Command line (recommended for power users)**
```bash
redhat-shell
```

**Option B: Desktop application**
```bash
./bin/create-app
```

This creates `RHEL Shell.app` with the Red Hat logo. You can:
- Double-click it to launch
- Drag it to your Applications folder
- Add it to your Dock

That's it! You're now inside a RHEL-like environment.

## 📖 Usage

### Basic Commands

#### Enter the shell as default user
```bash
redhat-shell
```

#### Enter as root
```bash
redhat-shell --root
# or
redhat-shell -r
```

#### Enter as a specific user
```bash
redhat-shell --user username
```

#### Run a single command
```bash
redhat-shell --command "ls -la /home"
# or
redhat-shell -c "dnf list installed"
```

#### Run a command as root
```bash
redhat-shell --root --command "dnf update"
```

### Container Management

#### Check container status
```bash
manage-container status
```

#### Start/stop the container
```bash
manage-container stop
manage-container start
manage-container restart
```

#### View container logs
```bash
manage-container logs
```

#### View resource usage
```bash
manage-container stats
```

#### Remove container (keeps image)
```bash
manage-container remove
```

#### Full reset (removes container and image)
```bash
manage-container reset
```

### Rebuild the image
```bash
build-image
```

### Backup and restore container
```bash
# Create a backup
manage-container backup

# Restore from backup
manage-container restore <backup-file>
```

### Run health check
```bash
./bin/health-check
# or if installed:
health-check
```

## 🔧 Using the Makefile

For convenience, you can use the Makefile for common operations:

```bash
make help          # Show available commands
make install       # Install scripts to ~/bin
make build         # Build the container image
make start         # Start the RHEL shell
make stop          # Stop the container
make restart       # Restart the container
make status        # Show container status
make logs          # View container logs
make clean         # Remove container (keeps image)
make reset         # Full reset (removes container and image)
make health-check  # Run health checks
make test          # Run validation tests
```

## 📁 Directory Structure

```
RedHatShell/
├── Containerfile              # Container image definition
├── Makefile                   # Convenience targets for common tasks
├── LICENSE                    # MIT License
├── CHANGELOG.md               # Version history
├── Red_Hat_logo.svg           # Red Hat logo for app icon
├── .config                    # Configuration file (optional)
├── .editorconfig              # Editor configuration
├── bin/
│   ├── redhat-shell           # Main shell launcher script
│   ├── build-image            # Image build script
│   ├── create-app             # macOS app bundle creator
│   ├── install                # Installation script
│   ├── manage-container       # Container management script
│   ├── health-check           # Health check and validation script
│   └── common.sh              # Shared functions and configuration
├── documentation/
│   ├── DEVELOPMENT_NOTES.md   # Development notes and setup process
│   └── hostSpecs.md           # Host system specifications
└── README.md                  # This file
```

## 🔧 Configuration

The project supports centralized configuration via the `.config` file. You can customize:

- **Container name**: `CONTAINER_NAME="redhat-shell"`
- **Default user**: `DEFAULT_USER="$USER"` (auto-detected from your macOS account)
- **Default user password**: `DEFAULT_USER_PASSWORD="redhat"`
- **Volume mounts**: `HOST_VOLUME="/Users"` and `CONTAINER_MOUNT="/mnt/host"`
- **Debug mode**: `DEBUG="false"`

To customize, create or edit `.config` in the project root:

```bash
# Example .config
CONTAINER_NAME="my-rhel-shell"
DEFAULT_USER="myuser"
DEBUG="true"
```

The image name is automatically determined based on your system architecture:
- Apple Silicon (M1/M2/M3/M4): `localhost/centos9-systemd-arm64`
- Intel Macs: `localhost/centos9-systemd-amd64`

### Default user (WSL-style auto-provisioning)

By default, `redhat-shell` mirrors your macOS account inside the container:

- The username defaults to `$(id -un)` on the host.
- On first launch, a matching account is created inside the container with the same UID/GID, added to the `wheel` group, and granted passwordless `sudo`.
- Because UIDs match, files in `/mnt/host` keep correct ownership and permissions — no `chown` gymnastics.

To override, set `DEFAULT_USER` in `.config` or pass `--user <name>` on the command line.

## 🛠️ Inside the Container

### Default credentials

> ⚠️ **SECURITY WARNING**: The default passwords are set to `redhat` for demonstration purposes.
> **You MUST change these passwords** if you're using this in any production or sensitive environment!

- **Your user** (auto-created, name = your macOS username): password `redhat`
- **Root**: `root` (password: `redhat`)

**To change passwords:**
```bash
# Change your user password
redhat-shell
passwd

# Change root password
sudo passwd root
```

### Accessing macOS files

Your macOS `/Users` directory is mounted at `/mnt/host`:

```bash
cd /mnt/host/yourusername/Documents
```

### Installed tools

The container comes with:
- **Build tools**: gcc, g++, make, cmake
- **Version control**: git
- **Languages**: Python 3, Node.js
- **Editors**: vim, nano
- **Shells**: bash, zsh, fish
- **Utilities**: curl, wget, htop, tree, ncdu
- **Network tools**: dig, netstat, ssh client

### Running services

Since systemd is enabled, you can run services normally:

```bash
sudo systemctl start httpd
sudo systemctl enable --now postgresql
```

### Installing additional software

```bash
sudo dnf install package-name
```

## 🎨 Tips & Tricks

### Create an alias

Add to your `~/.zshrc`:
```bash
alias rhel='redhat-shell'
alias rhel-root='redhat-shell --root'
```

### Auto-start container on boot

```bash
podman generate systemd --name redhat-shell --files --restart-policy=always
```

### Customize your container

Edit the `Containerfile` to add more packages or configuration, then rebuild:
```bash
build-image
manage-container reset  # Remove old container
redhat-shell            # Create new container with updated image
```

## 🐛 Troubleshooting

### Container won't start
```bash
manage-container logs
```

### Image build fails
Make sure Podman is running:
```bash
podman machine start
```

### Can't access files in /mnt/host
Check that the volume is mounted:
```bash
podman inspect redhat-shell | grep Mounts -A 10
```

### Permission issues
Inside the container, files from macOS may have different ownership. Use `sudo` when needed.

## 🆚 WSL Comparison

| Feature | WSL | RHEL Shell (this) |
|---------|-----|-------------------|
| Platform | Windows | macOS |
| Backend | Hyper-V | Podman |
| Systemd | ✅ | ✅ |
| File access | `/mnt/c` | `/mnt/host` |
| GUI apps | ✅ (WSLg) | ❌ |
| Performance | Native-like | Container overhead |

## 📝 License

This project is free to use and modify.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📚 References

- [Podman Documentation](https://docs.podman.io/)
- [CentOS Stream](https://www.centos.org/centos-stream/)
- [Systemd in containers](https://systemd.io/CONTAINER_INTERFACE/)
