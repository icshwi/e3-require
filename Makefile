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
# Date    : Tuesday, October  3 14:57:53 CEST 2017
# version : 0.0.1
#


TOP = $(CURDIR)

include $(TOP)/configure/CONFIG

E3_ENV_SRC=$(TOP)/e3-env/e3-env

ifneq ($(wildcard $(E3_ENV_SRC)),)
include $(E3_ENV_SRC)
endif


M_DIRS:=$(sort $(dir $(wildcard $(TOP)/*/.)))


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
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                    \
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
	sudo -E bash -c 'make $(M_OPTIONS) install'
	@sudo install -d -m 755  $(REQUIRE_TOOLS)
	@sudo install -m 644 $(EPICS_MODULE_SRC_PATH)/App/tools/driver.makefile $(REQUIRE_TOOLS)/
	@sudo install -m 755 $(EPICS_MODULE_SRC_PATH)/App/tools/*.tcl           $(REQUIRE_TOOLS)/
	@sudo -E bash -c 'm4 -D_DEFAULT_EPICS_VERSIONS="$(DEFAULT_EPICS_VERSIONS)" -D_EPICS_MODULES="$(EPICS_MODULES)" -D_EPICS_LOCATION="$(EPICS_LOCATION)"  $(TOP)/configure/driver_makefile_conf.m4  > $(REQUIRE_TOOLS)/conf'
	@sudo install -d -m 755 $(REQUIRE_BIN)
	@sudo install -m 755 $(EPICS_MODULE_SRC_PATH)/iocsh $(REQUIRE_BIN)/

#
## Uninstall "Require" Module in order not to use it
uninstall:
	sudo -E bash -c 'make $(M_OPTIONS) uninstall'


## Build the EPICS Module
build: conf
	make $(M_OPTIONS)

## Clean the EPICS Module
clean:
	make $(M_OPTIONS) clean


## Initialize all environments
init: e3-env mo-init


## Get EPICS Module, and change its $(EPICS_MODULE_TAG)
mo-init: 
	@git submodule deinit -f $(EPICS_MODULE_NAME)/
	git submodule deinit -f $(EPICS_MODULE_NAME)/	
	git submodule init $(EPICS_MODULE_NAME)/
	git submodule update --init --remote --recursive $(EPICS_MODULE_NAME)/.
	cd $(EPICS_MODULE_NAME) && git checkout tags/$(EPICS_MODULE_TAG)


## Print EPICS and ESS EPICS Environment variables
env:
	@echo ""

	@echo "EPICS_MODULE_NAME      : "$(EPICS_MODULE_NAME)
	@echo "EPICS_MODULE_TAG       : "$(EPICS_MODULE_TAG)
	@echo "EPICS_MODULE_SRC_PATH  : "$(EPICS_MODULE_SRC_PATH)
	@echo "ESS_MODULE_MAKEFILE    : "$(ESS_MODULE_MAKEFILE)
	@echo "PROJECT                : "$(PROJECT)
	@echo "LIBVERSION             : "$(LIBVERSION)

	@echo ""
	@echo ">>>> ESS EPICS Environment <<<< "
	@echo ""
	@echo "EPICS_LOCATION         : "$(EPICS_LOCATION)
	@echo "EPICS_MODULES          : "$(EPICS_MODULES)
	@echo "DEFAULT_EPICS_VERSIONS : "$(DEFAULT_EPICS_VERSIONS)
	@echo "REQUIRE_VERSION        : "$(REQUIRE_VERSION)
	@echo "REQUIRE_PATH           : "$(REQUIRE_PATH)
	@echo "REQUIRE_TOOLS          : "$(REQUIRE_TOOLS)
	@echo "REQUIRE_BIN            : "$(REQUIRE_BIN)
	@echo ""



dirs:
	@echo $(M_DIRS) || true

conf:
	@install -m 644 $(TOP)/$(ESS_MODULE_MAKEFILE)  $(EPICS_MODULE_SRC_PATH)/

#
#
e3-env:
	@git submodule deinit -f $(E3_ENV)/
	git submodule deinit -f $(E3_ENV)/	
	git submodule init $(E3_ENV)/
	git submodule update --init --remote --recursive $(E3_ENV)/.
#	cd $(E3_ENV) && git checkout tags/$(E3_ENV_TAG)


.PHONY: install build clean distclean mo-init e3-env init env dirs conf
