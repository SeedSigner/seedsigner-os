################################################################################
#
# libraqm
#
################################################################################

LIBRAQM_VERSION = 0.10.3
LIBRAQM_SITE = $(call github,HOST-Oman,libraqm,v$(LIBRAQM_VERSION))
LIBRAQM_LICENSE = MIT
LIBRAQM_LICENSE_FILES = COPYING
LIBRAQM_INSTALL_STAGING = YES

# libraqm depends on freetype, harfbuzz, and fribidi
LIBRAQM_DEPENDENCIES = freetype harfbuzz libfribidi host-pkgconf

$(eval $(meson-package))