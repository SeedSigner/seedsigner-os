################################################################################
#
# python-mock
#
################################################################################

PYTHON_MOCK_VERSION = 4.0.3
PYTHON_MOCK_SITE = https://files.pythonhosted.org/packages/e2/be/3ea39a8fd4ed3f9a25aae18a1bff2df7a610bca93c8ede7475e32d8b73a0
PYTHON_MOCK_SOURCE = mock-$(PYTHON_MOCK_VERSION).tar.gz
PYTHON_MOCK_LICENSE = BSD License
PYTHON_MOCK_SETUP_TYPE = setuptools

$(eval $(python-package))
