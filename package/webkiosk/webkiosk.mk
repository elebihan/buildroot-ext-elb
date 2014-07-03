################################################################################
#
# webkiosk
#
################################################################################

WEBKIOSK_VERSION = bb063504c8c17ec06403b721e99e21bdae034a18
WEBKIOSK_SITE = git://github.com/elebihan/webkiosk.git
WEBKIOSK_DEPENDENCIES = qt5webkit qt5declarative qt5quickcontrols

WEBKIOSK_LICENSE = GPLv3+
WEBKIOSK_LICENSE_FILES = COPYING

define WEBKIOSK_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/qmake PREFIX=$(TARGET_DIR))
endef

define WEBKIOSK_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define WEBKIOSK_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
