#
# Base-files consolidation for IPQ chipsets
#

BASEFILES_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

define base-files_install_append
ifneq (, $(findstring ipq, $(CONFIG_TARGET_BOARD)))
	$(CP) $(BASEFILES_DIR)/files/* $(1)/
endif
endef

Package/base-files/install += $(newline)$(base-files_install_append)
