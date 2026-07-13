#!/bin/sh

DEVNAME="/dev/$MDEV"

if [ $ACTION == "add" ] && [ -n "$DEVNAME" ]; then
    mkdir -p /mnt/microsd
    # nodirty (custom kernel patch) keeps the mount from writing the FAT
    # volume dirty flag; fall back for kernels without the patch (dev boards)
    mount -o sync,nodirty $DEVNAME /mnt/microsd || mount -o sync $DEVNAME /mnt/microsd
    echo -n "add" > /tmp/mdev_fifo
elif [ $ACTION == "remove" ] && [ -n "$DEVNAME" ]; then
    umount /mnt/microsd
    rmdir /mnt/microsd
    echo -n "remove" > /tmp/mdev_fifo
fi
