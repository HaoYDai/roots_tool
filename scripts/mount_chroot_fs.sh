#!/bin/bash

CHROOT_DIR="/mnt/chroot"

mount_fs() {
  echo "Mounting necessary file systems for chroot..."
  mount -t proc /proc "$CHROOT_DIR/proc"
  mount -t sysfs /sys "$CHROOT_DIR/sys"
  mount -o bind /dev "$CHROOT_DIR/dev"
  mount -o bind /dev/pts "$CHROOT_DIR/dev/pts"
  echo "File systems mounted."
}

umount_fs() {
  echo "Unmounting file systems for chroot..."
  umount "$CHROOT_DIR/proc"
  umount "$CHROOT_DIR/sys"
  umount "$CHROOT_DIR/dev/pts"
  umount "$CHROOT_DIR/dev"
  echo "File systems unmounted."
}

case "$1" in
mount)
  mount_fs
  ;;
umount)
  umount_fs
  ;;
*)
  echo "Usage: $0 {mount|umount}"
  exit 1
  ;;
esac
