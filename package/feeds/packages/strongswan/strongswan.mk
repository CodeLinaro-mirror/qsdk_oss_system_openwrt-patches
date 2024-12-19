#  Recipe extension for strongswan

define plugin_updown_append_install
	$(CP) $(TOPDIR)/openwrt-patches/package/feeds/packages/strongswan/files/etc/hotplug.d/ipsec/00-nss-ipsec-offload $(1)/etc/hotplug.d/ipsec/00-nss-ipsec-offload
endef

Plugin/updown/install += $(newline)$(plugin_updown_append_install)
