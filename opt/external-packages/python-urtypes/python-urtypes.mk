 ################################################################################
 #
 # python-urtypes
 #
 ################################################################################

 PYTHON_URTYPES_VERSION = 0.1.0
 PYTHON_URTYPES_SITE = $(call github,selfcustody,urtypes,v$(PYTHON_URTYPES_VERSION))
 PYTHON_URTYPES_SETUP_TYPE = setuptools
 PYTHON_URTYPES_LICENSE = MIT

 
 $(eval $(python-package))

