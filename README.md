# RHEL Shell for macOS

A WSL-like experience for running a RHEL-based shell environment on macOS using Podman containers. This project provides a persistent, systemd-enabled CentOS Stream 9 container that mimics the Windows Subsystem for Linux (WSL) experience.

## 🎯 Features

- **Systemd-enabled container** - Full systemd support for running services
- **Persistent environment** - Container persists across reboots
- **User-friendly CLI** - Simple commands to enter and manage the shell
- **macOS volume mounting** - Access your macOS `/Users` directory from inside the container
- **Non-root user** - Default user `pablo` with full sudo access
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

### 2. Clone or download this project

```bash
cd ~/Desktop/MyFiles/RedHatShell
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

This will build the CentOS Stream 9 image with all necessary tools.

### 6. Launch the RHEL shell

```bash
redhat-shell
```

That's it! You're now inside a RHEL-like environment.

## 📖 Usage

### Basic Commands

#### Enter the shell as default user (pablo)
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

## 📁 Directory Structure

```
RedHatShell/
├── Containerfile          # Container image definition
├── bin/
│   ├── redhat-shell       # Main shell launcher script
│   ├── build-image        # Image build script
│   ├── install            # Installation script
│   └── manage-container   # Container management script
├── documentation/
│   ├── steps.md           # Setup documentation
│   └── hostSpecs.md       # Host system specifications
└── README.md              # This file
```

## 🔧 Configuration

You can modify these settings in the scripts:

- **Container name**: `redhat-shell` (in `bin/redhat-shell`)
- **Image name**: `localhost/centos9-systemd-arm64` (in `bin/redhat-shell` and `bin/build-image`)
- **Default user**: `pablo` (in `bin/redhat-shell` and `Containerfile`)
- **Volume mount**: `/Users` → `/mnt/host` (in `bin/redhat-shell`)

### Changing the default user

Edit `bin/redhat-shell` and change:
```bash
DEFAULT_USER="pablo"
```

Or create a different user in the `Containerfile`.

## 🛠️ Inside the Container

### Default credentials

> ⚠️ **SECURITY WARNING**: The default passwords are set to `redhat` for demonstration purposes.
> **You MUST change these passwords** if you're using this in any production or sensitive environment!

- **User**: `pablo` (password: `redhat`)
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
