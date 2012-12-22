if [ "$#" != 2 ]; then
    echo "Usage: $0 source dest_image"
    exit 1
fi
ROOT=$(dirname $0)/..
. $ROOT/vars.inc

if [ ! -e $DATA/res/busybox ]; then
    echo Resources not downloaded.
    echo "Run $ROOT/emu/download-res.sh"
    exit 1
fi

initrd_tmp=$(maketmp)
initrd_tmp_dir=$(maketmp)
mkdir $initrd_tmp_dir || exit
rmdir $initrd_tmp_dir || exit
cp -a $1 $initrd_tmp_dir

cd $initrd_tmp_dir || exit 1

mkdir -p bin
cp $DATA/res/busybox bin/busybox || exit 1
chmod +x bin/busybox || exit 1
cp $ROOT/emu/halt.sh bin/halt || exit 1
ln -sf /bin/busybox bin/sh || exit 1
chmod +x bin/halt
find . -print0 | cpio --null -o --format=newc --quiet | gzip  > $initrd_tmp || exit 1

cd - 2>/dev/null

rm -r $initrd_tmp_dir
mv $initrd_tmp $2
