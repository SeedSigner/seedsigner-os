#!/bin/sh

# Dev-image post-build. Derived from ../pi02w/board/post-build.sh but the
# aggressive image-slimming steps are intentionally skipped: the dev image
# keeps the full python stdlib (venv, ensurepip, unittest, asyncio, ...) and
# all .py sources so code can be read, edited, and pip-installed on-device.

set -u
set -e

# The release rootfs-overlay carries etc/shadow with root locked out
# (root:*:::::::), and buildroot's own root-password hook runs *before*
# overlays are copied onto the target tree -- so that overlay always wins,
# silently overriding BR2_TARGET_GENERIC_ROOT_PASSWD. Reapply it now that the
# overlay has landed. $2 comes from BR2_ROOTFS_POST_BUILD_SCRIPT_ARGS in the
# defconfig ($1 is TARGET_DIR, passed positionally by buildroot).
ROOT_PASSWD="${2:?BR2_ROOTFS_POST_BUILD_SCRIPT_ARGS must hold the root password}"
ROOT_HASH="$(${HOST_DIR}/bin/mkpasswd -m sha-256 "${ROOT_PASSWD}")"
sed -i "s,^root:[^:]*:,root:${ROOT_HASH}:," ${TARGET_DIR}/etc/shadow

# Clean up files included in skeleton not needed.
# Unlike the release image, syslogd/klogd are kept so /var/log/messages works,
# and networking is handled by the dev overlay's own init scripts (S35network)
# instead of the skeleton's S40network.
rm -f ${TARGET_DIR}/etc/init.d/S02sysctl
rm -f ${TARGET_DIR}/etc/init.d/S02mdev
rm -f ${TARGET_DIR}/etc/init.d/S20seedrng
rm -f ${TARGET_DIR}/etc/init.d/S40network
rm -f ${TARGET_DIR}/etc/init.d/S50pigpio

# Add a root shell on the HDMI console (tty1) and the serial console.
# These respawn a shell directly (no login), so they bypass /etc/passwd -- use
# bash here so the console shell matches root's login shell (set below).
if [ -e ${TARGET_DIR}/etc/inittab ]; then
	grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/c\
console::respawn:-/bin/bash\
tty1::respawn:-/bin/bash' ${TARGET_DIR}/etc/inittab
fi

# Make bash root's login shell (SSH/dropbear reads it from /etc/passwd). /bin/sh
# stays busybox ash for system scripts; only interactive root sessions get bash.
if [ -e ${TARGET_DIR}/etc/passwd ]; then
	sed -i '/^root:/s|:/bin/sh$|:/bin/bash|' ${TARGET_DIR}/etc/passwd
fi

# NOTE: /root is persisted across reboots at *runtime* by S30devdata, which
# bind-mounts /mnt/data/root over /root once the data partition is mounted.

# Adding symlink to support upgrade of buildroot python3.10 to python3.12
ln -srf ${TARGET_DIR}/usr/lib/python3.12 ${TARGET_DIR}/usr/lib/python3.10
ln -srf ${TARGET_DIR}/usr/lib/python3.12 ${TARGET_DIR}/usr/lib/python3
ln -srf ${BUILD_DIR}/python3-3.12.10 ${BUILD_DIR}/python3-3.10.10
ln -srf ${BUILD_DIR}/python3-3.12.10 ${BUILD_DIR}/python3

# Clean up files included in embit we don't need (foreign-platform prebuilts; same as the release image)
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/liquid
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_darwin_arm64.dylib
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_darwin_x86_64.dylib
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_linux_aarch64.so
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_linux_x86_64.so
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_windows_amd64.dll

# Dev convenience: make `python3 -m venv DIR` produce a usable venv by default.
# This image's Python is built --without-ensurepip and carries the app's native
# deps (PIL/numpy/embit/...) only in the system site-packages, so the two useful
# venv defaults here are the opposite of upstream CPython:
#   --system-site-packages -> default ON  (venv sees the baked-in packages)
#   pip bootstrap          -> default OFF (ensurepip is unavailable; the system
#                             pip is used instead, via system-site-packages)
# Only the argparse *defaults* in the venv CLI are flipped; passing the flags
# explicitly still works. (Both target strings are unique in venv/__init__.py.)
# Also Fix double-parens in venv prompt: context.prompt already includes "(venv) ",
# so set it to bare "venv" and let the activate template add the parens.
VENV_INIT="${TARGET_DIR}/usr/lib/python3.12/venv/__init__.py"
if [ -f "${VENV_INIT}" ]; then
	sed -i \
		-e "s/'--system-site-packages', default=False,/'--system-site-packages', default=True,/" \
		-e "s/default=True, action='store_false',/default=False, action='store_false',/" \
		-e "s/context.prompt = '(%s) ' % prompt/context.prompt = '%s' % prompt/" \
		"${VENV_INIT}"
	rm -f "${TARGET_DIR}/usr/lib/python3.12/venv/__pycache__/__init__."*.pyc
fi

# dropbear (server) always installs its own scp, colliding with OpenSSH's at
# /usr/bin/scp; force OpenSSH's to win since dropbear's scp needs its client, which we skip.
OSSH_SCP=$(ls -d ${BUILD_DIR}/openssh-*/scp 2>/dev/null | head -1)
if [ -n "${OSSH_SCP}" ] && [ -f "${OSSH_SCP}" ]; then
	rm -f "${TARGET_DIR}/usr/bin/scp"
	cp -a "${OSSH_SCP}" "${TARGET_DIR}/usr/bin/scp"
fi

find "${TARGET_DIR}" -name '.DS_Store' -print0 | xargs -0 --no-run-if-empty rm -f

# Add python byte code (aka __pycache__ directories) to increase boot and import module speed
SOURCE_DATE_EPOCH=1 PYTHONHASHSEED=0 ${HOST_DIR}/bin/python3.12 \
  "${BUILD_DIR}/python3-3.12.10/Lib/compileall.py" \
  -f --invalidation-mode=checked-hash "${TARGET_DIR}/opt/src"