#!/bin/sh

# Dev-image start.sh (overrides rootfs-overlay/start.sh via overlay order).
#
# Prefers a developer checkout on the persistent data partition over the code
# baked into the image:
#   git clone https://github.com/SeedSigner/seedsigner.git /mnt/data/seedsigner
#
# S02seedsigner launches this before S30devdata has mounted /mnt/data, so wait
# briefly for the mount to show up (skipped instantly when the data partition
# is missing or holds no checkout).

DEV_DIR="/mnt/data/seedsigner"
DEV_SRC="${DEV_DIR}/src"

if [ -b /dev/mmcblk0p2 ] || [ -e /sys/class/block/mmcblk0p2 ]; then
    WAITED=0
    while [ $WAITED -lt 15 ] && ! grep -q ' /mnt/data ' /proc/mounts; do
        sleep 1
        WAITED=$((WAITED + 1))
    done
fi

PYTHON="/usr/bin/python3"

if [ -f "${DEV_SRC}/main.py" ]; then
    echo "seedsigner: running from ${DEV_SRC}" > /dev/kmsg
    # Use the checkout's virtualenv when one exists (either .venv or venv)
    for _venv in "${DEV_DIR}/.venv" "${DEV_DIR}/venv"; do
        if [ -x "${_venv}/bin/python3" ]; then
            PYTHON="${_venv}/bin/python3"
            break
        fi
    done
    cd "${DEV_SRC}"
else
    echo "seedsigner: running from /opt/src" > /dev/kmsg
    cd /opt/src/
fi

# exec (not background) so the pid tracked by S02seedsigner / `seedsigner` is
# the python process itself -- that's what makes stop/restart/status reliable.
#exec ${PYTHON} main.py >> /dev/kmsg 2>&1  # version that writes output to dmesg
exec ${PYTHON} main.py
