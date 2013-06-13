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
CURRENT_DIR=$(cd -P $(dirname $0); pwd)
echo "CURRENT_DIR=${CURRENT_DIR}"

IMAGE="rpi-image.img"
WGET="wget -c"
MIRRORBASE="http://distfiles.gentoo.org/releases/amd64/autobuilds/"

# Download the latest minimal install iso.
# It's tiny, and boots into a gentoo environment.
if [ ! -e latest-iso.txt ]; then
    $WGET "${MIRRORBASE}latest-iso.txt" -O "${CURRENT_DIR}/latest-iso.txt"
    $WGET "${MIRRORBASE}$(grep iso ${CURRENT_DIR}/latest-iso.txt)" \
        -O "${CURRENT_DIR}/x86_64-extras/install-amd64-minimal.iso"
fi

# Get memtest, memdisk from host filesystem, not a download.
# Needs sys-boot/syslinux.
test ! -e ${CURRENT_DIR}/x86_64-extras/memdisk && {
  test -e /usr/share/syslinux/memdisk && {
    cp /usr/share/syslinux/memdisk ${CURRENT_DIR}/x86_64-extras/memdisk
  } || {
    echo "Syslinux is not installed"
    exit 1
  }
}

echo "Loop setup. (requires sudo)"
echo "Hit enter to continue";read
LOOPDEV="$(sudo losetup --show -f $IMAGE)"
echo "Loop device on $LOOPDEV"
echo "Reading partitions"
sudo kpartx -a $LOOPDEV
sudo kpartx -l $LOOPDEV;
DEVMAP=/dev/mapper/$(echo "$LOOPDEV"|cut -d '/' -f 3)
echo "Creating rootfs mountpoint"
sudo mkdir -p /mnt/rpi-root
echo "Mounting rootfs"
sudo mount ${DEVMAP}p2 /mnt/rpi-root
echo "Creating bootfs mountpoint"
sudo mkdir -p /mnt/rpi-root/boot
echo "Mounting bootfs"
sudo mount ${DEVMAP}p1 /mnt/rpi-root/boot
echo "done. Next-up: Install extras.";read
echo "Installing x86_64-extras"
for f in $(ls "${CURRENT_DIR}/x86_64-extras"); do
    # Should '-r' be included?
    sudo cp -v "${CURRENT_DIR}/x86_64-extras/$f" /mnt/rpi-root/boot/
done
echo "done. Next-up: Syslinux.";read
echo "Installing syslinux"
sudo dd if=/usr/share/syslinux/mbr.bin of="${DEVMAP}"
sudo syslinux --install "${DEVMAP}p1"
echo "done. Next-up: Unmount and cleanup.";read
echo "Unmounting bootfs and rootfs"
sudo umount ${DEVMAP}p1 ${DEVMAP}p2
echo "Removing mountpoint"
sudo rm -rf /mnt/rpi-root
echo "Clearing partition map"
sudo kpartx -d $LOOPDEV
echo "Removing loop device"
sudo losetup -d $LOOPDEV
echo "done. Final step: Compress."; read
echo "Compressing image"
gzip -c $IMAGE | pipebench > ${IMAGE}.gz


