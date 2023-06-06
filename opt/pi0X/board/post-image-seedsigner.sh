#!/bin/bash

set -e

# BOARD_DIR="$(dirname $0)"
# BOARD_NAME="$(basename ${BOARD_DIR})"
# GENIMAGE_CFG="${BOARD_DIR}/genimage-rpi-seedsigner.cfg"
# GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
# 
# # Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# # ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# # space. We don't rely on genimage to build the rootfs image, just to insert a
# # pre-built one in the disk image.
# 
# trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
# ROOTPATH_TMP="$(mktemp -d)"
# 
# rm -rf "${GENIMAGE_TMP}"
# 
# genimage \
# 	--rootpath "${ROOTPATH_TMP}"   \
# 	--tmppath "${GENIMAGE_TMP}"    \
# 	--inputpath "${BINARIES_DIR}"  \
# 	--outputpath "${BINARIES_DIR}" \
# 	--config "${GENIMAGE_CFG}"
# 
# exit $?

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
dd if=/dev/zero of=disk.img bs=1M count=35 #40 MB

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
# mcopy doesn't copy directories deterministically, so rely on sorted shell globbing
# instead.
mcopy -bpm -i "disk.img@@$OFFSET" overlays/* ::overlays
mv disk.img ${BASE_DIR}/images/seedsigner_os.img

cd -