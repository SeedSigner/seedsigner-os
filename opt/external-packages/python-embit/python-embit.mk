################################################################################
#
# python-embit
#
################################################################################

PYTHON_EMBIT_VERSION = 0.6.1
PYTHON_EMBIT_SOURCE = embit-$(PYTHON_EMBIT_VERSION).tar.gz
PYTHON_EMBIT_SITE = https://files.pythonhosted.org/packages/9a/74/e5e213b5c6471eb56d773eb936ba14c3a4e04ab6c6069a56c0d9a0278a39
PYTHON_EMBIT_LICENSE = MIT
PYTHON_EMBIT_SETUP_TYPE = setuptools

$(eval $(python-package))
