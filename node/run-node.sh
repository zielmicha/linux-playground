#!/bin/bash
ROOT=$(dirname $0)/..
. $ROOT/vars.inc

if [ ! -e $DATA/gen/image.sfs ]; then
    echo "Master image not found. Run master first."
fi

echo "Starting node..."

initrd_dir=$(maketmp)
cp -a initrd $initrd_dir

cp $DATA/shared/ssh_host_rsa_key.pub $initrd_dir/master_key.pub
cp $DATA/shared/id_node $initrd_dir/id_node
cp $DATA/shared/id_node.pub $initrd_dir/id_node.pub
echo $MASTER_SSH_PORT > $initrd_dir/master_ssh_port

initrd=$(maketmp)
$ROOT/emu/mkinitrd.sh $initrd_dir $initrd || exit 1

rm -r "$initrd_dir"

$ROOT/emu/kvm.sh -initrd $initrd -cdrom $DATA/gen/image.sfs \
    -net nic,model=virtio -net user,net=10.0.3.0/24 \
    -fsdev local,id=exp2,path=$ROOT,security_model=mapped,readonly -device virtio-9p-pci,fsdev=exp2,mount_tag=code

rm $initrd
