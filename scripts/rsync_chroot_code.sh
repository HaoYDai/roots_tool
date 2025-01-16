#!/bin/bash

CHROOT_DIR="/mnt/chroot"

BUILD_PATH="build/"

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <host_code_path> <direction>"
  echo "Direction: to_chroot | from_chroot"
  exit 1
fi

HOST_CODE_PATH="$1"
CHROOT_CODE_PATH=/ws_code
DIRECTION="$2"

# 检查宿主机代码路径是否存在
if [ ! -d "$HOST_CODE_PATH" ]; then
  echo "Host code path not found: $HOST_CODE_PATH"
  exit 1
fi

mkdir -p "$CHROOT_DIR$CHROOT_CODE_PATH"

case "$DIRECTION" in
to_chroot)
  echo "Syncing $HOST_CODE_PATH to $CHROOT_DIR$CHROOT_CODE_PATH..."
  rsync -av --delete --exclude $BUILD_PATH "$HOST_CODE_PATH/" "$CHROOT_DIR$CHROOT_CODE_PATH/"
  ;;
from_chroot)
  echo "Syncing $CHROOT_DIR$CHROOT_CODE_PATH to $HOST_CODE_PATH..."
  rsync -av --delete --include $BUILD_PATH "$CHROOT_DIR$CHROOT_CODE_PATH/" "$HOST_CODE_PATH/"
  ;;
*)
  echo "Invalid direction: $DIRECTION"
  exit 1
  ;;
esac