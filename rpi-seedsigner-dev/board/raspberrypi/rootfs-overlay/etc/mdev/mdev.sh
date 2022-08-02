#!/bin/sh

ACTION=$1
name=$2
DEVNAME="/dev/$name"


if [ $ACTION == "add" ] && [ -n "$DEVNAME" ]; then
    mkdir -p /mnt/microsd
    mount $DEVNAME /mnt/microsd
fi


if [ $ACTION == "remove" ] && [ -n "$DEVNAME" ]; then
    umount /mnt/microsd
    rmdir /mnt/microsd
fi
