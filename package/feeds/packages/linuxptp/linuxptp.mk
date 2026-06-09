# Recipe extension for package : linuxptp

LINUXPTP:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

define linuxptp_install_append
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/firewall.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DATA) $(LINUXPTP)/files/ptp.uci.config $(1)/etc/config/ptp
	$(INSTALL_BIN) $(LINUXPTP)/files/ptp.init $(1)/etc/init.d/ptp
	$(INSTALL_BIN) $(LINUXPTP)/files/ptp-sequencer $(1)/usr/sbin/ptp-sequencer
	$(INSTALL_BIN) $(LINUXPTP)/files/ptp-phc-map $(1)/usr/sbin/ptp-phc-map
	$(INSTALL_BIN) $(LINUXPTP)/files/ptp.firewall $(1)/etc/firewall.d/ptp
	$(INSTALL_DATA) $(LINUXPTP)/files/ptp.defaults $(1)/etc/uci-defaults/99-ptp
endef

Package/linuxptp/install += $(newline)$(linuxptp_install_append)
