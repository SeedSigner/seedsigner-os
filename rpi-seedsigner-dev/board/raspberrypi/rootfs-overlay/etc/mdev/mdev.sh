#!/bin/sh

DEVNAME="/dev/$MDEV"

if [ $ACTION == "add" ] && [ -n "$DEVNAME" ]; then
    mkdir -p /mnt/microsd
    mount $DEVNAME /mnt/microsd
    echo "add /mnt/microsd" | nc -w 0 -U "/tmp/mdev_socket"
elif [ $ACTION == "remove" ] && [ -n "$DEVNAME" ]; then
    umount /mnt/microsd
    rmdir /mnt/microsd
    echo "remove /mnt/microsd" | nc -w 0 -U "/tmp/mdev_socket"
fi