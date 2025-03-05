#!/bin/bash

ROOTFS="$1"
CMD="$2"
CHROOT_DIR="/mnt/chroot"
SCRIPTS_PATCH="scripts"

# if [ -z "$ROOTFS" ] || [ -z "$CODE_DIR" ]; then
#   echo "Usage: $0 <rootfs_file> <code_directory>"
#   exit 1
# fi

case "$CMD" in
  "chroot")
    # 挂载根文件系统
    bash $SCRIPTS_PATCH/mount_rootfs.sh "$ROOTFS" || {
      echo "Failed to prepare rootfs"
      exit 1
    }
    # 挂载必要的文件系统
    bash $SCRIPTS_PATCH/mount_chroot_fs.sh mount || {
      echo "Failed to mount chroot fs"
      bash $SCRIPTS_PATCH/mount_rootfs.sh "$ROOTFS" cleanup
      exit 1
    }
    # cp -rf /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"
    chroot "$CHROOT_DIR" /bin/bash
    exit 0
    ;;
  "cleanup")
    bash $SCRIPTS_PATCH/mount_chroot_fs.sh umount
    bash $SCRIPTS_PATCH/mount_rootfs.sh "$ROOTFS" cleanup
    exit 0
    ;;
esac
