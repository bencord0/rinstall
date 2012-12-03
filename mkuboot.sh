#!/bin/bash
CURRENT_DIR=$(cd -P $(dirname $0); pwd)
PARALLEL=$(grep processor /proc/cpuinfo | wc -l)
MAKEOPTS="ARCH=arm "

# Follow instructions from http://kernelnomicon.org/?p=92 and http://kernelnomicon.org/?p=127
MAKEOPTS+="CROSS_COMPILE=${CURRENT_DIR}/compiler/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi- "
MAKEOPTS+="-j${PARALLEL}"

# U-Boot stuff
# Assume github://gonzoua/u-boot-pi (rpi branch) under ./u-boot
pushd "${CURRENT_DIR}"/u-boot
make ${MAKEOPTS} rpi_b_config
make ${MAKEOPTS}
popd

# Distill the bootloader
pushd "${CURRENT_DIR}"
cp u-boot/u-boot.bin ./u-boot.bin
popd

echo "Your fresh bootloader is ready"
md5sum "${CURRENT_DIR}"/u-boot.bin
