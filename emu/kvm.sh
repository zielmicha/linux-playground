sudo kvm -kernel bzImage-3.6.10 -initrd initrd.cpio.gz -append 'init=/init quiet' \
    $*
