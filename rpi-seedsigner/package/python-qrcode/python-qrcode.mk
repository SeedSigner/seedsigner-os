################################################################################
#
# python-qrocde
#
################################################################################

PYTHON_QRCODE_VERSION = 7.2
PYTHON_QRCODE_SITE = https://files.pythonhosted.org/packages/99/6f/3914ab406164775a6293ebe001e57d23e38c09d51f3909c45bd132684927
PYTHON_QRCODE_SOURCE = qrcode-$(PYTHON_QRCODE_VERSION).tar.gz
PYTHON_QRCODE_LICENSE = BSD License
PYTHON_QRCODE_SETUP_TYPE = setuptools

$(eval $(python-package))
