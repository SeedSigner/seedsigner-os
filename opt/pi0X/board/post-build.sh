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

### Reproducibility experimentation
### Remove all pyc files
find ${TARGET_DIR}/usr/lib/python3.10 -name '*.pyc' -print0 | xargs -0 --no-run-if-empty rm -f
### Create pyc files post build in a way that is reproducible
export PYTHONHASHSEED=0
export SOURCE_DATE_EPOCH=1
${HOST_DIR}/usr/bin/python3.10 -m compileall -f --invalidation-mode=checked-hash -s "${TARGET_DIR}" -p / ${TARGET_DIR}/usr/lib/python3.10/

### reproducible build cheat
### not able to figure out why this pyc are different each build, so I'm deleting them
rm -f ${TARGET_DIR}/usr/lib/python3.10/json/__pycache__/decoder.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/multiprocessing/__pycache__/connection.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/core/__pycache__/_string_helpers.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/distutils/__pycache__/ccompiler.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/distutils/__pycache__/misc_util.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/distutils/__pycache__/system_info.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/distutils/command/__pycache__/build_py.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/f2py/__pycache__/auxfuncs.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/f2py/__pycache__/crackfortran.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/f2py/__pycache__/f2py2e.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/f2py/tests/__pycache__/test_array_from_pyobj.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/lib/__pycache__/_iotools.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/lib/__pycache__/npyio.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/lib/__pycache__/recfunctions.cpython-310.pyc
rm -f ${TARGET_DIR}/usr/lib/python3.10/site-packages/numpy/lib/__pycache__/stride_tricks.cpython-310.pyc