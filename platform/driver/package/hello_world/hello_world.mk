HELLO_WORLD_VERSION = 1.0.0
HELLO_WORLD_SOURCE=
HELLO_WORLD_OVERRIDE_SRCDIR = $(HELLO_WORLD_PKGDIR)/src

$(eval $(kernel-module))
$(eval $(generic-package))