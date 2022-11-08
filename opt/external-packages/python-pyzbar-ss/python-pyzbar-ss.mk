 ################################################################################
 #
 # python-pyzbar-ss
 #
 ################################################################################

 PYTHON_PYZBAR_SS_VERSION = 0.1.9-ss
 PYTHON_PYZBAR_SS_SITE = $(call github,SeedSigner,pyzbar,v$(PYTHON_PYZBAR_SS_VERSION))
 PYTHON_PYZBAR_SS_SETUP_TYPE = setuptools
 PYTHON_PYZBAR_SS_LICENSE = MIT

 
 $(eval $(python-package))

