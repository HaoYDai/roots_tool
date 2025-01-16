#!/bin/bash -e

CHROOT_DIR="/mnt/chroot"

echo "Setting up chroot environment..."
cp -rf /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"

chroot "$CHROOT_DIR" /bin/bash -c "
    resize2fs /dev/loop0
    apt clean
    rm -rf /var/cache/apt/archives
    mkdir -p /var/cache/apt/archives/partial
    chmod 755 /var/cache/apt/archives
    apt update
    apt --fix-broken install -y build-essential cmake gcc g++ git python3 python3-pip"