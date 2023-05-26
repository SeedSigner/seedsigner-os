#!/bin/sh

set -u
set -e

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
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/random
rm -rf ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/linalg/tests

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
rm -rf ${TARGET_DIR}/usr/lib/python3.10/turtledemo
rm -rf ${TARGET_DIR}/usr/lib/python3.10/unittest
rm -rf ${TARGET_DIR}/usr/lib/python3.10/ensurepip