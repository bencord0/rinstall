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
STAGE="stage4-rpi.tar.gz"
IMAGE="rpi-image.img"
MODULES="modules.zip"

# Silence, or non-interactivity mode can be enbled by
# exporting SILENT or invoking the '--silent' flag.
if [ "_$1" = "_--silent" ]; then
  SILENT=1
fi

waitforuser () {
    if [ ! -n "$SILENT" ]; then
        echo "Press ENTER to continue...";
        read
    fi
}

# If pipebench is not installed, fake it with cat
which pipebench > /dev/null || alias pipebench=cat

rm ${IMAGE}
echo "Zeroing image of 3G"
dd if=/dev/zero | pipebench | dd iflag=fullblock of=$IMAGE bs=1M count=3072
echo "done. Next-up: Loop setup and partitioning. (requires sudo)"
waitforuser
echo "Partitioning..."
sudo fdisk $IMAGE << EOF
n
p
1

+500M
t
c
a
1
n
p
2


w
EOF
sudo fdisk -l $IMAGE
echo "Reading partitions"
sudo kpartx -a $LOOPDEV
sudo kpartx -l $LOOPDEV;
echo "Creating filesystems"
DEVMAP=/dev/mapper/$(echo "$LOOPDEV"|cut -d '/' -f 3)
sudo mkfs.vfat "${DEVMAP}p1"
sudo mkfs.ext4 "${DEVMAP}p2"
echo "done. Next-up: Mounting filesystems."
waitforuser
echo "Creating rootfs mountpoint"
sudo mkdir -p /mnt/rpi-root
echo "Mounting rootfs"
sudo mount ${DEVMAP}p2 /mnt/rpi-root
echo "Creating bootfs mountpoint"
sudo mkdir /mnt/rpi-root/boot
echo "Mounting bootfs"
sudo mount ${DEVMAP}p1 /mnt/rpi-root/boot
echo "Installing..."
sudo tar xavpf $STAGE -C /mnt/rpi-root
echo "done. Next-up: Kernel and modules."
waitforuser
echo "Adding Kernel, modules and other bootfiles"
#sudo unzip $MODULES -d /mnt/rpi-root
sudo cp -v ./kernel.img ./modules.zip /mnt/rpi-root/boot
sudo cp -v ./bootcode.bin start.elf /mnt/rpi-root/boot
[ -e ./cmdline.txt ] && sudo cp -v ./cmdline.txt /mnt/rpi-root/boot
sudo mkdir -p /mnt/rpi-root/boot/config
echo "Adding squash portage"
sudo cp -v ./portage.squashfs /mnt/rpi-root/usr/portage
echo "done. Next-up: Unmount and cleanup."
waitforuser
echo "Unmounting bootfs and rootfs"
sudo umount ${DEVMAP}p1 ${DEVMAP}p2
echo "Removing mountpoint"
sudo rm -rf /mnt/rpi-root
echo "Clearing partition map"
sudo kpartx -d $LOOPDEV
echo "Removing loop device"
sudo losetup -d $LOOPDEV
