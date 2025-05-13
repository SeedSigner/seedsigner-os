# Define the package name
SECP256K1_VERSION = 0.6.0
SECP256K1_SITE = $(call github,bitcoin-core,secp256k1,v$(SECP256K1_VERSION))

SECP256K1_LICENSE = MIT
SECP256K1_LICENSE_FILES = COPYING

# Enable autoreconf to regenerate the build system files
SECP256K1_AUTORECONF = YES

# Register the package with Buildroot
$(eval $(autotools-package))