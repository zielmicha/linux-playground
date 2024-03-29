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
mkdir -p $DATA/shared
$ROOT/emu/kvm.sh -initrd $DATA/tmp/master_initrd -cdrom $DATA/gen/image.sfs $DATA/master.img \
    -net nic,model=virtio -net user,hostfwd=tcp:127.0.0.1:$MASTER_SSH_PORT-:22 \
    -fsdev local,id=exp1,path=$DATA/shared,security_model=mapped -device virtio-9p-pci,fsdev=exp1,mount_tag=storage \
    -fsdev local,id=exp2,path=$ROOT,security_model=mapped,readonly -device virtio-9p-pci,fsdev=exp2,mount_tag=code
