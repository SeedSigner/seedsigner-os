#!/bin/bash

set -e

sectorsToBlocks() {
  echo $(( ( "$1" * 512 ) / 1024 ))
}

sectorsToBytes() {
  echo $(( "$1" * 512 ))
}

export disk_timestamp="2023/01/01T12:15:05"

rm -rf ${BUILD_DIR}/custom_image
mkdir -p ${BUILD_DIR}/custom_image
cd ${BUILD_DIR}/custom_image

# Create disk image.
dd if=/dev/zero of=disk.img bs=1M count=50  # block size (1MB) * count = size allocated for image

### needed: apt install fdisk
/sbin/sfdisk disk.img <<EOF
  label: dos
  label-id: 0xba5eba11

  disk.img1 : type=c, bootable
EOF

# Create boot partition.
START=$(/sbin/fdisk -l -o Start disk.img|tail -n 1)
SECTORS=$(/sbin/fdisk -l -o Sectors disk.img|tail -n 1)
### needed: apt install dosfstools
/sbin/mkfs.vfat --invariant -i ba5eba11 -n SEEDSIGNROS disk.img --offset $START $(sectorsToBlocks $SECTORS)
OFFSET=$(sectorsToBytes $START)

# Copy boot files.
mkdir -p boot/overlays overlays
cp ${BASE_DIR}/images/rpi-firmware/cmdline.txt boot/cmdline.txt
cp ${BASE_DIR}/images/rpi-firmware/config.txt boot/config.txt
cp ${BASE_DIR}/images/rpi-firmware/bootcode.bin boot/bootcode.bin
cp ${BASE_DIR}/images/rpi-firmware/fixup_x.dat boot/fixup_x.dat
cp ${BASE_DIR}/images/rpi-firmware/start_x.elf boot/start_x.elf
cp ${BASE_DIR}/images/rpi-firmware/overlays/* overlays/
cp ${BASE_DIR}/images/*.dtb boot/
cp ${BASE_DIR}/images/zImage boot/zImage

chmod 0755 `find boot overlays`
touch -d "${disk_timestamp}" `find boot overlays`
### needed: apt install mtools
mcopy -bpm -i "disk.img@@$OFFSET" boot/* ::
# mcopy doesn't copy directories deterministically, so rely on sorted shell globbing instead.
mcopy -bpm -i "disk.img@@$OFFSET" overlays/* ::overlays

# Copy the l10n assets (translations + non-Latin fonts) staged by post-build.sh.
# The app reads them from /mnt/microsd/l10n.
cp -r ${BASE_DIR}/images/l10n l10n
chmod 0755 `find l10n`
touch -d "${disk_timestamp}" `find l10n`
# Create dirs and copy files one at a time in sorted order to keep the image
# deterministic (mmd honors SOURCE_DATE_EPOCH for created dirs).
for d in $(find l10n -type d | LC_ALL=C sort); do
  mmd -i "disk.img@@$OFFSET" "::${d}"
done
for f in $(find l10n -type f | LC_ALL=C sort); do
  mcopy -bpm -i "disk.img@@$OFFSET" "${f}" "::${f}"
done

mv disk.img ${BASE_DIR}/images/seedsigner_os.img

cd -