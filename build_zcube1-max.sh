#!/bin/bash

./compile.sh docker BOARD=zcube1-max BRANCH=current RELEASE=bullseye BUILD_MINIMAL=no BUILD_DESKTOP=no KERNEL_ONLY=no KERNEL_CONFIGURE=no COMPRESS_OUTPUTIMAGE=sha,gz BOOT_LOGO=no
