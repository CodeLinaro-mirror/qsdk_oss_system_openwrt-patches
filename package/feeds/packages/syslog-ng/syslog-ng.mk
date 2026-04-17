# Recipe extension for syslog-ng

SYSLOG_NG:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

define syslog-ng_append
	DEPENDS+=+PACKAGE_logstreamer:librdkafka +PACKAGE_logstreamer_open:librdkafka
endef

define syslog-ng_install_append
	$(INSTALL_DIR) $(1)/etc/syslog-ng.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DATA) $(SYSLOG_NG)/files/kfence.conf $(1)/etc/syslog-ng.d/kfence.conf
	$(INSTALL_BIN) $(SYSLOG_NG)/files/kfence-handler.sh $(1)/usr/sbin/kfence-handler.sh
endef

ifdef CONFIG_PACKAGE_logstreamer
	CONFIGURE_ARGS += \
			  --enable-kafka=yes
else ifdef CONFIG_PACKAGE_logstreamer_open
	CONFIGURE_ARGS += \
			  --enable-kafka=yes
endif

Package/syslog-ng += $(newline)$(syslog-ng_append)
Package/syslog-ng/install += $(newline)$(syslog-ng_install_append)
