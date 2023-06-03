#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
	# if 'tty1::' is not found in inittab, then replace the line containing GENERIC_SERIAL with
	# 'onsole::respawn:-/bin/sh' + 'tty1::respawn:-/bin/sh'
	grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/c\
console::respawn:-/bin/sh\
tty1::respawn:-/bin/sh' ${TARGET_DIR}/etc/inittab
fi

# Clean up files included in skeleton not needed
rm -f ${TARGET_DIR}/etc/init.d/S01syslogd
rm -f ${TARGET_DIR}/etc/init.d/S02klogd
rm -f ${TARGET_DIR}/etc/init.d/S02sysctl
rm -f ${TARGET_DIR}/etc/init.d/S02mdev
rm -f ${TARGET_DIR}/etc/init.d/S20seedrng
rm -f ${TARGET_DIR}/etc/init.d/S40network
rm -f ${TARGET_DIR}/etc/init.d/S50pigpio

# Clean up test files included with numpy
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/tests
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/testing
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/core/tests

# Clean up files included in embit we don't need
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/embit/liquid

# Clean up tests/docs in other python included libs
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/pyzbar/tests
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/qrcode/tests

# Clean up bigger python modules we don't need
rm -rf ${TARGET_DIR}/usr/lib/python3.10/turtle.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3.10/pydoc.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3.10/doctest.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3.10/mailbox.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3.10/zipfile.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3.10/tarfile.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3.10/pickletools.pyc
