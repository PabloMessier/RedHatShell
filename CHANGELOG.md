# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-04

### Added
- Initial release of RHEL Shell for macOS
- WSL-like experience using Podman containers
- Systemd-enabled CentOS Stream 9 container
- Persistent container environment across reboots
- User-friendly CLI scripts (`redhat-shell`, `build-image`, `manage-container`)
- macOS volume mounting (`/Users` → `/mnt/host`)
- Pre-installed development tools (gcc, git, python, node.js)
- Multiple shell options (bash, zsh, fish)
- Architecture auto-detection (ARM64/AMD64)
- Podman machine validation
- Centralized configuration system (`.config` file)
- Comprehensive documentation

### Changed
- Refactored all scripts to use shared `common.sh` library
- Improved error handling and validation
- Enhanced security warnings for default passwords

### Fixed
- Fixed file permissions for all bin scripts
- Fixed hardcoded ARM64 architecture (now auto-detects)
- Fixed missing Podman machine validation

## [Unreleased]

### Planned
- Container backup/export functionality
- Health check script
- Shell completions (bash/zsh)
- Makefile for common operations
- Enhanced networking documentation
