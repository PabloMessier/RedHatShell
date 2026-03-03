FROM registry.access.redhat.com/ubi9/ubi-init

ENV container=podman \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

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
RUN useradd -m -G wheel user && \
    echo 'user:redhat' | chpasswd && \
    echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    chsh -s /bin/bash user

# Configure locale
RUN dnf -y install glibc-langpack-en && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Create useful directories for mounted volumes
RUN mkdir -p /mnt/host && \
    chown user:user /mnt/host

# Set working directory
WORKDIR /home/user

# Allow systemd to function correctly
VOLUME [ "/sys/fs/cgroup" ]
STOPSIGNAL SIGRTMIN+3

# Boot with systemd
CMD ["/usr/lib/systemd/systemd"]