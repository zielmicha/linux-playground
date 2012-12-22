#!/bin/sh
ROOT=$(dirname $0)/..
. $ROOT/vars.inc

cd $DATA/gen

if [ `whoami` != root ]; then
    echo "$0 is supposed to be run by root (to do debootstrap and chroot)"
    exit 1
fi
if [ -e "image" ]; then
    echo "$DATA/gen/image aleardy exists. Delete it and run $0 again."
    exit 1
fi

if ! which mksquashfs; then
    echo "mksquashfs is not installed. Install it."
    exit 1
fi

MIRROR=http://ftp.task.gda.pl/debian
APT_GET="aufs-tools squashfs-tools python2.7 less parted hdparm busybox"

debootstrap --include ssh --arch=i386 testing image $MIRROR || exit 1

mount --bind /proc image/proc || exit 1
mount --bind /sys image/sys || exit 1
mount --bind /dev/pts image/dev/pts || exit 1
chroot image apt-get update || exit 1
chroot image apt-get install -y $APT_GET || exit 1
chroot image apt-get clean || exit 1
umount image/proc
umount image/sys
umount image/dev/pts
mksquashfs image image.sfs || exit 1
