#!/bin/bash

set -e

sectorsToBlocks() {
  echo $(( ( "$1" * 512 ) / 1024 ))
}

sectorsToBytes() {
  echo $(( "$1" * 512 ))
}

export disk_timestamp="2023/01/01T12:15:05"

# The .dtb we boot is built from the kernel tree (raspberrypi/linux 5.15), but the
# .dtbo overlays come from the rpi-firmware package, which tracks a much newer
# kernel. The camera overlays there reference an "i2c_csi_dsi0" symbol that the 5.15
# device tree does not define, and the firmware silently refuses to apply an overlay
# whose symbols it cannot all resolve: csi1 stays disabled, the sensor node is never
# created and libcamera enumerates no cameras. Build the kernel's own overlays, which
# match our .dtb by construction, and override the firmware copies. disable-wifi and
# disable-bt (referenced by boot_config.txt) get the same treatment so a firmware
# symbol mismatch can never silently leave the radios enabled.
# (dtc output is deterministic; the chmod/touch below keeps the image reproducible.)
KERNEL_DIR="${BUILD_DIR}/linux-custom"
OVERLAY_SRC="${KERNEL_DIR}/arch/arm/boot/dts/overlays"
for overlay in ov5647 imx219 disable-wifi disable-bt; do
	cpp -nostdinc -undef -x assembler-with-cpp \
		-I "${OVERLAY_SRC}" -I "${KERNEL_DIR}/include" \
		"${OVERLAY_SRC}/${overlay}-overlay.dts" \
	| "${KERNEL_DIR}/scripts/dtc/dtc" -@ -H epapr -I dts -O dtb \
		-o "${BINARIES_DIR}/rpi-firmware/overlays/${overlay}.dtbo"
done

rm -rf ${BUILD_DIR}/custom_image
mkdir -p ${BUILD_DIR}/custom_image
cd ${BUILD_DIR}/custom_image

# Create disk image.
dd if=/dev/zero of=disk.img bs=1M count=50 # block size (1MB) * count = size allocated for image

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
cp ${BASE_DIR}/images/rpi-firmware/fixup.dat boot/fixup.dat
cp ${BASE_DIR}/images/rpi-firmware/start.elf boot/start.elf
# Only the overlays config.txt can actually use: the two camera sensors and
# the radio-disable overlays (all kernel-built, see above) plus the firmware's
# overlay-name map. The other ~320 rpi-firmware overlays target hardware this
# image has no drivers for.
cp ${BASE_DIR}/images/rpi-firmware/overlays/overlay_map.dtb overlays/
cp ${BASE_DIR}/images/rpi-firmware/overlays/ov5647.dtbo overlays/
cp ${BASE_DIR}/images/rpi-firmware/overlays/imx219.dtbo overlays/
cp ${BASE_DIR}/images/rpi-firmware/overlays/disable-wifi.dtbo overlays/
cp ${BASE_DIR}/images/rpi-firmware/overlays/disable-bt.dtbo overlays/
cp ${BASE_DIR}/images/*.dtb boot/
cp ${BASE_DIR}/images/zImage boot/zImage

chmod 0755 `find boot overlays`
touch -d "${disk_timestamp}" `find boot overlays`
### needed: apt install mtools
mcopy -bpm -i "disk.img@@$OFFSET" boot/* ::
# mcopy doesn't copy directories deterministically, so rely on sorted shell globbing instead.
mcopy -bpm -i "disk.img@@$OFFSET" overlays/* ::overlays
mv disk.img ${BASE_DIR}/images/seedsigner_os.img

cd -