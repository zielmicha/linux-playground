#!/bin/bash
ROOT=$(dirname $0)/..
. $ROOT/vars.inc

if [ ! -e $DATA/gen/image.sfs ]; then
    echo "Master image not found. Run master first."
fi

echo "Starting node..."

initrd_dir=$(maketmp)
cp -a initrd $initrd_dir

cp $DATA/shared/ssh_host_rsa_key.pub $initrd/master_key.pub
echo $MASTER_SSH_PORT > $initrd_dir/master_ssh_port

initrd=$(maketmp)
$ROOT/emu/mkinitrd.sh initrd $initrd || exit 1

$ROOT/emu/kvm.sh -initrd $initrd -cdrom _image.sfs \
    -net user -net nic,net=10.0.3.0/24
