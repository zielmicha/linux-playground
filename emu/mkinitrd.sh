if [ "$#" != 2 ]; then
    echo "Usage: $0 source dest_image"
    exit 1
fi
ROOT=$(dirname $0)/..
if [ ! -e $ROOT/emu/_res/ ]; then
    echo Resources not downloaded.
    exit 1
fi
cd $1 || exit 1
mkdir -p bin
cp $ROOT/emu/_res/busybox bin/busybox
cp $ROOT/emu/halt.sh bin/halt
chmod +x bin/halt
find . -print0 | cpio --null -ov --format=newc | gzip  > $ROOT/_initrd.cpio.gz || exit 1
cd ..
mv $ROOT/_initrd.cpio.gz $2
