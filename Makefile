TOPDIR := $(CURDIR)

BUILD_ROOT_VERSION ?= 2023.02.3

ifndef HOSTCC
HOSTCC := gcc
HOSTCC := $(shell which $(HOSTCC) || type -p $(HOSTCC) || echo gcc)
endif
ifndef HOSTCC_NOCCACHE
HOSTCC_NOCCACHE := $(HOSTCC)
endif

HOSTCC_MAX_VERSION := 9

HOSTCC_VERSION := $(shell V=$$($(HOSTCC_NOCCACHE) --version | \
	sed -n -r 's/^.* ([0-9]*)\.([0-9]*)\.([0-9]*)[ ]*.*/\1 \2/p'); \
	[ "$${V%% *}" -le $(HOSTCC_MAX_VERSION) ] || V=$(HOSTCC_MAX_VERSION); \
	printf "%s" "$${V}")

ifneq ($(firstword $(HOSTCC_VERSION)),4)
HOSTCC_VERSION := $(firstword $(HOSTCC_VERSION))
endif

BUILD_DIR:= $(TOPDIR)/output/tbus_build_output/build

BASE_DIR=$(TOPDIR)/output/tbus_build_output

CONFIG_CONFIG_IN = ConfigTbusBuild.in

BR2_CONFIG = $(TOPDIR)/.config

noconfig_targets := %_tbus_build_defconfig tbus_build_menuconfig

ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
-include $(BR2_CONFIG)
endif

COMMON_CONFIG_ENV = \
	BR2_DEFCONFIG='$(call qstrip,$(value BR2_DEFCONFIG))' \
	KCONFIG_AUTOCONFIG=$(BUILD_DIR)/buildroot-config/auto.conf \
	KCONFIG_AUTOHEADER=$(BUILD_DIR)/buildroot-config/autoconf.h \
	KCONFIG_TRISTATE=$(BUILD_DIR)/buildroot-config/tristate.config \
	BR2_CONFIG=$(BR2_CONFIG) \
	HOST_GCC_VERSION="$(HOSTCC_VERSION)" \
	BASE_DIR=$(BASE_DIR) \
	SKIP_LEGACY=

%_tbus_build_defconfig: $(BUILD_DIR)/buildroot-config/conf
	defconfig=$(or \
		$(firstword \
			$(foreach d, \
				$(TOPDIR), \
				$(wildcard $(d)/configs/tbus_build/$@) \
			) \
		), \
		$(error "Can't find $@") \
	); \
	$(COMMON_CONFIG_ENV) BR2_DEFCONFIG=$${defconfig} \
		$< --defconfig=$${defconfig} $(CONFIG_CONFIG_IN)

tbus_build_menuconfig: patch $(BUILD_DIR)/buildroot-config/mconf
	$(COMMON_CONFIG_ENV) $(BUILD_DIR)/buildroot-config/mconf $(CONFIG_CONFIG_IN)

make_into_buildroot:patch
	@make BR2_EXTERNAL=../ $(tar) -C $(TOPDIR)/buildroot-$(BUILD_ROOT_VERSION)

%:
	@case "$@" in \
		"all") \
			echo "Unsupported command"; \
			;; \
		"V="*) \
			echo "Unsupported command"; \
			;; \
		"O="*) \
			echo "Unsupported command"; \
			;; \
		"sdk") \
			echo "Unsupported command"; \
			;; \
		$(TOPDIR)/.config) \
			;; \
		"diff") \
			;; \
		"patch") \
			;; \
		"unzip") \
			;; \
		"download") \
			;; \
		"remove") \
			;; \
		*"_tbus_build_defconfig") \
			;; \
		"tbus_build_menuconfig") \
			;; \
		*) make make_into_buildroot tar=$@ ;; \
	esac; \

CONFIG = support/kconfig

$(BUILD_DIR)/buildroot-config/%onf:
	mkdir -p $(@D)/lxdialog
	PKG_CONFIG_PATH="$(HOST_PKG_CONFIG_PATH)" $(MAKE) CC="$(HOSTCC_NOCCACHE)" HOSTCC="$(HOSTCC_NOCCACHE)" \
	    obj=$(@D) -C $(CONFIG) -f Makefile.br $(@F)

download:
	@if [ ! -f "$(TOPDIR)/dl/buildroot-$(BUILD_ROOT_VERSION).tar.gz" ]; then \
		mkdir -p $(TOPDIR)/dl; \
		cd $(TOPDIR)/dl; \
		wget https://buildroot.org/downloads/buildroot-$(BUILD_ROOT_VERSION).tar.gz; \
	fi

unzip:download
	@if [ ! -d "$(TOPDIR)/buildroot-$(BUILD_ROOT_VERSION)" ]; then \
		tar zxvf $(TOPDIR)/dl/buildroot-$(BUILD_ROOT_VERSION).tar.gz -C $(TOPDIR); \
	fi

patch:unzip
	@if [ ! -f "$(TOPDIR)/buildroot-$(BUILD_ROOT_VERSION)/.$@" ]; then \
		./scripts/diff_patch.sh --patch $(BUILD_ROOT_VERSION); \
		touch $(TOPDIR)/buildroot-$(BUILD_ROOT_VERSION)/.$@; \
	fi

diff:unzip
	rm -f $(TOPDIR)/patches/*
	./scripts/diff_patch.sh --diff $(BUILD_ROOT_VERSION)

remove:
	rm -rf $(TOPDIR)/buildroot-$(BUILD_ROOT_VERSION)
	rm -rf $(TOPDIR)/output
	rm -rf $(TOPDIR)/dl
	rm -f $(TOPDIR)/.config
	rm -f $(TOPDIR)/.config.old

platform:patch
	$(TOPDIR)/scripts/parse_config.sh platform $(TOPDIR)/output/.config $(TOPDIR)/.config

platform_all_clean:patch
	$(TOPDIR)/scripts/parse_config.sh platform_all_clean $(TOPDIR)/output/.config

app:patch
	$(TOPDIR)/scripts/parse_config.sh app $(TOPDIR)/output/.config

app_clean:patch
	$(TOPDIR)/scripts/parse_config.sh app_clean $(TOPDIR)/output/.config

driver:patch
	$(TOPDIR)/scripts/parse_config.sh driver $(TOPDIR)/output/.config

driver_clean:patch
	$(TOPDIR)/scripts/parse_config.sh driver_clean $(TOPDIR)/output/.config

tools:patch
	$(TOPDIR)/scripts/parse_config.sh tools $(TOPDIR)/output/.config

tools_clean:patch
	$(TOPDIR)/scripts/parse_config.sh tools_clean $(TOPDIR)/output/.config

.DEFAULT_GOAL := help

help:
	@echo ' TbusBuild: '
	@echo '	make diff                  - Compare the source code extracted from buildroot-$$(BUILD_ROOT_VERSION)'
	@echo '									and buildroot-$$(BUILD_ROOT_VERSION).tar.gz in the current directory, and generate patches into patches.'
	@echo '	make patch                 - patch *. patches under the patches directory into buildroot-$$(BUILD_ROOT_VERSION)'
	@echo '	make unzip                 - Unzip buildroot-$$(BUILD_ROOT_VERSION)'
	@echo '	make remove                - Delete the buildroot-$$(BUILD_ROOT_VERSION) directory'
	@echo '	make download              - download buildroot-$$(BUILD_ROOT_VERSION).tar.gz'
	@echo '	make tbus_build_menuconfig - open TbusBuild menuconfig'
	@echo '	make <defconfig name>      - selete TbusBuild defconfig in $(TOPDIR)/tbus_build'
	@echo '	make platform              - Build and pack the <pkg> of your choice for the platform of your choice'
	@echo '	make platform_all_clean    - remove <pkg> of all platform build directory'
	@echo '	make app                   - compile and pack the <pkg> of your choice for the app'
	@echo '	make app_clean             - remove <pkg> of app build directory'
	@echo '	make driver            	   - compile and pack the <pkg> of your choice for the driver'
	@echo '	make driver_clean      	   - remove <pkg> of driver build directory'
	@echo '	make tools            	   - compile and pack the <pkg> of your choice for the tools'
	@echo '	make tools_clean      	   - remove <pkg> of tools build directory'

	@echo ' Buildroot: '
	@echo '	make clean                 - delete all files created by build'
	@echo '	make distclean             - delete all non-source files (including .config)'
	@echo '	make toolchain             - build toolchain'
	@echo '	make menuconfig            - interactive curses-based configurator'
	@echo '	make oldconfig             - resolve any unresolved symbols in .config'
	@echo '	syncconfig             	  - Same as oldconfig, but quietly, additionally update deps'
	@echo '	olddefconfig           	  - Same as syncconfig but sets new symbols to their default value'
	@echo '	randconfig             	  - New config with random answer to all options'
	@echo '	defconfig              	  - New config with default answer to all options;'
	@echo '	                       	        BR2_DEFCONFIG, if set on the command line, is used as input'
	@echo '	savedefconfig          	  - Save current config to BR2_DEFCONFIG (minimal config)'
	@echo '	update-defconfig       	  - Same as savedefconfig'
	@echo '	allyesconfig           	  - New config where all options are accepted with yes'
	@echo '	allnoconfig            	  - New config where all options are answered with no'
	@echo '	alldefconfig           	  - New config where all options are set to default'
	@echo '	randpackageconfig      	  - New config with random answer to package options'
	@echo '	allyespackageconfig    	  - New config where pkg options are accepted with yes'
	@echo '	allnopackageconfig     	  - New config where package options are answered with no'
	@echo '	<pkg>                  	  - Build and install <pkg> and all its dependencies'
	@echo '	<pkg>-auto            	  - Build and install and pack <pkg> and all its dependencies'
	@echo '	<pkg>-pack-module     	  - install module to $(TOPDIR)/output/module/<pkg>/$(LINUX_VERSION)/*.ko'
	@echo '	<pkg>-pack-clean      	  - clean module'
	@echo '	<pkg>-source           	  - Only download the source files for <pkg>'
	@echo '	<pkg>-extract          	  - Extract <pkg> sources'
	@echo '	<pkg>-patch            	  - Apply patches to <pkg>'
	@echo '	<pkg>-depends          	  - Build <pkg>'\''s dependencies'
	@echo '	<pkg>-configure        	  - Build <pkg> up to the configure step'
	@echo '	<pkg>-build            	  - Build <pkg> up to the build step'
	@echo '	<pkg>-show-info        	  - generate info about <pkg>, as a JSON blurb'
	@echo '	<pkg>-show-depends     	  - List packages on which <pkg> depends'
	@echo '	<pkg>-show-rdepends    	  - List packages which have <pkg> as a dependency'
	@echo '	<pkg>-show-recursive-depends'
	@echo '	                       	  - Recursively list packages on which <pkg> depends'
	@echo '	<pkg>-show-recursive-rdepends'
	@echo '	                           - Recursively list packages which have <pkg> as a dependency'
	@echo '	<pkg>-graph-depends    	  - Generate a graph of <pkg>'\''s dependencies'
	@echo '	<pkg>-graph-rdepends   	  - Generate a graph of <pkg>'\''s reverse dependencies'
	@echo '	<pkg>-dirclean         	  - Remove <pkg> build directory'
	@echo '	<pkg>-reconfigure      	  - Restart the build from the configure step'
	@echo '	<pkg>-rebuild          	  - Restart the build from the build step'
	@echo '	<pkg>-reinstall        	  - Restart the build from the install step'
	@echo '	Documentation:'
	@echo '	manual                 	  - build manual in all formats'
	@echo '	manual-html            	  - build manual in HTML'
	@echo '	manual-split-html      	  - build manual in split HTML'
	@echo '	manual-pdf             	  - build manual in PDF'
	@echo '	manual-text            	  - build manual in text'
	@echo '	manual-epub            	  - build manual in ePub'
	@echo '	graph-build            	  - generate graphs of the build times'
	@echo '	graph-depends          	  - generate graph of the dependency tree'
	@echo '	graph-size             	  - generate stats of the filesystem size'
	@echo '	list-defconfigs        	  - list all defconfigs (pre-configured minimal systems)'
	@echo
	@echo '	Miscellaneous:'
	@echo '	source                 	  - download all sources needed for offline-build'
	@echo '	external-deps          	  - list external packages used'
	@echo '	legal-info             	  - generate info about license compliance'
	@echo '	show-info              	  - generate info about packages, as a JSON blurb'
	@echo '	pkg-stats              	  - generate info about packages as JSON and HTML'
	@echo '	missing-cpe            	  - generate XML snippets for missing CPE identifiers'
	@echo '	printvars              	  - dump internal variables selected with VARS=...'
	@echo '	show-vars              	  - dump all internal variables as a JSON blurb; use VARS=...'
	@echo '	                           to limit the list to variables names matching that pattern'

.PHONY: % \
		download \
		unzip \
		patch \
		diff \
		tbus_build_menuconfig \
		%_tbus_build_defconfig \
		remove \
		platform \
		platform_all_clean \
		app \
		app_clean \
		driver \
		driver_clean \
		tools \
		tools_clean \
		help
