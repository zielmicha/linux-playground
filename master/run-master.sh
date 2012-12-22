ROOT=$(dirname $0)/..
. $ROOT/vars.inc

if [ ! -e $DATA/gen/image.sfs ]; then
    echo "[first boot] $DATA/gen/image.sfs missing"
    if [ $(whoami) = root ]; then
        ./generate-master-image.sh
        echo "[first boot] Creating master image. This may take a while."
    else
        echo "[first boot] Run $PWD/generate-master-image.sh as root."
        exit 1
    fi
fi
if [ ! -e $DATA/master.img ]; then
    echo "[first boot] Preparing master disk. This may take a while."
    qemu-img create -f qcow2 $DATA/master.img 500G
    touch $DATA/shared/_first_startup
fi
echo 'Starting master...'
$ROOT/emu/mkinitrd.sh initrd $DATA/tmp/master_initrd || exit 1
export PG_EXPORT_PATH=$DATA/shared
mkdir -p $PG_EXPORT_PATH
$ROOT/emu/kvm.sh -initrd $DATA/tmp/master_initrd -cdrom $DATA/gen/image.sfs $DATA/master.img \
    -net nic,model=virtio -net user,hostfwd=tcp:127.0.0.1:$MASTER_SSH_PORT-:22
