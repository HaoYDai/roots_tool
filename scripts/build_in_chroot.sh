#!/bin/bash

CHROOT_DIR="/mnt/chroot"

CHROOT_CODE_PATH=/ws_code

# 检查代码目录是否挂载到 chroot 环境
if [ ! -d "$CHROOT_DIR$CHROOT_CODE_PATH" ]; then
  echo "Error: Code directory '$CHROOT_DIR$CHROOT_CODE_PATH' is not mounted in chroot!"
  exit 1
fi

# 在 chroot 环境中编译代码
chroot "$CHROOT_DIR" /bin/bash -c "
    detect_and_build() {
        CHROOT_CODE_PATH=\"\$1\"

        if [ -f \"\$CHROOT_CODE_PATH/Makefile\" ]; then
            echo \"Detected Makefile in \$CHROOT_CODE_PATH. Using make...\"
            make -C \"\$CHROOT_CODE_PATH\"

        elif [ -f \"\$CHROOT_CODE_PATH/CMakeLists.txt\" ]; then
            echo \"Detected CMakeLists.txt in \$CHROOT_CODE_PATH. Using cmake...\"
            mkdir -p \"\$CHROOT_CODE_PATH/build\"
            cd \"\$CHROOT_CODE_PATH/build\" && cmake .. && make

        elif [ -f \"\$CHROOT_CODE_PATH/build.sh\" ]; then
            echo \"Detected build.sh in \$CHROOT_CODE_PATH. Using custom script...\"
            bash \"\$CHROOT_CODE_PATH/build.sh\"

        else
            echo \"No known build system found in \$CHROOT_CODE_PATH. Skipping...\"
            return 1
        fi
    }

    detect_and_build \"$CHROOT_CODE_PATH\"
"
