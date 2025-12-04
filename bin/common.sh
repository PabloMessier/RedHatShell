#!/bin/bash

# Common library for RHEL Shell scripts
# Source this file in other scripts: source "$(dirname "$0")/common.sh"

# ============================================================================
# Configuration
# ============================================================================

# Default configuration values
CONTAINER_NAME="redhat-shell"
HOST_VOLUME="/Users"
CONTAINER_MOUNT="/mnt/host"
DEFAULT_USER="pablo"
DEBUG="${DEBUG:-false}"

# Load user configuration if available
CONFIG_FILE="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/.config"
if [ -f "$CONFIG_FILE" ]; then
    # Source the config file to override defaults
    source "$CONFIG_FILE"
fi

# Detect architecture and set image name accordingly
ARCH=$(uname -m)
case "$ARCH" in
    arm64|aarch64)
        PLATFORM="linux/arm64"
        ARCH_SUFFIX="arm64"
        ;;
    x86_64|amd64)
        PLATFORM="linux/amd64"
        ARCH_SUFFIX="amd64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

IMAGE_NAME="localhost/centos9-systemd-${ARCH_SUFFIX}"

# ============================================================================
# Color Codes
# ============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Output Functions
# ============================================================================

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_debug() {
    if [ "${DEBUG:-false}" = "true" ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# ============================================================================
# Validation Functions
# ============================================================================

# Check if podman is installed
check_podman_installed() {
    if ! command -v podman &> /dev/null; then
        print_error "Podman is not installed!"
        print_info "Install it using: brew install podman"
        return 1
    fi
    return 0
}

# Check if podman machine is initialized and running
check_podman_machine() {
    print_debug "Checking Podman machine status..."
    
    if ! check_podman_installed; then
        return 1
    fi
    
    # Check if any machine exists
    if ! podman machine list --format "{{.Name}}" 2>/dev/null | grep -q .; then
        print_error "No Podman machine found!"
        print_info "Initialize one using:"
        echo "    podman machine init"
        echo "    podman machine start"
        return 1
    fi
    
    # Check if a machine is running
    if ! podman machine list --format "{{.Running}}" 2>/dev/null | grep -q "true"; then
        print_error "Podman machine is not running!"
        print_info "Start it using: podman machine start"
        return 1
    fi
    
    print_debug "Podman machine is running"
    return 0
}

# Check if image exists
check_image_exists() {
    local image="${1:-$IMAGE_NAME}"
    if podman image exists "$image" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if container exists
check_container_exists() {
    local container="${1:-$CONTAINER_NAME}"
    if podman container exists "$container" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if container is running
check_container_running() {
    local container="${1:-$CONTAINER_NAME}"
    if check_container_exists "$container"; then
        if [ "$(podman inspect -f '{{.State.Running}}' "$container" 2>/dev/null)" = "true" ]; then
            return 0
        fi
    fi
    return 1
}

# ============================================================================
# Utility Functions
# ============================================================================

# Get the project root directory
get_project_root() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(dirname "$script_dir")"
}

# Show version info
show_version() {
    echo "RHEL Shell for macOS"
    echo "Version: 1.0.0"
    echo "Architecture: $ARCH ($ARCH_SUFFIX)"
    echo "Platform: $PLATFORM"
}
