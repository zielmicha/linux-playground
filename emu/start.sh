./mkinitrd.sh >/dev/null 2>&1
sudo kvm -kernel bzImage-3.6.10 -initrd initrd.cpio.gz -append 'init=/init quiet console=ttyS0 panic=1' -nographic -no-reboot
