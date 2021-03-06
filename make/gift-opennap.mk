###########################################################
#
# gift-opennap
#
###########################################################

#
# GIFT_OPENNAP_VERSION, GIFT_OPENNAP_REPOSITORY and GIFT_OPENNAP_SOURCE define
# the upstream location of the source code for the package.
# GIFT_OPENNAP_DIR is the directory which is created when the source
# archive is unpacked.
# GIFT_OPENNAP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFT_OPENNAP_REPOSITORY=:pserver:anonymous@cvs.gift-opennap.berlios.de:/cvsroot/gift-opennap
GIFT_OPENNAP_SITE=$(SOURCES_NLO_SITE)
GIFT_OPENNAP_VERSION=20050212
GIFT_OPENNAP_SOURCE=gift-opennap-$(GIFT_OPENNAP_VERSION).tar.gz
GIFT_OPENNAP_TAG=-D 2005-02-12
GIFT_OPENNAP_MODULE=giFT-OpenNap 
GIFT_OPENNAP_DIR=gift-opennap-$(GIFT_OPENNAP_VERSION)
GIFT_OPENNAP_UNZIP=zcat
GIFT_OPENNAP_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
GIFT_OPENNAP_SECTION=net
GIFT_OPENNAP_PRIORITY=optional
GIFT_OPENNAP_DEPENDS=gift, zlib
GIFT_OPENNAP_DESCRIPTION=gIFt opennap plugin

#
# GIFT_OPENNAP_IPK_VERSION should be incremented when the ipk changes.
#
GIFT_OPENNAP_IPK_VERSION=2

#
# GIFT_OPENNAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GIFT_OPENNAP_PATCHES=$(GIFT_OPENNAP_SOURCE_DIR)/patch.PATH

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFT_OPENNAP_CPPFLAGS=
GIFT_OPENNAP_LDFLAGS=

#
# GIFT_OPENNAP_BUILD_DIR is the directory in which the build is done.
# GIFT_OPENNAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFT_OPENNAP_IPK_DIR is the directory in which the ipk is built.
# GIFT_OPENNAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFT_OPENNAP_BUILD_DIR=$(BUILD_DIR)/gift-opennap
GIFT_OPENNAP_SOURCE_DIR=$(SOURCE_DIR)/gift-opennap
GIFT_OPENNAP_IPK_DIR=$(BUILD_DIR)/gift-opennap-$(GIFT_OPENNAP_VERSION)-ipk
GIFT_OPENNAP_IPK=$(BUILD_DIR)/gift-opennap_$(GIFT_OPENNAP_VERSION)-$(GIFT_OPENNAP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from cvs.
#
#$(DL_DIR)/$(GIFT_OPENNAP_SOURCE):
#	cd $(DL_DIR) ; $(CVS) -z3 -d $(GIFT_OPENNAP_REPOSITORY) co $(GIFT_OPENNAP_TAG) $(GIFT_OPENNAP_MODULE)
#	mv $(DL_DIR)/$(GIFT_OPENNAP_MODULE) $(DL_DIR)/$(GIFT_OPENNAP_DIR)
#	cd $(DL_DIR) ; tar zcvf $(GIFT_OPENNAP_SOURCE) $(GIFT_OPENNAP_DIR)
#	rm -rf $(DL_DIR)/$(GIFT_OPENNAP_DIR)

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIFT_OPENNAP_SOURCE):
	$(WGET) -P $(@D) $(GIFT_OPENNAP_SITE)/$(@F)



#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-opennap-source: $(DL_DIR)/$(GIFT_OPENNAP_SOURCE) $(GIFT_OPENNAP_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
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
$(GIFT_OPENNAP_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFT_OPENNAP_SOURCE) $(GIFT_OPENNAP_PATCHES) \
make/gift-opennap.mk
	$(MAKE) gift-stage
	$(HOST_TOOL_AUTOMAKE1.10)
	rm -rf $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) $(@D)
	$(GIFT_OPENNAP_UNZIP) $(DL_DIR)/$(GIFT_OPENNAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GIFT_OPENNAP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) -p1
	mv $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) $(GIFT_OPENNAP_BUILD_DIR)
	echo 'ACLOCAL_AMFLAGS = -I m4' >> $(@D)/Makefile.am
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFT_OPENNAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFT_OPENNAP_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--enable-shared \
	)
	touch $@

gift-opennap-unpack: $(GIFT_OPENNAP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GIFT_OPENNAP_BUILD_DIR)/.built: $(GIFT_OPENNAP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GIFT_OPENNAP_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gift-opennap: $(GIFT_OPENNAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_LIB_DIR)/libgift-opennap.so.$(GIFT_OPENNAP_VERSION): $(GIFT_OPENNAP_BUILD_DIR)/.built
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(GIFT_OPENNAP_BUILD_DIR)/gift-opennap.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(GIFT_OPENNAP_BUILD_DIR)/libgift-opennap.a $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(GIFT_OPENNAP_BUILD_DIR)/libgift-opennap.so.$(GIFT_OPENNAP_VERSION) $(STAGING_LIB_DIR)
	cd $(STAGING_LIB_DIR) && ln -fs libgift-opennap.so.$(GIFT_OPENNAP_VERSION) libgift-opennap.so.1
	cd $(STAGING_LIB_DIR) && ln -fs libgift-opennap.so.$(GIFT_OPENNAP_VERSION) libgift-opennap.so

gift-opennap-stage: $(STAGING_LIB_DIR)/libgift-opennap.so.$(GIFT_OPENNAP_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gift-opennap
#
$(GIFT_OPENNAP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gift-opennap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIFT_OPENNAP_PRIORITY)" >>$@
	@echo "Section: $(GIFT_OPENNAP_SECTION)" >>$@
	@echo "Version: $(GIFT_OPENNAP_VERSION)-$(GIFT_OPENNAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIFT_OPENNAP_MAINTAINER)" >>$@
	@echo "Source: $(GIFT_OPENNAP_SITE)/$(GIFT_OPENNAP_SOURCE)" >>$@
	@echo "Description: $(GIFT_OPENNAP_DESCRIPTION)" >>$@
	@echo "Depends: $(GIFT_OPENNAP_DEPENDS)" >>$@
	@echo "Conflicts: $(GIFT_OPENNAP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/etc/gift-opennap/...
# Documentation files should be installed in $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/doc/gift-opennap/...
# Daemon startup scripts should be installed in $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gift-opennap
#
# You may need to patch your application to make it use these locations.
#
$(GIFT_OPENNAP_IPK): $(GIFT_OPENNAP_BUILD_DIR)/.built
	rm -rf $(GIFT_OPENNAP_IPK_DIR) $(BUILD_DIR)/gift-opennap_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/lib/giFT
	$(STRIP_COMMAND) $(GIFT_OPENNAP_BUILD_DIR)/src/.libs/libOpenNap.so -o $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/lib/giFT/libOpenNap.so
	$(INSTALL) -m 644 $(GIFT_OPENNAP_BUILD_DIR)/src/.libs/libOpenNap.la $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/lib/giFT/libOpenNap.la
	$(INSTALL) -d $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/share/giFT/OpenNap
	$(INSTALL) -m 644 $(GIFT_OPENNAP_BUILD_DIR)/data/OpenNap.conf.template $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/share/giFT/OpenNap/OpenNap.conf.template
	$(INSTALL) -m 644 $(GIFT_OPENNAP_BUILD_DIR)/data/nodelist $(GIFT_OPENNAP_IPK_DIR)$(TARGET_PREFIX)/share/giFT/OpenNap/nodelist
	$(INSTALL) -d $(GIFT_OPENNAP_IPK_DIR)/CONTROL
	$(MAKE) $(GIFT_OPENNAP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFT_OPENNAP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GIFT_OPENNAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gift-opennap-ipk: $(GIFT_OPENNAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-opennap-clean:
	-$(MAKE) -C $(GIFT_OPENNAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-opennap-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) $(GIFT_OPENNAP_BUILD_DIR) $(GIFT_OPENNAP_IPK_DIR) $(GIFT_OPENNAP_IPK)
