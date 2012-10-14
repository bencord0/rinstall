rinstall
========

Description
-----------
A tool for generating Raspberry Pi images.

This scripts in this repository take a stage4 tarball to create a raw SDCard image to boot a [Raspberry Pi](http://www.raspberrypi.org).

Dependencies
------------

    * app-arch/tar        (s)
    * app-arch/gzip       (s)
    * net-misc/wget       (s)
    * sys-apps/coreutils  (s)
    * sys-apps/util-linux (s)
    * sys-devel/make      (s)
    * sys-fs/e2fsprogs    (s)
    * app-admin/sudo
    * app-arch/zip
    * app-benchmarks/pipebench [Not strictly required, but nice to have]
    * dev-lang/python
    * dev-vcs/git
    * sys-fs/multipath-tools
    * sys-fs/dosfstools

(s) Typically found in @system

How to use
----------
First, clone this repository. The scripts were designed to run on a [Gentoo](http://www.gentoo.org) AMD64 system. This has consequences on the compiler toolchain used and the assumptions about system dependencies.

If you have your own raspberry pi kernel source tree, add (or symlink it) under ./linux.
If you have your own cross-compiler, add/symlink it to ./compiler.
(Paths are relative to the root of this source tree)

Run the ./configure script. This is not like a typical GNU Autotools configure script, please don't treat it as such.
The configure script will download the Raspberry Pi firmware, and if you haven't specified a kernel and compiler, will download those too.
Read the script for more information.

If you are using your own kernel tree, configure it now. The ./configure script will use the bcmrpi_defconfig.

Run the ./mkkernel.sh script. This will compile the kernel under ./linux with the cross-compiler in ./compiler.
Then it will install any modules (and firmware) to ./modules and zip them up.
Finally it will shim the fresh kernel and output ./kernel.img and md5sum it.

Run the ./mkimage.sh script. This will create a raw disk image (rpi-image.img) loop mount, partition and apply some filesystems.
The script will pause at strategic points in the script, so that you can check that nothing too stupid is happening. Read the script for what it is doing. Root access is required for the loop mount, and any operations occuring in it. If fuse/fakeroot can be used to get the same effect, that would be nice.

The mkimage.sh script will then extract the stage tarball. Feel free to use your own stage tarball. See the [Gentoo Wiki](http://wiki.gentoo.org/wiki/Raspberry_Pi) for more information about stage tarballs. Note: the configure script will automatically download one.

The kernel and modules built with the ./mkkernel.sh script will then be installed.

The script will clean up, unmounting the loop device and compress the resulting image.

Upload [rpi-image.img.gz](http://dl.condi.me/rinstall/rpi-image.img.gz) to any mirrors for distribution.
Install rpi-image.img to an SDCard with dd, or [Win32DiskImager](https://launchpad.net/win32-image-writer).

Notes
-----

The creation of a [stage4 tarball](http://dl.condi.me/rinstall/stage4-rpi.tar.gz) is out of scope of this tool.

It would be nice to upload the rpi-image.img.gz to a Raspberry Pi directly to perform an in-place upgrade.


On Optional Dependencies
---------------------
The ./mkinstall.sh script uses sudo and is the only phase that requires root privilages. In general, it is a bad idea to compile with root privilages.
If you don't use sudo (or have it installed) on your system, edit the script and run as root.

The pipebench optional dependency can be disabled, just remove it between the pipes.
