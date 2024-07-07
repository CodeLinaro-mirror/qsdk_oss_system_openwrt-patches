# Recipe extension for package : wifi-scripts

ifeq ($(CONFIG_PACKAGE_kmod-ath11k)$(CONFIG_PACKAGE_kmod-ath12k),)
define wifi-scripts_install_append
	rm -rf $(1)/lib/wifi/mac80211.sh
	rm -rf $(1)/lib/netifd/hostapd.sh
endef
endif

Package/wifi-scripts/install += $(newline)$(wifi-scripts_install_append)

