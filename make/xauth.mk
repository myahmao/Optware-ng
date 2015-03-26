###########################################################
#
# xauth
#
###########################################################

#
# XAUTH_VERSION, XAUTH_SITE and XAUTH_SOURCE define
# the upstream location of the source code for the package.
# XAUTH_DIR is the directory which is created when the source
# archive is unpacked.
#
XAUTH_SITE=http://xorg.freedesktop.org/releases/individual/app
XAUTH_SOURCE=xauth-$(XAUTH_VERSION).tar.gz
XAUTH_VERSION=1.0.9
XAUTH_DIR=xauth-$(XAUTH_VERSION)
XAUTH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XAUTH_DESCRIPTION=X authority utility
XAUTH_SECTION=utility
XAUTH_PRIORITY=optional
XAUTH_DEPENDS=x11, xau, xext, xmu

#
# XAUTH_IPK_VERSION should be incremented when the ipk changes.
#
XAUTH_IPK_VERSION=1

#
# XAUTH_CONFFILES should be a list of user-editable files
XAUTH_CONFFILES=

#
# XAUTH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XAUTH_PATCHES=$(XAUTH_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XAUTH_CPPFLAGS=
XAUTH_LDFLAGS=

#
# XAUTH_BUILD_DIR is the directory in which the build is done.
# XAUTH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XAUTH_IPK_DIR is the directory in which the ipk is built.
# XAUTH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XAUTH_BUILD_DIR=$(BUILD_DIR)/xauth
XAUTH_SOURCE_DIR=$(SOURCE_DIR)/xauth
XAUTH_IPK_DIR=$(BUILD_DIR)/xauth-$(XAUTH_VERSION)-ipk
XAUTH_IPK=$(BUILD_DIR)/xauth_$(XAUTH_VERSION)-$(XAUTH_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XAUTH_IPK_DIR)/CONTROL/control:
	@install -d $(XAUTH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xauth" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XAUTH_PRIORITY)" >>$@
	@echo "Section: $(XAUTH_SECTION)" >>$@
	@echo "Version: $(XAUTH_VERSION)-$(XAUTH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XAUTH_MAINTAINER)" >>$@
	@echo "Source: $(XAUTH_SITE)/$(XAUTH_SOURCE)" >>$@
	@echo "Description: $(XAUTH_DESCRIPTION)" >>$@
	@echo "Depends: $(XAUTH_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XAUTH_SOURCE):
	$(WGET) -P $(@D) $(XAUTH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xauth-source: $(DL_DIR)/$(XAUTH_SOURCE) $(XAUTH_PATCHES)

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(XAUTH_BUILD_DIR)/.configured: $(DL_DIR)/$(XAUTH_SOURCE) $(XAUTH_PATCHES) make/xauth.mk
	$(MAKE) xorg-macros-stage x11-stage xau-stage xext-stage xmu-stage xproto-stage
	rm -rf $(BUILD_DIR)/$(XAUTH_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XAUTH_SOURCE)
	if test -n "$(XAUTH_PATCHES)" ; \
		then cat $(XAUTH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XAUTH_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XAUTH_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XAUTH_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XAUTH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XAUTH_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $@

xauth-unpack: $(XAUTH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XAUTH_BUILD_DIR)/.built: $(XAUTH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xauth: $(XAUTH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XAUTH_BUILD_DIR)/.staged: $(XAUTH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

xauth-stage: $(XAUTH_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XAUTH_IPK_DIR)/opt/sbin or $(XAUTH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XAUTH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XAUTH_IPK_DIR)/opt/etc/xauth/...
# Documentation files should be installed in $(XAUTH_IPK_DIR)/opt/doc/xauth/...
# Daemon startup scripts should be installed in $(XAUTH_IPK_DIR)/opt/etc/init.d/S??xauth
#
# You may need to patch your application to make it use these locations.
#
$(XAUTH_IPK): $(XAUTH_BUILD_DIR)/.built
	rm -rf $(XAUTH_IPK_DIR) $(BUILD_DIR)/xauth_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XAUTH_BUILD_DIR) DESTDIR=$(XAUTH_IPK_DIR) install-strip
	install -d $(XAUTH_IPK_DIR)/opt/X11R6/X11
	ln -s /opt/bin/xauth $(XAUTH_IPK_DIR)/opt/X11R6/X11/xauth
	$(MAKE) $(XAUTH_IPK_DIR)/CONTROL/control
#	install -m 644 $(XAUTH_SOURCE_DIR)/postinst $(XAUTH_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XAUTH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xauth-ipk: $(XAUTH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xauth-clean:
	-$(MAKE) -C $(XAUTH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xauth-dirclean:
	rm -rf $(BUILD_DIR)/$(XAUTH_DIR) $(XAUTH_BUILD_DIR) $(XAUTH_IPK_DIR) $(XAUTH_IPK)
