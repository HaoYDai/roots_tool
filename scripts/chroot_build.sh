#!/bin/bash

ROOTFS="$1"
CODE_DIR="$2"
CHROOT_DIR="/mnt/chroot"
SCRIPTS_PATCH="scripts"

if [ -z "$ROOTFS" ] || [ -z "$CODE_DIR" ]; then
  echo "Usage: $0 <rootfs_file> <code_directory>"
  exit 1
fi

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

bash $SCRIPTS_PATCH/setup_chroot_build_env.sh

# 同步代码目录
bash $SCRIPTS_PATCH/rsync_chroot_code.sh "$CODE_DIR" to_chroot

# 编译代码
bash $SCRIPTS_PATCH/build_in_chroot.sh "$CODE_DIR"

# 同步代码目录
bash $SCRIPTS_PATCH/rsync_chroot_code.sh "$CODE_DIR" from_chroot

# 卸载文件系统
bash $SCRIPTS_PATCH/mount_chroot_fs.sh umount

# 卸载根文件系统
bash $SCRIPTS_PATCH/mount_rootfs.sh "$ROOTFS" cleanup
