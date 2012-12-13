./mkinitrd.sh >/dev/null 2>&1
EXPORT_PATH=_tmp
sudo kvm -kernel bzImage-3.6.10 -initrd initrd.cpio.gz -append 'init=/init quiet console=ttyS0 panic=1' -nographic -no-reboot \
    -fsdev local,id=exp1,path=$EXPORT_PATH,security_model=mapped -device virtio-9p-pci,fsdev=exp1,mount_tag=storage
