###########################################################
#
# perl-digest-perl-md5
#
###########################################################

PERL-DIGEST-PERL-MD5_SITE=http://search.cpan.org/CPAN/authors/id/D/DE/DELTA
PERL-DIGEST-PERL-MD5_VERSION=1.8
PERL-DIGEST-PERL-MD5_SOURCE=Digest-Perl-MD5-$(PERL-DIGEST-PERL-MD5_VERSION).tar.gz
PERL-DIGEST-PERL-MD5_DIR=Digest-Perl-MD5-$(PERL-DIGEST-PERL-MD5_VERSION)
PERL-DIGEST-PERL-MD5_UNZIP=zcat
PERL-DIGEST-PERL-MD5_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DIGEST-PERL-MD5_DESCRIPTION=Digest-Perl-MD5 - Perl implementation of Ron Rivests MD5 Algorithm 
PERL-DIGEST-PERL-MD5_SECTION=util
PERL-DIGEST-PERL-MD5_PRIORITY=optional
PERL-DIGEST-PERL-MD5_DEPENDS=perl
PERL-DIGEST-PERL-MD5_SUGGESTS=
PERL-DIGEST-PERL-MD5_CONFLICTS=

PERL-DIGEST-PERL-MD5_IPK_VERSION=1

PERL-DIGEST-PERL-MD5_CONFFILES=

PERL-DIGEST-PERL-MD5_BUILD_DIR=$(BUILD_DIR)/perl-digest-perl-md5
PERL-DIGEST-PERL-MD5_SOURCE_DIR=$(SOURCE_DIR)/perl-digest-perl-md5
PERL-DIGEST-PERL-MD5_IPK_DIR=$(BUILD_DIR)/perl-digest-perl-md5-$(PERL-DIGEST-PERL-MD5_VERSION)-ipk
PERL-DIGEST-PERL-MD5_IPK=$(BUILD_DIR)/perl-digest-perl-md5_$(PERL-DIGEST-PERL-MD5_VERSION)-$(PERL-DIGEST-PERL-MD5_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DIGEST-PERL-MD5_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DIGEST-PERL-MD5_SITE)/$(PERL-DIGEST-PERL-MD5_SOURCE)

perl-digest-perl-md5-source: $(DL_DIR)/$(PERL-DIGEST-PERL-MD5_SOURCE) $(PERL-DIGEST-PERL-MD5_PATCHES)

$(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DIGEST-PERL-MD5_SOURCE) $(PERL-DIGEST-PERL-MD5_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-PERL-MD5_DIR) $(PERL-DIGEST-PERL-MD5_BUILD_DIR)
	$(PERL-DIGEST-PERL-MD5_UNZIP) $(DL_DIR)/$(PERL-DIGEST-PERL-MD5_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DIGEST-PERL-MD5_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-DIGEST-PERL-MD5_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DIGEST-PERL-MD5_DIR) $(PERL-DIGEST-PERL-MD5_BUILD_DIR)
	(cd $(PERL-DIGEST-PERL-MD5_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.configured

perl-digest-perl-md5-unpack: $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.configured

$(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.built: $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.configured
	rm -f $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DIGEST-PERL-MD5_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.built

perl-digest-perl-md5: $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.built

$(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.staged: $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.built
	rm -f $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DIGEST-PERL-MD5_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.staged

perl-digest-perl-md5-stage: $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.staged

$(PERL-DIGEST-PERL-MD5_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-DIGEST-PERL-MD5_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-digest-perl-md5" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DIGEST-PERL-MD5_PRIORITY)" >>$@
	@echo "Section: $(PERL-DIGEST-PERL-MD5_SECTION)" >>$@
	@echo "Version: $(PERL-DIGEST-PERL-MD5_VERSION)-$(PERL-DIGEST-PERL-MD5_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DIGEST-PERL-MD5_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DIGEST-PERL-MD5_SITE)/$(PERL-DIGEST-PERL-MD5_SOURCE)" >>$@
	@echo "Description: $(PERL-DIGEST-PERL-MD5_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DIGEST-PERL-MD5_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DIGEST-PERL-MD5_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DIGEST-PERL-MD5_CONFLICTS)" >>$@

$(PERL-DIGEST-PERL-MD5_IPK): $(PERL-DIGEST-PERL-MD5_BUILD_DIR)/.built
	rm -rf $(PERL-DIGEST-PERL-MD5_IPK_DIR) $(BUILD_DIR)/perl-digest-perl-md5_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DIGEST-PERL-MD5_BUILD_DIR) DESTDIR=$(PERL-DIGEST-PERL-MD5_IPK_DIR) install
	find $(PERL-DIGEST-PERL-MD5_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DIGEST-PERL-MD5_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DIGEST-PERL-MD5_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DIGEST-PERL-MD5_IPK_DIR)/CONTROL/control
	echo $(PERL-DIGEST-PERL-MD5_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DIGEST-PERL-MD5_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DIGEST-PERL-MD5_IPK_DIR)

perl-digest-perl-md5-ipk: $(PERL-DIGEST-PERL-MD5_IPK)

perl-digest-perl-md5-clean:
	-$(MAKE) -C $(PERL-DIGEST-PERL-MD5_BUILD_DIR) clean

perl-digest-perl-md5-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-PERL-MD5_DIR) $(PERL-DIGEST-PERL-MD5_BUILD_DIR) $(PERL-DIGEST-PERL-MD5_IPK_DIR) $(PERL-DIGEST-PERL-MD5_IPK)
