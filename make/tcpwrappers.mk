#############################################################
#
# tcp_wrappers
#
#############################################################

TCPWRAPPERS_DIR:=$(BUILD_DIR)/tcpwrappers

TCPWRAPPERS_VERSION=7.6
TCPWRAPPERS=tcp_wrappers_$(TCPWRAPPERS_VERSION)
TCPWRAPPERS_SITE=ftp://ftp.porcupine.org/pub/security/
TCPWRAPPERS_SOURCE:=$(TCPWRAPPERS).tar.gz
TCPWRAPPERS_UNZIP=zcat
TCPWRAPPERS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TCPWRAPPERS_SECTION=net
TCPWRAPPERS_PRIORITY=optional
TCPWRAPPERS_DESCRIPTION=A library that allows IP level control over ports

TCPWRAPPERS_IPK_VERSION=5

TCPWRAPPERS_IPK=$(BUILD_DIR)/tcpwrappers_$(TCPWRAPPERS_VERSION)-$(TCPWRAPPERS_IPK_VERSION)_$(TARGET_ARCH).ipk
TCPWRAPPERS_IPK_DIR:=$(BUILD_DIR)/tcpwrappers-$(TCPWRAPPERS_VERSION)-ipk
TCPWRAPPERS_PATCH=$(SOURCE_DIR)/tcpwrappers.patch

.PHONY: tcpwrappers-source tcpwrappers-unpack tcpwrappers tcpwrappers-stage tcpwrappers-ipk tcpwrappers-clean tcpwrappers-dirclean tcpwrappers-check

$(DL_DIR)/$(TCPWRAPPERS_SOURCE):
	$(WGET) -P $(DL_DIR) $(TCPWRAPPERS_SITE)/$(TCPWRAPPERS_SOURCE)

tcpwrappers-source: $(DL_DIR)/$(TCPWRAPPERS_SOURCE)

$(TCPWRAPPERS_DIR)/.configured: $(DL_DIR)/$(TCPWRAPPERS_SOURCE) make/tcpwrappers.mk
	@rm -rf $(BUILD_DIR)/$(TCPWRAPPERS) $(TCPWRAPPERS_DIR)
	$(TCPWRAPPERS_UNZIP) $(DL_DIR)/$(TCPWRAPPERS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TCPWRAPPERS) $(TCPWRAPPERS_DIR)
	$(PATCH) -d $(TCPWRAPPERS_DIR) < $(TCPWRAPPERS_PATCH)
	sed -ie '/char \*malloc()/d' $(TCPWRAPPERS_DIR)/scaffold.c
	touch $(TCPWRAPPERS_DIR)/.configured

tcpwrappers-unpack: $(TCPWRAPPERS_DIR)/.configured

$(TCPWRAPPERS_DIR)/.built: $(TCPWRAPPERS_DIR)/.configured
	rm -f $@
	make -C $(TCPWRAPPERS_DIR) \
		CC="$(TARGET_CC) -fPIC" AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) \
		REAL_DAEMON_DIR=/dev/null \
		linux
	touch $@

tcpwrappers: $(TCPWRAPPERS_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TCPWRAPPERS_DIR)/.staged: $(TCPWRAPPERS_DIR)/.built
	rm -f $@
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(TCPWRAPPERS_DIR)/tcpd.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(TCPWRAPPERS_DIR)/libwrap.a $(STAGING_LIB_DIR)
	touch $@

tcpwrappers-stage: $(TCPWRAPPERS_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tcpwrappers
#
$(TCPWRAPPERS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: tcpwrappers" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TCPWRAPPERS_PRIORITY)" >>$@
	@echo "Section: $(TCPWRAPPERS_SECTION)" >>$@
	@echo "Version: $(TCPWRAPPERS_VERSION)-$(TCPWRAPPERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TCPWRAPPERS_MAINTAINER)" >>$@
	@echo "Source: $(TCPWRAPPERS_SITE)/$(TCPWRAPPERS_SOURCE)" >>$@
	@echo "Description: $(TCPWRAPPERS_DESCRIPTION)" >>$@
	@echo "Depends: $(TCPWRAPPERS_DEPENDS)" >>$@
	@echo "Conflicts: $(TCPWRAPPERS_CONFLICTS)" >>$@

$(TCPWRAPPERS_IPK): $(TCPWRAPPERS_DIR)/.built
	rm -rf $(TCPWRAPPERS_IPK_DIR) $(BUILD_DIR)/tcpwrappers_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(TCPWRAPPERS_IPK_DIR)/CONTROL
	$(INSTALL) -d $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -d $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -d $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/man/man3
	$(INSTALL) -d $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/man/man5
	$(INSTALL) -d $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/man/man8
	$(INSTALL) -d $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/libexec
	$(MAKE) $(TCPWRAPPERS_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(TCPWRAPPERS_DIR)/tcpd  $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/libexec
	$(INSTALL) -m 755 $(TCPWRAPPERS_DIR)/tcpdchk $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -m 755 $(TCPWRAPPERS_DIR)/tcpdmatch $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -m 755 $(TCPWRAPPERS_DIR)/tcpd*.8 $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/man/man8
	$(INSTALL) -m 755 $(TCPWRAPPERS_DIR)/hosts_access.3 $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/man/man3
	$(INSTALL) -m 755 $(TCPWRAPPERS_DIR)/hosts_access.5 $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/man/man5
	$(INSTALL) -m 755 $(TCPWRAPPERS_DIR)/libwrap.a $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/libexec/tcpd \
			 $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/sbin/tcpdchk \
			 $(TCPWRAPPERS_IPK_DIR)$(TARGET_PREFIX)/sbin/tcpdmatch
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TCPWRAPPERS_IPK_DIR)

tcpwrappers-ipk: $(TCPWRAPPERS_IPK)

tcpwrappers-clean:
	-make -C $(TCPWRAPPER_DIR) clean

tcpwrappers-dirclean:
	rm -rf $(TCPWRAPPERS_DIR) $(TCPWRAPPERS_IPK_DIR) $(TCPWRAPPERS_IPK)

#
# Some sanity check for the package.
#
tcpwrappers-check: $(TCPWRAPPERS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TCPWRAPPERS_IPK)
