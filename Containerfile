FROM registry.access.redhat.com/ubi10/ubi-init

ENV container=podman \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Disable subscription-manager managed repos (use only free UBI repos).
# When the host passes RHEL entitlements into the build, dnf would otherwise
# try to use subscription-locked rhel-10-* repos and fail with HTTP 403.
RUN subscription-manager config --rhsm.manage_repos=0 || true && \
    rm -f /etc/yum.repos.d/redhat.repo && \
    printf '[main]\nenabled=0\n' > /etc/dnf/plugins/subscription-manager.conf

# Install systemd and basic tools
RUN dnf -y install systemd hostname iproute vim nano procps-ng && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Set root password
# ⚠️  WARNING: Change this password for production use!
# The default password 'redhat' is INSECURE
RUN echo root:redhat | chpasswd

# Install developer tools and utilities
RUN dnf -y install --allowerasing \
        gcc gcc-c++ make automake autoconf \
        git curl wget sudo \
        zsh util-linux-user \
        python3 python3-pip \
        man-db \
        bind-utils net-tools \
        openssh-clients \
        tar gzip bzip2 xz unzip \
        && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Add non-root user with sudo
# ⚠️  WARNING: Change the password 'redhat' for production use!
#
# Note: This 'user' account is a fallback. The redhat-shell launcher will
# auto-provision a container user that mirrors the host's username and
# UID/GID on first launch (WSL-style), so each engineer gets their own
# matching account without rebuilding the image.
RUN useradd -m -G wheel user && \
    echo 'user:redhat' | chpasswd && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel-nopasswd && \
    chmod 0440 /etc/sudoers.d/wheel-nopasswd && \
    chsh -s /bin/bash user

# Configure locale
RUN dnf -y install glibc-langpack-en && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Create useful directories for mounted volumes (world-traversable so any
# auto-provisioned user can reach their host home under /mnt/host).
RUN mkdir -p /mnt/host && \
    chmod 0755 /mnt/host

# Set working directory
WORKDIR /home

# Allow systemd to function correctly
VOLUME [ "/sys/fs/cgroup" ]
STOPSIGNAL SIGRTMIN+3

# Boot with systemd
CMD ["/usr/lib/systemd/systemd"]