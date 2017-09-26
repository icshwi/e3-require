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
# Date    : Tuesday, September 26 17:17:47 CEST 2017
# version : 0.0.1
#


TOP = $(CURDIR)


include $(TOP)/configure/CONFIG

M_DIRS:=$(sort $(dir $(wildcard $(TOP)/*/.)))

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
## Install  "Require" EPICS Module in order to use it
install:
	sudo -E bash -c 'make -C $(EPICS_MODULE_SRC_PATH) LIBVERSION=$(LIBVERSION) PROJECT=$(EPICS_MODULE_NAME) install'



## Build     EPICS Module in order to use it with EEE
build: 
	make -C $(EPICS_MODULE_SRC_PATH) LIBVERSION=$(LIBVERSION) PROJECT=$(EPICS_MODULE_NAME)

## Clean     EPICS Module in terms of EEE Makefile (module.Makefile)
clean:
	make -C $(EPICS_MODULE_SRC_PATH) LIBVERSION=$(LIBVERSION) PROJECT=$(EPICS_MODULE_NAME) clean


## Distclean EPICS Module in terms of EEE Makefile (module.Makefile)
distclean:
	make -C $(EPICS_MODULE_SRC_PATH) LIBVERSION=$(LIBVERSION) PROJECT=$(EPICS_MODULE_NAME) distclean


## Get      EPICS Module, and change its $(EPICS_MODULE_TAG)
init:
	@git submodule deinit -f $(EPICS_MODULE_NAME)/
	git submodule deinit -f $(EPICS_MODULE_NAME)/	
	git submodule init $(EPICS_MODULE_NAME)/
	git submodule update --init --remote --recursive $(EPICS_MODULE_NAME)/.
#	cd $(EPICS_MODULE_NAME) && git checkout tags/$(EPICS_MODULE_TAG)


## Print ENV variables
env:
	@echo ""
	@echo "EPICS_BASE             : "$(EPICS_BASE)

	@echo "EPICS_MODULE_NAME      : "$(EPICS_MODULE_NAME)
	@echo "EPICS_MODULE_TAG       : "$(EPICS_MODULE_TAG)
	@echo "EPICS_MODULE_SRC_PATH  : "$(EPICS_MODULE_SRC_PATH)
	@echo "ESS_MODULE_MAKEFILE    : "$(ESS_MODULE_MAKEFILE)
	@echo "PROJECT                : "$(PROJECT)
	@echo "LIBVERSION             : "$(LIBVERSION)

	@echo ""
	@echo "EPICS_BASES_PATH       : "$(EPICS_BASES_PATH)
	@echo "EPICS_MODULES_PATH     : "$(EPICS_MODULES_PATH)
	@echo "EPICS_HOST_ARCH        : "$(EPICS_HOST_ARCH)
	@echo "EPICS_ENV_PATH         : "$(EPICS_ENV_PATH)
	@echo ""



dirs:
	@echo $(M_DIRS) || true


.PHONY: install build clean distclean init env dirs
