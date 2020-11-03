# Recipe extension for resolveip

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -Wall $(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/resolveip $(PKG_BUILD_DIR)/resolveip.c
endef
