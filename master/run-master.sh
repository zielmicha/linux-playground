if [ ! -e _image.sfs ]; then
    echo "[first boot] Creating master image. This may take a while."
    ./generate-master-image.sh
fi
if [ ! -e _master.img ]; then
    echo "[first boot] Preparing master disk. This may take a while."
    qemu-img create -f qcow2 _master.qcow2 500G
fi
