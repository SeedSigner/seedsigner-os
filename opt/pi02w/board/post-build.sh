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

# Adding symlink to support upgrade of buildroot python3.10 to python3.12
ln -srf ${TARGET_DIR}/usr/lib/python3.12 ${TARGET_DIR}/usr/lib/python3.10
ln -srf ${TARGET_DIR}/usr/lib/python3.12 ${TARGET_DIR}/usr/lib/python3
ln -srf ${BUILD_DIR}/python3-3.12.10 ${BUILD_DIR}/python3-3.10.10
ln -srf ${BUILD_DIR}/python3-3.12.10 ${BUILD_DIR}/python3

# Clean up files included in embit we don't need
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/liquid
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_darwin_arm64.dylib
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_darwin_x86_64.dylib
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_linux_aarch64.so
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_linux_x86_64.so
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/embit/util/prebuilt/libsecp256k1_windows_amd64.dll

# Clean up tests/docs in other python included libs
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/pyzbar/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/qrcode/tests

# Clean up bigger python modules we don't need
rm -rf ${TARGET_DIR}/usr/lib/python3/turtle.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3/pydoc.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3/doctest.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3/mailbox.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3/zipfile.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3/tarfile.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3/pickletools.pyc
rm -rf ${TARGET_DIR}/usr/lib/python3/turtledemo
rm -rf ${TARGET_DIR}/usr/lib/python3/unittest
rm -rf ${TARGET_DIR}/usr/lib/python3/ensurepip

# ### Cross-arch reproducibility normalization
# ### Files recording the *build machine* architecture make images built on an
# ### aarch64 host differ from x86_64-host builds:
# ###   - python sysconfigdata: embeds the configure build triplet; only loaded via
# ###     sysconfig.get_config_var(), which nothing on the device calls => remove it.
# ###   - libstdc++: its .text used to differ by build host (12 bytes in
# ###     std::from_chars: cc1plus's argument evaluation order leaked into the
# ###     pseudo-register numbering of arm.md's 64-bit shift expanders). Fixed
# ###     at the source by opt/patches/gcc/0001-arm-deterministic-64bit-shift-
# ###     scratch-pseudo-order.patch (verified 2026-07-15: x86_64- and aarch64-
# ###     hosted toolchains produce byte-identical libstdc++.so.6.0.32), so no
# ###     normalization is needed here anymore.

# Remove the libstdc++ gdb helper (build-path metadata; not a library)
rm -f ${TARGET_DIR}/usr/lib/libstdc++.so.6.0.32-gdb.py

# Remove python sysconfigdata (build-host metadata; unused at runtime)
rm -f ${TARGET_DIR}/usr/lib/python3.12/_sysconfigdata__linux_arm-linux-gnueabihf.py

# ### Image slimming: files verified unused by the seedsigner app
# ### (dependency-closure scan of every ELF + import scan of every shipped pyc)

# CLI tools shipped by library packages (zbar, fribidi, qrcode) that the app,
# which links/imports the libraries directly, never invokes
for f in read_zbar read_zbar.py zbarcam fribidi qr; do
  rm -f ${TARGET_DIR}/usr/bin/${f}
done

# Libraries nothing in the image links against (v4l compat shims, harfbuzz subsetter)
rm -rf ${TARGET_DIR}/usr/lib/libv4l
rm -f  ${TARGET_DIR}/usr/lib/libharfbuzz-subset.so*

# libcamera extras: the cam/qcam apps and v4l2 compat are disabled at configure
# time, but the IPA tuning data ships one JSON per supported sensor (~20). Keep
# the two sensors we build drivers for + the uncalibrated fallback.
find ${TARGET_DIR}/usr/share/libcamera/ipa/rpi/vc4 -name '*.json' \
	-not -name 'ov5647.json' -not -name 'imx219.json' \
	-not -name 'uncalibrated.json' \
	-print0 | xargs -0 --no-run-if-empty rm -f

# gnutls and its dependency closure (libtasn1, libunistring, nettle/hogweed,
# gmp): force-selected by buildroot's libcamera Config.in, but our libcamera
# links OpenSSL's libcrypto instead (opt/patches/libcamera/0002), which python3
# already ships. Nothing references these.
rm -f  ${TARGET_DIR}/usr/lib/libgnutls*.so* \
       ${TARGET_DIR}/usr/lib/libtasn1.so* \
       ${TARGET_DIR}/usr/lib/libunistring.so* \
       ${TARGET_DIR}/usr/lib/libnettle.so* \
       ${TARGET_DIR}/usr/lib/libhogweed.so* \
       ${TARGET_DIR}/usr/lib/libgmp*.so* \
       ${TARGET_DIR}/usr/bin/nettle-*

# Python stdlib subsystems with no importers in the image (scan of all pyc string
# tables; concurrent/ was kept only for picamera.mmal, which is gone)
rm -rf ${TARGET_DIR}/usr/lib/python3.12/concurrent \
       ${TARGET_DIR}/usr/lib/python3.12/asyncio \
       ${TARGET_DIR}/usr/lib/python3.12/email \
       ${TARGET_DIR}/usr/lib/python3.12/xml \
       ${TARGET_DIR}/usr/lib/python3.12/http \
       ${TARGET_DIR}/usr/lib/python3.12/multiprocessing \
       ${TARGET_DIR}/usr/lib/python3.12/wsgiref \
       ${TARGET_DIR}/usr/lib/python3.12/venv \
       ${TARGET_DIR}/usr/lib/python3.12/pydoc_data \
       ${TARGET_DIR}/usr/lib/python3.12/zoneinfo
rm -f  ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/_asyncio.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/_multiprocessing.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/_posixshmem.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/_zoneinfo.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/audioop.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/_lsprof.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/spwd.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/syslog.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/xxlimited*.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/_xxinterpchannels.* \
       ${TARGET_DIR}/usr/lib/python3.12/lib-dynload/_xxsubinterpreters.*

# ### Reproducibility experimentation
# ### Remove all pyc files I can seem to make reproducible and keep the py versions

rm -f ${TARGET_DIR}/usr/lib/python3/config-3.12-arm-linux-gnueabihf/Makefile
rm -f ${TARGET_DIR}/usr/lib/python3/json/decoder.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/traceback.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/_sysconfigdata__linux_arm-linux-gnueabihf.pyc

find ${TARGET_DIR}/usr/lib/python3.12 -name '*.py' \
	-not -path "*/python3.12/json/decoder.py" \
	-not -path "*/python3.12/traceback.py" \
	-print0 | \
	xargs -0 --no-run-if-empty rm -f

find "${TARGET_DIR}" -name '.DS_Store' -print0 | xargs -0 --no-run-if-empty rm -f

# Add python byte code (aka __pycache__ directories) to increase boot and import module speed
SOURCE_DATE_EPOCH=1 PYTHONHASHSEED=0 ${HOST_DIR}/bin/python3.12 \
  "${BUILD_DIR}/python3-3.12.10/Lib/compileall.py" \
  -f --invalidation-mode=checked-hash "${TARGET_DIR}/opt/src"
