#!/bin/bash
#
# Copyright 2013 Ben Cordero
#
# This file is part of rinstall.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
set -e

CURRENT_DIR=$(cd -P $(dirname $0); pwd)
PARALLEL=$(grep processor /proc/cpuinfo | wc -l)
MAKEOPTS="ARCH=arm "

# Assume compiler from ftp://ftp.kernel.org/pub/tools/crosstool/index.html
MAKEOPTS+="CROSS_COMPILE=${CURRENT_DIR}/compiler/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi- "
MAKEOPTS+="-j${PARALLEL}"

# Kernel stuff
# Assume github://raspberrypi/linux (or symlink) under ./linux
pushd "${CURRENT_DIR}"/linux
yes ""|make ${MAKEOPTS} oldconfig
make ${MAKEOPTS}
popd

# RaspberryPi-ify Kernel
rm -f "${CURRENT_DIR}"/kernel.img
pushd "${CURRENT_DIR}"
python2 imagetool-uncompressed.py linux/arch/arm/boot/Image
popd

if [ -e "${CURRENT_DIR}"/kernel.img ]; then
    echo "Your fresh kernel.img is ready"
    md5sum "${CURRENT_DIR}"/kernel.img
else
    echo "Kernel build failed"
    exit 1
fi

