#!/bin/bash -ex

ROOTFS="$1"
CHROOT_DIR="/mnt/chroot"

if [ -z "$ROOTFS" ]; then
  echo "Usage: $0 <rootfs_file> [cleanup]"
  exit 1
fi

# Cleanup loop devices
cleanup_loop_devices() {
    local img_file="$1"
    # Get absolute path of image file
    img_file=$(realpath "$img_file")
    # Find and cleanup all matching loop devices
    losetup -a | grep "$img_file" | cut -d: -f1 | while read -r loop_dev; do
        echo "Detaching loop device: $loop_dev"
        losetup -d "$loop_dev" 2>/dev/null || echo "Failed to detach $loop_dev"
    done
}

# Update cleanup function
cleanup() {
    echo "Cleaning up $CHROOT_DIR..."
    
    # Unmount first
    echo "Unmounting $CHROOT_DIR..."
    umount "$CHROOT_DIR" 2>/dev/null || echo "Unmount failed."
    
    # Cleanup all related loop devices
    cleanup_loop_devices "$ROOTFS"
    
    # Remove mount directory
    echo "Removing $CHROOT_DIR..."
    rm -rf "$CHROOT_DIR"
    echo "Cleanup completed."
}

# 创建挂载目录
mkdir -p "$CHROOT_DIR"

case "$2" in
cleanup)
  cleanup
  exit 0
  ;;
*) ;;
esac

# 根据文件类型选择处理方式
case "$ROOTFS" in
  *.img)
    echo "Mounting IMG file..."
    # 使用 losetup 创建循环设备并获取设备名
    LOOP_DEV=$(losetup -f --show "$ROOTFS")
    echo "Loop device created: $LOOP_DEV"

    # 检查是否成功创建了 loop 设备
    if [ -z "$LOOP_DEV" ]; then
      echo "Error: Failed to create loop device."
      exit 1
    fi
    
    # 尝试挂载映像文件
    echo "Mounting $LOOP_DEV to $CHROOT_DIR..."
    mount -t ext4 "$LOOP_DEV" "$CHROOT_DIR" || {
      echo "Failed to mount $ROOTFS"
      exit 1
    }
    ;;
*.tar | *.tar.gz | *.tar.xz)
    echo "Extracting TAR file..."
    tar -xf "$ROOTFS" -C "$CHROOT_DIR" || {
      echo "Failed to extract $ROOTFS"
      exit 1
    }
    ;;
*.squashfs)
    echo "Mounting SquashFS file..."
    mount -t squashfs -o loop "$ROOTFS" "$CHROOT_DIR" || {
      echo "Failed to mount $ROOTFS"
      exit 1
    }
    ;;
*.ext4)
    echo "Mounting EXT4 file..."
    mount -o loop "$ROOTFS" "$CHROOT_DIR" || {
      echo "Failed to mount $ROOTFS"
      exit 1
    }
    ;;
*.cpio | *.cpio.gz)
    echo "Extracting CPIO file..."
    cd "$CHROOT_DIR" || exit 1
    cpio -idv <"$ROOTFS"
    ;;
*.iso)
  echo "Mounting ISO file..."
  mount -o loop "$ROOTFS" "$CHROOT_DIR" || {
    echo "Failed to mount $ROOTFS"
    exit 1
  }
  ;;
*)
  echo "Unsupported rootfs format: $ROOTFS"
  exit 1
  ;;
esac

echo "Root filesystem ready at $CHROOT_DIR"
