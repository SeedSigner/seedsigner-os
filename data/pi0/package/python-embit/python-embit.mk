################################################################################
#
# python-embit
#
################################################################################

PYTHON_EMBIT_VERSION = 0.5.0
PYTHON_EMBIT_SOURCE = embit-$(PYTHON_EMBIT_VERSION).tar.gz
PYTHON_EMBIT_SITE = https://files.pythonhosted.org/packages/d5/be/9be9bba669e901d0318e8367fd9f744fe8d6eff3ba1bcfb03f5cfa553310
PYTHON_EMBIT_LICENSE = MIT
PYTHON_EMBIT_SETUP_TYPE = setuptools

$(eval $(python-package))
