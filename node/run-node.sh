#!/bin/bash
ROOT=$(dirname $0)/..
. $ROOT/vars.inc

if [ ! -e $ROOT/master/_image.sfs ]; then
    echo "Master image not found. Run master first."
fi

echo "Starting node..."

cp $ROOT/_config/ssh_host_rsa_key.pub initrd/master_key.pub
echo $MASTER_SSH_PORT > initrd/master_ssh_port

$ROOT/emu/mkinitrd.sh initrd $ROOT/_tmp/node_initrd || exit 1

$ROOT/emu/kvm.sh -initrd $ROOT/_tmp/node_initrd -cdrom _image.sfs \
    -net user -net nic,net=10.0.3.0/24
