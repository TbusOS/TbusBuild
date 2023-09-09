DEMO_VERSION:= 1.0.0
DEMO_SOURCE=
DEMO_OVERRIDE_SRCDIR = $(DEMO_PKGDIR)/src

define DEMO_BUILD_CMDS
	CC=$(TARGET_CC) make -C $(@D)
endef

define DEMO_INSTALL_TARGET_CMDS
	cp $(@D)/demo $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
