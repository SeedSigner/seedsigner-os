################################################################################
#
# python-embit
#
################################################################################

PYTHON_EMBIT_VERSION = 0.4.14
PYTHON_EMBIT_SOURCE = embit-$(PYTHON_EMBIT_VERSION).tar.gz
PYTHON_EMBIT_SITE = https://files.pythonhosted.org/packages/f4/c9/133e63ba6f1da1ba684714ffef50c4e952137c04170627a9e10de42d7e2e
PYTHON_EMBIT_LICENSE = MIT
PYTHON_EMBIT_SETUP_TYPE = setuptools

$(eval $(python-package))
