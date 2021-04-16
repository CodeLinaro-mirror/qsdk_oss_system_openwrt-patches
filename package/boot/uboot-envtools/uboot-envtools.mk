# Recipe extension for package : uboot-envtools

UBOOT-ENVTOOLS_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

define uboot-envtools_install_append
ifneq ($(CONFIG_TARGET_ipq807x)$(CONFIG_TARGET_ipq50xx)$(CONFIG_TARGET_ipq60xx),)
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) $(UBOOT-ENVTOOLS_DIR)/files/ipq $(1)/etc/uci-defaults/30_uboot-envtools
endif
endef

Package/uboot-envtools/install += $(newline)$(uboot-envtools_install_append)
