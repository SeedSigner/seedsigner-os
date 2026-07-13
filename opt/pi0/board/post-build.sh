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

# Clean up test files included with numpy
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/testing
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/core/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/linalg/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/f2py/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/typing/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/ma/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/lib/tests
rm -rf ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/random/tests/

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
# ### Two files record the *build machine* architecture, which makes images built on
# ### an aarch64 host differ from x86_64-host builds:
# ###   - libstdc++: nothing in the image links against it, and its .text differs by build
# ###     host (GCC 13.3 orders two spill slots in from_chars differently) => remove it.
# ###   - python sysconfigdata: embeds the configure build triplet; only loaded via
# ###     sysconfig.get_config_var(), which nothing on the device calls => remove it.
# ### (numpy's __config__.py is handled at the source instead: see the python-numpy patch
# ###  in BR2_GLOBAL_PATCH_DIR, opt/patches/python-numpy/.)

# Remove libstdc++ (unused: no binary in the image links against it)
rm -f ${TARGET_DIR}/usr/lib/libstdc++.so.6.0.32 \
      ${TARGET_DIR}/usr/lib/libstdc++.so.6 \
      ${TARGET_DIR}/usr/lib/libstdc++.so \
      ${TARGET_DIR}/usr/lib/libstdc++.so.6.0.32-gdb.py

# Remove python sysconfigdata (build-host metadata; unused at runtime)
rm -f ${TARGET_DIR}/usr/lib/python3.12/_sysconfigdata__linux_arm-linux-gnueabihf.py

# ### Image slimming: files verified unused by the seedsigner app
# ### (dependency-closure scan of every ELF + import scan of every shipped pyc)

# rpi-userland demo/diagnostic binaries; picamera talks to libmmal* directly
for f in containers_check_frame_int containers_datagram_receiver containers_datagram_sender \
         containers_dump_pktfile containers_rtp_decoder containers_stream_client \
         containers_stream_server containers_test containers_test_bits containers_test_uri \
         containers_uri_pipe raspistill raspivid raspividyuv raspiyuv mmal_vc_diag \
         vchiq_test vcsmem vcmailbox tvservice vcgencmd dtoverlay dtoverlay-pre \
         dtoverlay-post dtmerge read_zbar read_zbar.py zbarcam fribidi qr; do
  rm -f ${TARGET_DIR}/usr/bin/${f}
done

# Libraries nothing in the image links against (GL stack, media-container plugins,
# dtoverlay helpers, v4l compat shims, harfbuzz subsetter)
rm -rf ${TARGET_DIR}/usr/lib/plugins \
       ${TARGET_DIR}/usr/lib/libv4l
rm -f  ${TARGET_DIR}/usr/lib/libharfbuzz-subset.so* \
       ${TARGET_DIR}/usr/lib/libdtovl.so \
       ${TARGET_DIR}/usr/lib/libdebug_sym.so \
       ${TARGET_DIR}/usr/lib/libvcilcs.so \
       ${TARGET_DIR}/usr/lib/libkhrn_client.so \
       ${TARGET_DIR}/usr/lib/libopenmaxil.so \
       ${TARGET_DIR}/usr/lib/libEGL.so \
       ${TARGET_DIR}/usr/lib/libGLESv2.so \
       ${TARGET_DIR}/usr/lib/libOpenVG.so \
       ${TARGET_DIR}/usr/lib/libWFC.so \
       ${TARGET_DIR}/usr/lib/libbrcmEGL.so \
       ${TARGET_DIR}/usr/lib/libbrcmGLESv2.so \
       ${TARGET_DIR}/usr/lib/libbrcmOpenVG.so \
       ${TARGET_DIR}/usr/lib/libbrcmWFC.so

# Python stdlib subsystems with no importers in the image (scan of all pyc string tables;
# concurrent/ stays: picamera.mmal uses concurrent.futures)
rm -rf ${TARGET_DIR}/usr/lib/python3.12/asyncio \
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
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/core/_string_helpers.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/distutils/ccompiler.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/distutils/command/build_py.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/distutils/misc_util.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/distutils/system_info.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/f2py/auxfuncs.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/f2py/crackfortran.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/f2py/f2py2e.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/lib/_iotools.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/lib/npyio.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/lib/recfunctions.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/site-packages/numpy/lib/stride_tricks.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/traceback.pyc
rm -f ${TARGET_DIR}/usr/lib/python3/_sysconfigdata__linux_arm-linux-gnueabihf.pyc

find ${TARGET_DIR}/usr/lib/python3.12 -name '*.py' \
	-not -path "*/python3.12/json/decoder.py" \
	-not -path "*/python3.12/site-packages/numpy/core/_string_helpers.py" \
	-not -path "*/python3.12/site-packages/numpy/distutils/ccompiler.py" \
	-not -path "*/python3.12/site-packages/numpy/distutils/command/build_py.py" \
	-not -path "*/python3.12/site-packages/numpy/distutils/misc_util.py" \
	-not -path "*/python3.12/site-packages/numpy/distutils/system_info.py" \
	-not -path "*/python3.12/site-packages/numpy/f2py/auxfuncs.py" \
	-not -path "*/python3.12/site-packages/numpy/f2py/crackfortran.py" \
	-not -path "*/python3.12/site-packages/numpy/f2py/f2py2e.py" \
	-not -path "*/python3.12/site-packages/numpy/lib/_iotools.py" \
	-not -path "*/python3.12/site-packages/numpy/lib/npyio.py" \
	-not -path "*/python3.12/site-packages/numpy/lib/recfunctions.py" \
	-not -path "*/python3.12/site-packages/numpy/lib/stride_tricks.py" \
	-not -path "*/python3.12/traceback.py" \
	-print0 | \
	xargs -0 --no-run-if-empty rm -f

find "${TARGET_DIR}" -name '.DS_Store' -print0 | xargs -0 --no-run-if-empty rm -f

# Add python byte code (aka __pycache__ directories) to increase boot and import module speed
SOURCE_DATE_EPOCH=1 PYTHONHASHSEED=0 ${HOST_DIR}/bin/python3.12 \
  "${BUILD_DIR}/python3-3.12.10/Lib/compileall.py" \
  -f --invalidation-mode=checked-hash "${TARGET_DIR}/opt/src"

# ### l10n externalization
# ### Translations and non-Latin fonts don't need to be RAM-resident; stage them for
# ### the FAT boot partition (copied in by post-image-seedsigner.sh, read by the app
# ### from /mnt/microsd/l10n) and strip them from the initramfs rootfs.

app_res="${TARGET_DIR}/opt/src/seedsigner/resources"
l10n_staging="${BINARIES_DIR}/l10n"

rm -rf "${l10n_staging}"
mkdir -p "${l10n_staging}/fonts"

mo_count=0
for mo in "${app_res}"/seedsigner-translations/l10n/*/LC_MESSAGES/messages.mo; do
  [ -f "${mo}" ] || continue
  locale="$(basename "$(dirname "$(dirname "${mo}")")")"
  mkdir -p "${l10n_staging}/${locale}/LC_MESSAGES"
  cp "${mo}" "${l10n_staging}/${locale}/LC_MESSAGES/messages.mo"
  mo_count=$((mo_count + 1))
done

# Fail loudly rather than ship an image with no languages on the FAT partition
if [ "${mo_count}" -eq 0 ]; then
  echo "ERROR: no compiled messages.mo files found to stage for the FAT partition" >&2
  exit 1
fi

cp "${app_res}"/seedsigner-translations/fonts/*.ttf "${l10n_staging}/fonts/"
cp "${app_res}/fonts/NotoSansDevanagari-Regular.ttf" "${l10n_staging}/fonts/"

# Strip the now-externalized assets from the rootfs
rm -rf "${app_res}/seedsigner-translations"
rm -f  "${app_res}/fonts/NotoSansDevanagari-Regular.ttf"

# Normalize timestamps for byte-reproducible images
find "${l10n_staging}" -exec touch -d "2023/01/01T12:15:05" {} +
