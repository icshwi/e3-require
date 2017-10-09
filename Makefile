#
#  Copyright (c) 2017 - Present  European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author  : Jeong Han Lee
# email   : han.lee@esss.se
# Date    : Friday, October  6 13:35:46 CEST 2017
# version : 0.1.0
#

TOP:=$(CURDIR)

include $(TOP)/configure/CONFIG

-include $(TOP)/$(E3_ENV_NAME)/$(E3_ENV_NAME)

#
# Keep always the module up-to-date
define git_update =
@git submodule deinit -f $@/
git submodule deinit -f $@/
sed -i '/submodule/,$$d'  $(TOP)/.git/config
rm -rf $(TOP)/.git/modules/$@
git submodule init $@/
git submodule update --init --recursive --recursive $@/.
git submodule update --remote --merge $@/
endef

ifndef VERBOSE
  QUIET := @
endif

ifdef DEBUG_SHELL
  SHELL = /bin/sh -x
endif

M_OPTIONS := -C $(EPICS_MODULE_SRC_PATH)
M_OPTIONS += -f $(ESS_MODULE_MAKEFILE)
M_OPTIONS += LIBVERSION="$(REQUIRE_VERSION)"
M_OPTIONS += PROJECT="$(EPICS_MODULE_NAME)"
M_OPTIONS += EPICS_MODULES="$(EPICS_MODULES)"
M_OPTIONS += EPICS_LOCATION="$(EPICS_LOCATION)"
M_OPTIONS += DEFAULT_EPICS_VERSIONS="$(DEFAULT_EPICS_VERSIONS)"

unexport BUILDCLASSES



# help is defined in 
# https://gist.github.com/rcmachado/af3db315e31383502660
help:
	$(info --------------------------------------- )	
	$(info Available targets)
	$(info --------------------------------------- )
	$(QUIET) awk '/^[a-zA-Z\-\_0-9]+:/ {            \
	  nb = sub( /^## /, "", helpMsg );              \
	  if(nb == 0) {                                 \
	    helpMsg = $$0;                              \
	    nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
	  }                                             \
	  if (nb)                                       \
	    print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts:	



default: help

#
## Install "Require" Module in order to use it
install:
	$(QUIET) sudo -E bash -c 'make $(M_OPTIONS) install'
	$(QUIET) sudo install -d -m 755  $(REQUIRE_TOOLS)
	$(QUIET) sudo install -m 644 $(EPICS_MODULE_SRC_PATH)/App/tools/driver.makefile $(REQUIRE_TOOLS)/
	$(QUIET) sudo install -m 755 $(EPICS_MODULE_SRC_PATH)/App/tools/*.tcl           $(REQUIRE_TOOLS)/
	$(QUIET) sudo -E bash -c 'm4 \
	-D_DEFAULT_EPICS_VERSIONS="$(DEFAULT_EPICS_VERSIONS)" \
	-D_EPICS_MODULES="$(EPICS_MODULES)" \
	-D_EPICS_LOCATION="$(EPICS_LOCATION)" \
	 $(TOP)/configure/driver_makefile_conf.m4  \
	 > $(REQUIRE_TOOLS)/conf'
	$(QUIET) sudo install -d -m 755 $(REQUIRE_BIN)
#	$(QUIET) sudo install -m 755 $(EPICS_MODULE_SRC_PATH)/iocsh $(REQUIRE_BIN)/
	$(QUIET) sudo install -m 755  $(TOP)/iocsh.bash       $(REQUIRE_BIN)/
	$(QUIET) sudo install -m 644  $(TOP)/ess-env.conf     $(REQUIRE_BIN)/
	$(QUIET) sudo install -m 644  $(TOP)/iocsh_functions  $(REQUIRE_BIN)/
#
## Uninstall "Require" Module in order not to use it
uninstall:
	$(QUIET) sudo -E bash -c 'make $(M_OPTIONS) uninstall'


## Build the EPICS Module
build: conf
	$(QUIET) make $(M_OPTIONS)

## Clean the EPICS Module
clean:
	$(QUIET) make $(M_OPTIONS) clean


#
## Initialize EPICS BASE and E3 ENVIRONMENT Module
init: git-submodule-sync $(EPICS_MODULE_NAME) $(E3_ENV_NAME)

git-submodule-sync:
	$(QUIET) git submodule sync


$(EPICS_MODULE_NAME): 
	$(QUIET) $(git_update)
	cd $@ && git checkout tags/$(REQUIRE_MODULE_TAG)


$(E3_ENV_NAME): 
	$(QUIET) $(git_update)


## Print EPICS and ESS EPICS Environment variables
env:
	$(QUIET) echo ""

	$(QUIET) echo "EPICS_MODULE_NAME           : "$(EPICS_MODULE_NAME)
	$(QUIET) echo "REQUIRE_MODULE_TAG          : "$(REQUIRE_MODULE_TAG)
	$(QUIET) echo "EPICS_MODULE_SRC_PATH       : "$(EPICS_MODULE_SRC_PATH)
	$(QUIET) echo "ESS_MODULE_MAKEFILE         : "$(ESS_MODULE_MAKEFILE)

	$(QUIET) echo ""
	$(QUIET) echo "----- >>>> EPICS BASE Information <<<< -----"
	$(QUIET) echo ""
	$(QUIET) echo "EPICS_BASE_TAG              : "$(EPICS_BASE_TAG)
	$(QUIET) echo "CROSS_COMPILER_TARGET_ARCHS : "$(CROSS_COMPILER_TARGET_ARCHS)
	$(QUIET) echo ""
	$(QUIET) echo "----- >>>> ESS EPICS Environment  <<<< -----"
	$(QUIET) echo ""
	$(QUIET) echo "EPICS_LOCATION              : "$(EPICS_LOCATION)
	$(QUIET) echo "EPICS_MODULES               : "$(EPICS_MODULES)
	$(QUIET) echo "DEFAULT_EPICS_VERSIONS      : "$(DEFAULT_EPICS_VERSIONS)
	$(QUIET) echo "BASE_INSTALL_LOCATIONS      : "$(BASE_INSTALL_LOCATIONS)
	$(QUIET) echo "REQUIRE_VERSION             : "$(REQUIRE_VERSION)
	$(QUIET) echo "REQUIRE_PATH                : "$(REQUIRE_PATH)
	$(QUIET) echo "REQUIRE_TOOLS               : "$(REQUIRE_TOOLS)
	$(QUIET) echo "REQUIRE_BIN                 : "$(REQUIRE_BIN)
	$(QUIET) echo ""



conf:
	$(QUIET) install -m 644 $(TOP)/$(ESS_MODULE_MAKEFILE)  $(EPICS_MODULE_SRC_PATH)/



.PHONY: help default init $(EPICS_MODULE_NAME) $(E3_ENV_NAME) env conf install uninstall build clean 
