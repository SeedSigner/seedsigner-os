#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-rpi-seedsigner.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# The .dtb we boot is built from the kernel tree (raspberrypi/linux 5.15), but the
# .dtbo overlays come from the rpi-firmware package, which tracks a much newer
# kernel. The camera overlays there reference an "i2c_csi_dsi0" symbol that the 5.15
# device tree does not define, and the firmware silently refuses to apply an overlay
# whose symbols it cannot all resolve: csi1 stays disabled, the sensor node is never
# created and libcamera enumerates no cameras. Build the kernel's own overlays, which
# match our .dtb by construction, and override the firmware copies.
KERNEL_DIR="${BUILD_DIR}/linux-custom"
OVERLAY_SRC="${KERNEL_DIR}/arch/arm/boot/dts/overlays"
for overlay in ov5647 imx219; do
	cpp -nostdinc -undef -x assembler-with-cpp \
		-I "${OVERLAY_SRC}" -I "${KERNEL_DIR}/include" \
		"${OVERLAY_SRC}/${overlay}-overlay.dts" \
	| "${KERNEL_DIR}/scripts/dtc/dtc" -@ -H epapr -I dts -O dtb \
		-o "${BINARIES_DIR}/rpi-firmware/overlays/${overlay}.dtbo"
done

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
