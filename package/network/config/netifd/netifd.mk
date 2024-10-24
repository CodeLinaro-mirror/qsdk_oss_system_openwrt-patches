# Recipe extension for package : netifd

NETIFD:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

define netifd_install_append
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(NETIFD)/files/66-netifd-set-up-no-hairpin-flood.sh $(1)/etc/uci-defaults
endef

Package/netifd/install += $(newline)$(netifd_install_append)
