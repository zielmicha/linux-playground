if [ "$#" != 2 ]; then
    echo "Usage: $0 source dest_image"
    exit 1
fi
ROOT=$(readlink -f $(dirname $0)/..)
if [ ! -e $ROOT/emu/_res/ ]; then
    echo Resources not downloaded.
    exit 1
fi
cd $1 || exit 1
mkdir -p bin
cp $ROOT/emu/_res/busybox bin/busybox || exit 1
chmod +x bin/busybox || exit 1
cp $ROOT/emu/halt.sh bin/halt || exit 1
ln -sf /bin/busybox bin/sh || exit 1
chmod +x bin/halt
find . -print0 | cpio --null -o --format=newc --quiet | gzip  > $ROOT/_initrd.cpio.gz || exit 1
cd ..
mv $ROOT/_initrd.cpio.gz $2
