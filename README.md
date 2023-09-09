# TbusBuild
一个开源的作为Linux驱动，Linux应用开发，调试的开源编译框架

## Quickstart

要构建和使用TbusBuild，请执行以下操作:

1. 'make ori_tbus_build_defconfig' 选择TbusBuild默认config.
2. 'make buildroot_defconfig' 选择buildroot默认config.
3. 'make <pkg>' 编译pkg.

## Tip

1. 如果增加了新的pkg, 请在$(TOPDIR)/platform/[platform_name]/package/Config.in文件中的BR2_SELECT_ALL_[PLATFORM_NAME]中增加对应的select.

2. 如果你要编译内核module，你可以选择以下两种方式选择内核路径.

    - 依赖外部的内核路径

      make menuconfig;

      ​	External options  --->

      ​		()externel linux kernel dir

    - 使用buildroot的内核

      make menuconfig;

      ​	Kernel  --->

      ​		[ ] Linux Kernel

## Usage

### TbusBuild

make download							- 下载buildroot-$(BUILD_ROOT_VERSION).tar.gz

make unzip									- 解压buildroot-$(BUILD_ROOT_VERSION).tar.gz

make patch									- 将$(TOPDIR)/patches目录下的patch打入buildroot-$(BUILD_ROOT_VERSION)

make [defconfig name]				- 选择TbusBuild的defconfig

make diff										-  比较buildroot-$(BUILD_ROOT_VERSION)目录和buildroot-$(BUILD_ROOT VERSION).tar.gz源码包中源码的区别, 然后将patch生成到$(TOPDIR)/patches目录下.

make tbus_build_menuconfig	- 打开TbusBuild的menuconfig

make [platform_name]				- 编译对应platform(app, driver or tools)中选中的pkg

make platform_all_clean			 - 将全部platform的编译过程中的中间文件、目标文件及文件夹删除

make remove                   - 将$(TOPDIR)/buildroot-$(BUILD_ROOT_VERSION), $(TOPDIR)/dl, $(TOPDIR)/output, $(TOPDIR)/.config, $(TOPDIR)/.config.old删除


### Buildroot

make clean        	 - delete all files created by build

make distclean       - delete all non-source files (including .config)

make toolchain       - build toolchain

#### How to use config

make menuconfig      	 - interactive curses-based configurator

make oldconfig       		- resolve any unresolved symbols in .config

make syncconfig       	  - Same as oldconfig, but quietly, additionally update deps

make olddefconfig      	- Same as syncconfig but sets new symbols to their default value

make randconfig       	  - New config with random answer to all options

make defconfig       		- New config with default answer to all options; BR2_DEFCONFIG, if set on the command line, is used as input

make savedefconfig        - Save current config to BR2_DEFCONFIG (minimal config)

make update-defconfig    - Same as savedefconfig

make allyesconfig      		- New config where all options are accepted with yes

make allnoconfig      		- New config where all options are answered with no

make alldefconfig      		- New config where all options are set to default

make randpackageconfig   - New config with random answer to package options

make allyespackageconfig  - New config where pkg options are accepted with yes

make allnopackageconfig   - New config where package options are answered with no

#### How to use packages

make <pkg>         - Build and install <pkg> and all its dependencies

make <pkg>-auto       - [Custom] Build and install and pack <pkg> and all its dependencies

make <pkg>-pack-module   - [Custom] install module to $(TOPDIR)/output/module/<pkg>/$(LINUX_VERSION)/*.ko

make <pkg>-pack-clean    - [Custom] clean module

make <pkg>-source      - Only download the source files for <pkg>

make <pkg>-extract     - Extract <pkg> sources

make <pkg>-patch      - Apply patches to <pkg>

make <pkg>-depends     - Build <pkg>'\''s dependencies

make <pkg>-configure    - Build <pkg> up to the configure step

make <pkg>-build      - Build <pkg> up to the build step

make <pkg>-show-info    - generate info about <pkg>, as a JSON blurb

make <pkg>-show-depends   - List packages on which <pkg> depends

make <pkg>-show-rdepends  - List packages which have <pkg> as a dependency

make <pkg>-show-recursive-depends

​              \- Recursively list packages on which <pkg> depends

make <pkg>-show-recursive-rdepends

​              \- Recursively list packages which have <pkg> as a dependency

make <pkg>-graph-depends   - Generate a graph of <pkg>'\''s dependencies

make <pkg>-graph-rdepends  - Generate a graph of <pkg>'\''s reverse dependencies

make <pkg>-dirclean     - Remove <pkg> build directory

make <pkg>-reconfigure    - Restart the build from the configure step

make <pkg>-rebuild      - Restart the build from the build step

make <pkg>-reinstall     - Restart the build from the install step

### Documentation

make manual         - build manual in all formats

make manual-html       - build manual in HTML

make manual-split-html    - build manual in split HTML

make manual-pdf       - build manual in PDF

make manual-text       - build manual in text

make manual-epub       - build manual in ePub

make graph-build       - generate graphs of the build times

make graph-depends      - generate graph of the dependency tree

make graph-size       - generate stats of the filesystem size

make list-defconfigs     - list all defconfigs (pre-configured minimal systems)

make source         - download all sources needed for offline-build

make external-deps      - list external packages used

make legal-info       - generate info about license compliance

make show-info        - generate info about packages, as a JSON blurb

make pkg-stats        - generate info about packages as JSON and HTML

make missing-cpe       - generate XML snippets for missing CPE identifiers

make printvars        - dump internal variables selected with VARS=...

make show-vars        - dump all internal variables as a JSON blurb; use VARS=...

​             to limit the list to variables names matching that pattern
