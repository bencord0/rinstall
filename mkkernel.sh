#!/bin/bash
CURRENT_DIR=$(cd -P $(dirname $0); pwd)
PARALLEL=$(grep processor /proc/cpuinfo | wc -l)
MAKEOPTS="ARCH=arm "

# Assume compiler from ftp://ftp.kernel.org/pub/tools/crosstool/index.html
MAKEOPTS+="CROSS_COMPILE=${CURRENT_DIR}/../gcc-4.6.3-nolibc/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi- "
MAKEOPTS+="-j${PARALLEL}"

# Kernel stuff
# Assume github://raspberrypi/linux (or symplink) under ./linux
pushd "${CURRENT_DIR}"/linux
make ${MAKEOPTS} menuconfig
make ${MAKEOPTS}
test "_$1" = "_-m" && $make ${MAKEOPTS} modules_install INSTALL_MOD_PATH="${CURRENT_DIR}"
popd

# Zip the modules
test "_$1" = "_-m" && {
    pushd "${CURRENT_DIR}"
    rm lib/modules/*/{build,source}
    zip -ru modules.zip lib
    popd
}

# RaspberryPi-ify Kernel
pushd "${CURRENT_DIR}"
python imagetool-uncompressed.py linux/arch/arm/boot/Image
popd

echo "Your fresh kernel.img is ready"
md5sum "${CURRENT_DIR}"/kernel.img
