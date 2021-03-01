#
# Base-files consolidation for IPQ chipsets
#

BASEFILES_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

define base-files_install_append
ifneq ($(CONFIG_TARGET_ipq807x)$(CONFIG_TARGET_ipq50xx)$(CONFIG_TARGET_ipq60xx),)
	$(CP) $(BASEFILES_DIR)/files/* $(1)/
endif
endef

Package/base-files/install += $(newline)$(base-files_install_append)
