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
