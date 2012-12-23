ROOT=$(dirname $0)/..
. $ROOT/vars.inc

# console=ttyS0  panic=1, -no-reboot -nographic
sudo chown $(whoami) /dev/kvm
kvm -kernel $DATA/res/bzImage -append 'init=/init quiet selinux=0 panic=1 console=ttyS0' -no-reboot -nographic \
    $*
echo
