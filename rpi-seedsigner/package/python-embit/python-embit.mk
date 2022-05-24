################################################################################
#
# python-embit
#
################################################################################

PYTHON_EMBIT_VERSION = 0.4.5
PYTHON_EMBIT_SOURCE = embit-$(PYTHON_EMBIT_VERSION).tar.gz
PYTHON_EMBIT_SITE = https://files.pythonhosted.org/packages/fd/4f/876fea09571742667ec37d62a0775d4ea719d5d8f5d85a38434da2654054
PYTHON_EMBIT_LICENSE = MIT
PYTHON_EMBIT_SETUP_TYPE = setuptools

$(eval $(python-package))
