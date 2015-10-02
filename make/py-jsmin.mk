###########################################################
#
# py-jsmin
#
###########################################################

#
# PY-JSMIN_VERSION, PY-JSMIN_SITE and PY-JSMIN_SOURCE define
# the upstream location of the source code for the package.
# PY-JSMIN_DIR is the directory which is created when the source
# archive is unpacked.
# PY-JSMIN_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
PY-JSMIN_SITE=https://pypi.python.org/packages/source/j/jsmin
PY-JSMIN_VERSION=2.1.2
PY-JSMIN_SOURCE=jsmin-$(PY-JSMIN_VERSION).tar.gz
PY-JSMIN_DIR=jsmin-$(PY-JSMIN_VERSION)
PY-JSMIN_UNZIP=zcat
PY-JSMIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-JSMIN_DESCRIPTION=JavaScript minifier.
PY-JSMIN_SECTION=misc
PY-JSMIN_PRIORITY=optional
PY25-JSMIN_DEPENDS=python25
PY26-JSMIN_DEPENDS=python26
PY27-JSMIN_DEPENDS=python27
PY3-JSMIN_DEPENDS=python3
PY-JSMIN_CONFLICTS=

#
# PY-JSMIN_IPK_VERSION should be incremented when the ipk changes.
#
PY-JSMIN_IPK_VERSION=1

#
# PY-JSMIN_CONFFILES should be a list of user-editable files
#PY-JSMIN_CONFFILES=/opt/etc/py-jsmin.conf /opt/etc/init.d/SXXpy-jsmin

#
# PY-JSMIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-JSMIN_PATCHES=$(PY-JSMIN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-JSMIN_CPPFLAGS=
PY-JSMIN_LDFLAGS=

#
# PY-JSMIN_BUILD_DIR is the directory in which the build is done.
# PY-JSMIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-JSMIN_IPK_DIR is the directory in which the ipk is built.
# PY-JSMIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-JSMIN_BUILD_DIR=$(BUILD_DIR)/py-jsmin
PY-JSMIN_SOURCE_DIR=$(SOURCE_DIR)/py-jsmin
PY-JSMIN_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-jsmin

PY25-JSMIN_IPK_DIR=$(BUILD_DIR)/py25-jsmin-$(PY-JSMIN_VERSION)-ipk
PY25-JSMIN_IPK=$(BUILD_DIR)/py25-jsmin_$(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-JSMIN_IPK_DIR=$(BUILD_DIR)/py26-jsmin-$(PY-JSMIN_VERSION)-ipk
PY26-JSMIN_IPK=$(BUILD_DIR)/py26-jsmin_$(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-JSMIN_IPK_DIR=$(BUILD_DIR)/py27-jsmin-$(PY-JSMIN_VERSION)-ipk
PY27-JSMIN_IPK=$(BUILD_DIR)/py27-jsmin_$(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-JSMIN_IPK_DIR=$(BUILD_DIR)/py3-jsmin-$(PY-JSMIN_VERSION)-ipk
PY3-JSMIN_IPK=$(BUILD_DIR)/py3-jsmin_$(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-JSMIN_SOURCE):
	$(WGET) -P $(@D) $(PY-JSMIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-jsmin-source: $(DL_DIR)/$(PY-JSMIN_SOURCE) $(PY-JSMIN_PATCHES)

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
$(PY-JSMIN_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-JSMIN_SOURCE) $(PY-JSMIN_PATCHES) make/py-jsmin.mk
	$(MAKE) py-setuptools-stage py-setuptools-host-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-JSMIN_DIR)
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-JSMIN_DIR)
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	# 2.7
	rm -rf $(BUILD_DIR)/$(PY-JSMIN_DIR)
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	# 3
	rm -rf $(BUILD_DIR)/$(PY-JSMIN_DIR)
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	touch $@

py-jsmin-unpack: $(PY-JSMIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-JSMIN_BUILD_DIR)/.built: $(PY-JSMIN_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-jsmin: $(PY-JSMIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-JSMIN_BUILD_DIR)/.staged: $(PY-JSMIN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

$(PY-JSMIN_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-JSMIN_SOURCE) make/py-jsmin.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)
	$(MAKE) py-setuptools-host-stage
	mkdir -p $(@D)/
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(HOST_STAGING_PREFIX)/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(HOST_STAGING_PREFIX)/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(HOST_STAGING_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	$(PY-JSMIN_UNZIP) $(DL_DIR)/$(PY-JSMIN_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(PY-JSMIN_PATCHES)"; then \
	    cat $(PY-JSMIN_PATCHES) | $(PATCH) -d $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) -p1; \
	fi
	mv $(HOST_BUILD_DIR)/$(PY-JSMIN_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	(cd $(@D)/2.5; \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.6; \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-jsmin-host-stage: $(PY-JSMIN_HOST_BUILD_DIR)/.staged

py-jsmin-stage: $(PY-JSMIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-jsmin
#
$(PY25-JSMIN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-jsmin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JSMIN_PRIORITY)" >>$@
	@echo "Section: $(PY-JSMIN_SECTION)" >>$@
	@echo "Version: $(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JSMIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-JSMIN_SITE)/$(PY-JSMIN_SOURCE)" >>$@
	@echo "Description: $(PY-JSMIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-JSMIN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JSMIN_CONFLICTS)" >>$@

$(PY26-JSMIN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-jsmin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JSMIN_PRIORITY)" >>$@
	@echo "Section: $(PY-JSMIN_SECTION)" >>$@
	@echo "Version: $(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JSMIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-JSMIN_SITE)/$(PY-JSMIN_SOURCE)" >>$@
	@echo "Description: $(PY-JSMIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-JSMIN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JSMIN_CONFLICTS)" >>$@

$(PY27-JSMIN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-jsmin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JSMIN_PRIORITY)" >>$@
	@echo "Section: $(PY-JSMIN_SECTION)" >>$@
	@echo "Version: $(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JSMIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-JSMIN_SITE)/$(PY-JSMIN_SOURCE)" >>$@
	@echo "Description: $(PY-JSMIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-JSMIN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JSMIN_CONFLICTS)" >>$@

$(PY3-JSMIN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-jsmin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JSMIN_PRIORITY)" >>$@
	@echo "Section: $(PY-JSMIN_SECTION)" >>$@
	@echo "Version: $(PY-JSMIN_VERSION)-$(PY-JSMIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JSMIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-JSMIN_SITE)/$(PY-JSMIN_SOURCE)" >>$@
	@echo "Description: $(PY-JSMIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-JSMIN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JSMIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-JSMIN_IPK_DIR)/opt/sbin or $(PY-JSMIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-JSMIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-JSMIN_IPK_DIR)/opt/etc/py-jsmin/...
# Documentation files should be installed in $(PY-JSMIN_IPK_DIR)/opt/doc/py-jsmin/...
# Daemon startup scripts should be installed in $(PY-JSMIN_IPK_DIR)/opt/etc/init.d/S??py-jsmin
#
# You may need to patch your application to make it use these locations.
#
$(PY25-JSMIN_IPK): $(PY-JSMIN_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-jsmin_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-JSMIN_IPK_DIR) $(BUILD_DIR)/py25-jsmin_*_$(TARGET_ARCH).ipk
	(cd $(PY-JSMIN_BUILD_DIR)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install --root=$(PY25-JSMIN_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-JSMIN_IPK_DIR)/CONTROL/control
#	echo $(PY-JSMIN_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-JSMIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-JSMIN_IPK_DIR)

$(PY26-JSMIN_IPK): $(PY-JSMIN_BUILD_DIR)/.built
	rm -rf $(PY26-JSMIN_IPK_DIR) $(BUILD_DIR)/py26-jsmin_*_$(TARGET_ARCH).ipk
	(cd $(PY-JSMIN_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install --root=$(PY26-JSMIN_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY26-JSMIN_IPK_DIR)/CONTROL/control
#	echo $(PY-JSMIN_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-JSMIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-JSMIN_IPK_DIR)

$(PY27-JSMIN_IPK): $(PY-JSMIN_BUILD_DIR)/.built
	rm -rf $(PY27-JSMIN_IPK_DIR) $(BUILD_DIR)/py27-jsmin_*_$(TARGET_ARCH).ipk
	(cd $(PY-JSMIN_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 -c "import setuptools; execfile('setup.py')" install --root=$(PY27-JSMIN_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY27-JSMIN_IPK_DIR)/CONTROL/control
#	echo $(PY-JSMIN_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-JSMIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-JSMIN_IPK_DIR)

$(PY3-JSMIN_IPK): $(PY-JSMIN_BUILD_DIR)/.built
	rm -rf $(PY3-JSMIN_IPK_DIR) $(BUILD_DIR)/py3-jsmin_*_$(TARGET_ARCH).ipk
	(cd $(PY-JSMIN_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-JSMIN_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY3-JSMIN_IPK_DIR)/CONTROL/control
#	echo $(PY-JSMIN_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-JSMIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-JSMIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-jsmin-ipk: $(PY25-JSMIN_IPK) $(PY26-JSMIN_IPK) $(PY27-JSMIN_IPK) $(PY3-JSMIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-jsmin-clean:
	-$(MAKE) -C $(PY-JSMIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-jsmin-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-JSMIN_DIR) $(PY-JSMIN_BUILD_DIR)
	rm -rf $(PY25-JSMIN_IPK_DIR) $(PY25-JSMIN_IPK)
	rm -rf $(PY26-JSMIN_IPK_DIR) $(PY26-JSMIN_IPK)
	rm -rf $(PY27-JSMIN_IPK_DIR) $(PY27-JSMIN_IPK)
	rm -rf $(PY3-JSMIN_IPK_DIR) $(PY3-JSMIN_IPK)
