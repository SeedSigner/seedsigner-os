 ################################################################################
 #
 # python-pyzbar
 #
 ################################################################################

 PYTHON_PYZBAR_VERSION = 0.1.9-ss
 PYTHON_PYZBAR_SITE = $(call github,SeedSigner,pyzbar,v$(PYTHON_PYZBAR_VERSION))
 PYTHON_PYZBAR_SETUP_TYPE = setuptools
 PYTHON_PYZBAR_LICENSE = MIT

 
 $(eval $(python-package))

