#!/bin/bash
CURRENT_DIR=$(cd -P $(dirname $0); pwd)
pushd $CURRENT_DIR

wget https://github.com/raspberrypi/firmware/raw/master/boot/bootcode.bin
wget https://github.com/raspberrypi/firmware/raw/master/boot/arm240_start.elf -O start.elf
wget https://github.com/raspberrypi/tools/raw/master/mkimage/args-uncompressed.txt
wget https://github.com/raspberrypi/tools/raw/master/mkimage/boot-uncompressed.txt
wget https://github.com/raspberrypi/tools/raw/master/mkimage/imagetool-uncompressed.py

popd
