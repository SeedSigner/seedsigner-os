################################################################################
#
# python-babel
#
################################################################################

PYTHON_BABEL_VERSION = 2.10.1
PYTHON_BABEL_SITE = https://files.pythonhosted.org/packages/23/a6/a616817c8e4fb1a69f7e8aae9fc7fce1a147e1a492f45b6fa0b7d6823178
PYTHON_BABEL_SOURCE = Babel-$(PYTHON_BABEL_VERSION).tar.gz
PYTHON_BABEL_LICENSE = MIT
PYTHON_BABEL_SETUP_TYPE = setuptools

$(eval $(python-package))
