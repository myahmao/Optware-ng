###########################################################
#
# perl-extutils-cbuilder
#
###########################################################

PERL-EXTUTILS-CBUILDER_SITE=http://search.cpan.org/CPAN/authors/id/K/KW/KWILLIAMS
PERL-EXTUTILS-CBUILDER_VERSION=0.24_01
PERL-EXTUTILS-CBUILDER_SOURCE=ExtUtils-CBuilder-$(PERL-EXTUTILS-CBUILDER_VERSION).tar.gz
PERL-EXTUTILS-CBUILDER_DIR=ExtUtils-CBuilder-$(PERL-EXTUTILS-CBUILDER_VERSION)
PERL-EXTUTILS-CBUILDER_UNZIP=zcat
PERL-EXTUTILS-CBUILDER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-EXTUTILS-CBUILDER_DESCRIPTION=ExtUtils-CBuilder - Compile and link C code for Perl modules.
PERL-EXTUTILS-CBUILDER_SECTION=util
PERL-EXTUTILS-CBUILDER_PRIORITY=optional
PERL-EXTUTILS-CBUILDER_DEPENDS=perl
PERL-EXTUTILS-CBUILDER_SUGGESTS=
PERL-EXTUTILS-CBUILDER_CONFLICTS=

PERL-EXTUTILS-CBUILDER_IPK_VERSION=2

PERL-EXTUTILS-CBUILDER_CONFFILES=

PERL-EXTUTILS-CBUILDER_BUILD_DIR=$(BUILD_DIR)/perl-extutils-cbuilder
PERL-EXTUTILS-CBUILDER_SOURCE_DIR=$(SOURCE_DIR)/perl-extutils-cbuilder
PERL-EXTUTILS-CBUILDER_IPK_DIR=$(BUILD_DIR)/perl-extutils-cbuilder-$(PERL-EXTUTILS-CBUILDER_VERSION)-ipk
PERL-EXTUTILS-CBUILDER_IPK=$(BUILD_DIR)/perl-extutils-cbuilder_$(PERL-EXTUTILS-CBUILDER_VERSION)-$(PERL-EXTUTILS-CBUILDER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-EXTUTILS-CBUILDER_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-EXTUTILS-CBUILDER_SITE)/$(PERL-EXTUTILS-CBUILDER_SOURCE)

perl-extutils-cbuilder-source: $(DL_DIR)/$(PERL-EXTUTILS-CBUILDER_SOURCE) $(PERL-EXTUTILS-CBUILDER_PATCHES)

$(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-EXTUTILS-CBUILDER_SOURCE) $(PERL-EXTUTILS-CBUILDER_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-EXTUTILS-CBUILDER_DIR) $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)
	$(PERL-EXTUTILS-CBUILDER_UNZIP) $(DL_DIR)/$(PERL-EXTUTILS-CBUILDER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-EXTUTILS-CBUILDER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-EXTUTILS-CBUILDER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-EXTUTILS-CBUILDER_DIR) $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)
	(cd $(PERL-EXTUTILS-CBUILDER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.configured

perl-extutils-cbuilder-unpack: $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.configured

$(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.built: $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.configured
	rm -f $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-EXTUTILS-CBUILDER_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.built

perl-extutils-cbuilder: $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.built

$(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.staged: $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.built
	rm -f $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-EXTUTILS-CBUILDER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.staged

perl-extutils-cbuilder-stage: $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.staged

$(PERL-EXTUTILS-CBUILDER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-EXTUTILS-CBUILDER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-extutils-cbuilder" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-EXTUTILS-CBUILDER_PRIORITY)" >>$@
	@echo "Section: $(PERL-EXTUTILS-CBUILDER_SECTION)" >>$@
	@echo "Version: $(PERL-EXTUTILS-CBUILDER_VERSION)-$(PERL-EXTUTILS-CBUILDER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-EXTUTILS-CBUILDER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-EXTUTILS-CBUILDER_SITE)/$(PERL-EXTUTILS-CBUILDER_SOURCE)" >>$@
	@echo "Description: $(PERL-EXTUTILS-CBUILDER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-EXTUTILS-CBUILDER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-EXTUTILS-CBUILDER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-EXTUTILS-CBUILDER_CONFLICTS)" >>$@

$(PERL-EXTUTILS-CBUILDER_IPK): $(PERL-EXTUTILS-CBUILDER_BUILD_DIR)/.built
	rm -rf $(PERL-EXTUTILS-CBUILDER_IPK_DIR) $(BUILD_DIR)/perl-extutils-cbuilder_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-EXTUTILS-CBUILDER_BUILD_DIR) DESTDIR=$(PERL-EXTUTILS-CBUILDER_IPK_DIR) install
	find $(PERL-EXTUTILS-CBUILDER_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-EXTUTILS-CBUILDER_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-EXTUTILS-CBUILDER_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-EXTUTILS-CBUILDER_IPK_DIR)/CONTROL/control
	echo $(PERL-EXTUTILS-CBUILDER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-EXTUTILS-CBUILDER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-EXTUTILS-CBUILDER_IPK_DIR)

perl-extutils-cbuilder-ipk: $(PERL-EXTUTILS-CBUILDER_IPK)

perl-extutils-cbuilder-clean:
	-$(MAKE) -C $(PERL-EXTUTILS-CBUILDER_BUILD_DIR) clean

perl-extutils-cbuilder-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-EXTUTILS-CBUILDER_DIR) $(PERL-EXTUTILS-CBUILDER_BUILD_DIR) $(PERL-EXTUTILS-CBUILDER_IPK_DIR) $(PERL-EXTUTILS-CBUILDER_IPK)
