ROOT=$(dirname $0)/..
. $ROOT/vars.inc

if [ "$PG_EXPORT_PATH" != "" ]; then
    fsdev_args="-fsdev local,id=exp1,path=$PG_EXPORT_PATH,security_model=mapped -device virtio-9p-pci,fsdev=exp1,mount_tag=storage"
fi
# console=ttyS0  panic=1, -no-reboot -nographic
sudo chown $(whoami) /dev/kvm
kvm -kernel $DATA/res/bzImage -append 'init=/init quiet selinux=0 panic=1 console=ttyS0' -no-reboot -nographic \
    $fsdev_args \
    $*
echo
