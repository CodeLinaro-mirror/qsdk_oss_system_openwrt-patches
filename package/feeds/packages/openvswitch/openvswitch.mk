# Recipe extension for package : openvswitch

define openvswitch_install_append
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenvswitch*.so*  $(1)/usr/lib/
endef

Build/InstallDev += $(newline)$(openvswitch_install_append)

