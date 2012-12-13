cd initrd || exit 1
find . -print0 | cpio --null -ov --format=newc | gzip  > ../initrd.cpio.gz || exit 1
cd ..
