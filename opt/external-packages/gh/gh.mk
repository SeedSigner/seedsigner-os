################################################################################
#
# gh (GitHub CLI)
#
################################################################################

GH_VERSION = 2.96.0
GH_SOURCE = gh_$(GH_VERSION)_linux_armv6.tar.gz
GH_SITE = https://github.com/cli/cli/releases/download/v$(GH_VERSION)
GH_LICENSE = MIT
GH_LICENSE_FILES = LICENSE

# Dev-image convenience: install the official prebuilt, statically-linked ARM
# binary instead of building gh from Go source (gh has a very large module
# tree). The linux_armv6 build runs on the pi02w (armv7/armv8 in 32-bit mode).
# gh talks to github.com over HTTPS (ca-certificates) and shells out to git;
# both are already in the dev image.
define GH_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/gh $(TARGET_DIR)/usr/bin/gh
endef

$(eval $(generic-package))
