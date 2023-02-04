################################################################################
#
# python-embit
#
################################################################################

PYTHON_EMBIT_VERSION = 0.7.0
PYTHON_EMBIT_SOURCE = embit-$(PYTHON_EMBIT_VERSION).tar.gz
PYTHON_EMBIT_SITE = https://files.pythonhosted.org/packages/39/51/9f606c964a45e74cc9df259c5df5e69586c491178bf2972a59b40a889be0
PYTHON_EMBIT_LICENSE = MIT
PYTHON_EMBIT_SETUP_TYPE = setuptools

$(eval $(python-package))
