ROOT=$(dirname $0)/..
. $ROOT/vars.inc

if [ ! -e _image.sfs ]; then
    if [ $(whoami) = root ]; then
        ./generate-master-image.sh
        echo "[first boot] Creating master image. This may take a while."
    else
        echo "[first boot] Run $PWD/generate-master-image.sh as root."
        exit 1
    fi
fi
if [ ! -e _master.img ]; then
    echo "[first boot] Preparing master disk. This may take a while."
    qemu-img create -f qcow2 _master.img 500G
    mkdir -p initrd/bin
    touch $ROOT/_config/_first_startup
fi
echo 'Starting master...'
$ROOT/emu/mkinitrd.sh initrd $ROOT/_tmp/master_initrd || exit 1
export PG_EXPORT_PATH=$ROOT/_config
mkdir -p $PG_EXPORT_PATH
$ROOT/emu/kvm.sh -initrd $ROOT/_tmp/master_initrd -cdrom _image.sfs _master.img \
    -net nic,model=virtio -net user,hostfwd=tcp:127.0.0.1:$MASTER_SSH_PORT-:22
