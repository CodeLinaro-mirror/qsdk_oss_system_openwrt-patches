# Recipe extension for package : wifi-scripts

EXTERNAL_FILE_DIR:=$(TOPDIR)/openwrt-patches/package/kernel/mac80211
FILE_DIR_HOSTAPD:=$(TOPDIR)/openwrt-patches/package/network/services/hostapd/

ifeq ($(CONFIG_PACKAGE_kmod-ath11k)$(CONFIG_PACKAGE_kmod-ath12k),)
define wifi-scripts_install_append
	rm -rf $(1)/lib/wifi/mac80211.sh
	rm -rf $(1)/lib/netifd/hostapd.sh
endef
else
define wifi-scripts_install_append
	$(INSTALL_DATA) $(EXTERNAL_FILE_DIR)/files/lib/wifi/mac80211.sh $(1)/lib/wifi
	$(INSTALL_BIN) $(EXTERNAL_FILE_DIR)/files/lib/netifd-wlan/wireless/mac80211.sh $(1)/lib/netifd/wireless/
	$(INSTALL_DATA) $(FILE_DIR_HOSTAPD)/files/hostapd.sh $(1)/lib/netifd/hostapd.sh
endef
endif

Package/wifi-scripts/install += $(newline)$(wifi-scripts_install_append)

