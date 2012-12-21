#!/bin/sh
if [ `whoami` != root ]; then
    echo "$0 is supposed to be run by root (to do debootstrap and chroot)"
    exit 1
fi
if [ -e "_image" ]; then
    echo "_image aleardy exists. Delete it and run $0 again."
    exit 1
fi

if ! which mksquashfs; then
    echo "mksquashfs is not installed. Install it."
    exit 1
fi

MIRROR=http://ftp.task.gda.pl/debian
APT_GET="aufs-tools squashfs-tools python2.7 less parted hdparm"

debootstrap --include ssh --arch=i386 testing _image $MIRROR || exit 1

mount --bind /proc _image/proc || exit 1
mount --bind /sys _image/sys || exit 1
mount --bind /dev/pts _image/dev/pts || exit 1
chroot _image apt-get update || exit 1
chroot _image apt-get install -y $APT_GET || exit 1
chroot _image apt-get clean || exit 1
umount _image/proc
umount _image/sys
umount _image/dev/pts
mksquashfs _image _image.sfs || exit 1
