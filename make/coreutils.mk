###########################################################
#
# coreutils
#
###########################################################

# You must replace "coreutils" and "COREUTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# COREUTILS_VERSION, COREUTILS_SITE and COREUTILS_SOURCE define
# the upstream location of the source code for the package.
# COREUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# COREUTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
COREUTILS_SITE=http://ftp.gnu.org/pub/gnu/coreutils
COREUTILS_VERSION=8.4
COREUTILS_SOURCE=coreutils-$(COREUTILS_VERSION).tar.gz
COREUTILS_DIR=coreutils-$(COREUTILS_VERSION)
COREUTILS_UNZIP=zcat
COREUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
COREUTILS_DESCRIPTION=Bunch of heavyweight *nix core utilities
COREUTILS_SECTION=core
COREUTILS_PRIORITY=optional
COREUTILS_DEPENDS=libcap
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
COREUTILS_DEPENDS+=, libiconv
endif
ifeq (enable, $(GETTEXT_NLS))
COREUTILS_DEPENDS+=, gettext
endif
COREUTILS_CONFLICTS=

#
# COREUTILS_IPK_VERSION should be incremented when the ipk changes.
#
COREUTILS_IPK_VERSION=3

#
# COREUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
COREUTILS_PATCHES=$(COREUTILS_SOURCE_DIR)/mountlist.patch
#COREUTILS_PATCHES+=$(COREUTILS_SOURCE_DIR)/coreutils-futimens.patch

# Assume that all uclibc systems are the same
ifeq ($(LIBC_STYLE), uclibc)
ifeq ($(OPTWARE_TARGET), openwrt-brcm24)
COREUTILS_AC_CACHE=$(COREUTILS_SOURCE_DIR)/config-brcm24.cache
else
COREUTILS_AC_CACHE=$(COREUTILS_SOURCE_DIR)/config-uclibc.cache
endif
else
COREUTILS_AC_CACHE=$(COREUTILS_SOURCE_DIR)/config.cache
endif
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET),wl500g)
  COREUTILS_CPPFLAGS=-DMB_CUR_MAX=1
  COREUTILS_LDFLAGS=-lm
else
  COREUTILS_CPPFLAGS=
  COREUTILS_LDFLAGS=
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
COREUTILS_LDFLAGS+= -liconv
endif

COREUTILS_CONFIG_ENVS=\
gl_cv_func_fflush_stdin=yes \
gl_cv_func_rename_trailing_slash_bug=no \
gl_cv_func_rename_dest_exists_bug=no \

ifeq (uclibc, $(LIBC_STYLE))
# internal obstack support removed starting from uClibc-ng 1.0.21
COREUTILS_CONFIG_ENVS += ac_cv_func_obstack=no
endif

#
# COREUTILS_BUILD_DIR is the directory in which the build is done.
# COREUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# COREUTILS_IPK_DIR is the directory in which the ipk is built.
# COREUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
COREUTILS_BUILD_DIR=$(BUILD_DIR)/coreutils
COREUTILS_SOURCE_DIR=$(SOURCE_DIR)/coreutils
COREUTILS_IPK_DIR=$(BUILD_DIR)/coreutils-$(COREUTILS_VERSION)-ipk
COREUTILS_IPK=$(BUILD_DIR)/coreutils_$(COREUTILS_VERSION)-$(COREUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: coreutils-source coreutils-unpack coreutils coreutils-stage coreutils-ipk coreutils-clean coreutils-dirclean coreutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(COREUTILS_SOURCE):
	$(WGET) -P $(@D) $(COREUTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
coreutils-source: $(DL_DIR)/$(COREUTILS_SOURCE) $(COREUTILS_PATCHES)

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
$(COREUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(COREUTILS_SOURCE) $(COREUTILS_PATCHES) $(COREUTILS_AC_CACHE) make/coreutils.mk
ifeq (enable, $(GETTEXT_NLS))
	$(MAKE) gettext-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) libcap-stage
	rm -rf $(BUILD_DIR)/$(COREUTILS_DIR) $(@D)
	$(COREUTILS_UNZIP) $(DL_DIR)/$(COREUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(COREUTILS_PATCHES) | $(PATCH) -Z -d $(BUILD_DIR)/$(COREUTILS_DIR) -p1
	mv $(BUILD_DIR)/$(COREUTILS_DIR) $(@D)
	sed -i.orig -e '/gets is a security hole - use fgets instead/s|^|//|' $(@D)/lib/stdio.in.h
	cp $(COREUTILS_AC_CACHE) $(@D)/config.cache
	sed -i -e '/binPROGRAMS_INSTALL=\.\/ginstall/s|./ginstall|install|' $(@D)/src/Makefile.in
ifeq ($(OPTWARE_TARGET), ts101)
	sed -i -e "/ac_cv_func_clock_settime=/s|'yes'|'no'|" $(@D)/config.cache
	sed -i -e 's/^#ifdef POSIX_FADV_DONTNEED/#if 0/' $(@D)/src/dd.c
	touch $(@D)/man/dd.1
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(COREUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(COREUTILS_LDFLAGS)" \
		$(COREUTILS_CONFIG_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--without-gmp \
		--datarootdir=$(TARGET_PREFIX) \
		--cache-file=config.cache \
	)
	touch $@

coreutils-unpack: $(COREUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(COREUTILS_BUILD_DIR)/.built: $(COREUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(COREUTILS_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
coreutils: $(COREUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(STAGING_LIB_DIR)/libcoreutils.so.$(COREUTILS_VERSION): $(COREUTILS_BUILD_DIR)/.built
#	$(INSTALL) -d $(STAGING_INCLUDE_DIR)
#	$(INSTALL) -m 644 $(COREUTILS_BUILD_DIR)/coreutils.h $(STAGING_INCLUDE_DIR)
#	$(INSTALL) -d $(STAGING_LIB_DIR)
#	$(INSTALL) -m 644 $(COREUTILS_BUILD_DIR)/libcoreutils.a $(STAGING_LIB_DIR)
#	$(INSTALL) -m 644 $(COREUTILS_BUILD_DIR)/libcoreutils.so.$(COREUTILS_VERSION) $(STAGING_LIB_DIR)
#	cd $(STAGING_LIB_DIR) && ln -fs libcoreutils.so.$(COREUTILS_VERSION) libcoreutils.so.1
#	cd $(STAGING_LIB_DIR) && ln -fs libcoreutils.so.$(COREUTILS_VERSION) libcoreutils.so
#
#coreutils-stage: $(STAGING_LIB_DIR)/libcoreutils.so.$(COREUTILS_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/coreutils
#
$(COREUTILS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: coreutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COREUTILS_PRIORITY)" >>$@
	@echo "Section: $(COREUTILS_SECTION)" >>$@
	@echo "Version: $(COREUTILS_VERSION)-$(COREUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COREUTILS_MAINTAINER)" >>$@
	@echo "Source: $(COREUTILS_SITE)/$(COREUTILS_SOURCE)" >>$@
	@echo "Description: $(COREUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(COREUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(COREUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/etc/coreutils/...
# Documentation files should be installed in $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/doc/coreutils/...
# Daemon startup scripts should be installed in $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??coreutils
#
# You may need to patch your application to make it use these locations.
#
$(COREUTILS_IPK): $(COREUTILS_BUILD_DIR)/.built
	rm -rf $(COREUTILS_IPK_DIR) $(BUILD_DIR)/coreutils_*_$(TARGET_ARCH).ipk
	# Install binaries
	$(INSTALL) -d $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/bin
	$(MAKE) -C $(COREUTILS_BUILD_DIR) DESTDIR=$(COREUTILS_IPK_DIR) install-exec
	# copy su - can't install it as install only works for root
	cp -p $(COREUTILS_BUILD_DIR)/src/su $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/bin/su
	# Install makefiles
	$(INSTALL) -d $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/man/man1	
	$(MAKE) -C $(COREUTILS_BUILD_DIR)/man DESTDIR=$(COREUTILS_IPK_DIR) install
	$(STRIP_COMMAND) $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/bin/* $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/lib/coreutils/lib*.so
	$(MAKE) $(COREUTILS_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(COREUTILS_IPK_DIR)/CONTROL/postinst
	(echo "/bin/chown 0:0 $(TARGET_PREFIX)/bin/coreutils-su"; \
	 echo "/bin/chmod 4755 $(TARGET_PREFIX)/bin/coreutils-su"; \
	) >> $(COREUTILS_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(COREUTILS_IPK_DIR)/CONTROL/prerm
	cd $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/bin; \
	for p in *; do \
	    if test "$$p" = "["; then \
		q=coreutils-lbracket; \
	    else \
		q=coreutils-$$p; \
	    fi; \
	    mv $$p $$q; \
	    echo "update-alternatives --install '$(TARGET_PREFIX)/bin/$$p' '$$p' '$$q' 50" \
		>> $(COREUTILS_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove '$$p' '$$q'" \
		>> $(COREUTILS_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(COREUTILS_IPK_DIR)/CONTROL/postinst $(COREUTILS_IPK_DIR)/CONTROL/prerm; \
	fi
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
	$(INSTALL) -d $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(COREUTILS_SOURCE_DIR)/rc.coreutils $(COREUTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S05coreutils
	$(INSTALL) -d $(COREUTILS_IPK_DIR)/usr/bin
	ln -s $(TARGET_PREFIX)/bin/env $(COREUTILS_IPK_DIR)/usr/bin/env
endif
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COREUTILS_IPK_DIR)

$(COREUTILS_BUILD_DIR)/.ipk: $(COREUTILS_IPK)
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
coreutils-ipk: $(COREUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
coreutils-clean:
	-$(MAKE) -C $(COREUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
coreutils-dirclean:
	rm -rf $(BUILD_DIR)/$(COREUTILS_DIR) $(COREUTILS_BUILD_DIR) $(COREUTILS_IPK_DIR) $(COREUTILS_IPK)

#
# Some sanity check for the package.
#
coreutils-check: $(COREUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
