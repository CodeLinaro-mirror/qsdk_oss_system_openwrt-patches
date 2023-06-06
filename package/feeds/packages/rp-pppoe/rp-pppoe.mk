# Recipe extension for package : rp-pppoe-relay

RP-PPPOE:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

define rp-pppoe-relay_install_append
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface/
	$(INSTALL_DATA) $(RP-PPPOE)/files/pppoe.hotplug $(1)/etc/hotplug.d/iface/65-pppoe
endef

Package/rp-pppoe-relay/install += $(newline)$(rp-pppoe-relay_install_append)
