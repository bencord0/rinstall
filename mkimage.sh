#!/bin/bash
STAGE="stage4-rpi.tar.gz"
IMAGE="rpi-image.img"
MODULES="modules.zip"

rm ${IMAGE}
echo "Zeroing image of 3G"
dd if=/dev/zero | pipebench | dd iflag=fullblock of=$IMAGE bs=1M count=3072
echo "done. Next-up: Loop setup and partitioning. (requires sudo)"
echo "Press ENTER to continue...";read
LOOPDEV="$(sudo losetup --show -f $IMAGE)"
echo "Loop device on $LOOPDEV"
echo "Partitioning..."
sudo fdisk $LOOPDEV << EOF
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
sudo fdisk -l $LOOPDEV
echo "Reading partitions"
sudo kpartx -a $LOOPDEV
sudo kpartx -l $LOOPDEV;
echo "Creating filesystems"
DEVMAP=/dev/mapper/$(echo "$LOOPDEV"|cut -d '/' -f 3)
sudo mkfs.vfat "${DEVMAP}p1"
sudo mkfs.ext4 "${DEVMAP}p2"
echo "done. Next-up: Mounting filesystems."
echo "Press ENTER to continue...";read
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
echo "Press ENTER to continue...";read
echo "Adding Kernel, modules and other bootfiles"
sudo unzip $MODULES -d /mnt/rpi-root
sudo cp -v ./kernel.img ./modules.zip /mnt/rpi-root/boot
sudo cp -v ./bootcode.bin start.elf /mnt/rpi-root/boot
[ -e ./cmdline.txt ] && sudo cp -v ./cmdline.txt /mnt/rpi-root/boot
sudo mkdir -p /mnt/rpi-root/boot/config
echo "Adding squash portage"
sudo cp -v ./portage.squashfs /mnt/rpi-root/usr/portage
echo "done. Next-up: Unmount and cleanup."
echo "Press ENTER to continue...";read
echo "Unmounting bootfs and rootfs"
sudo umount ${DEVMAP}p1 ${DEVMAP}p2
echo "Removing mountpoint"
sudo rm -rf /mnt/rpi-root
echo "Clearing partition map"
sudo kpartx -d $LOOPDEV
echo "Removing loop device"
sudo losetup -d $LOOPDEV
