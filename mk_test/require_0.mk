
# Get the location of this file.
MAKEHOME:=$(dir $(lastword ${MAKEFILE_LIST}))
# Get the name of the Makefile that included this file.
USERMAKEFILE:=$(lastword $(filter-out $(lastword ${MAKEFILE_LIST}), ${MAKEFILE_LIST}))

# Some configuration:
DEFAULT_EPICS_VERSIONS = 3.13.9 3.13.10 3.14.8 3.14.12
BUILDCLASSES = vxWorks
EPICS_MODULES ?= /ioc/modules
MODULE_LOCATION = ${EPICS_MODULES}/$(or ${PRJ},$(error PRJ not defined))/$(or ${LIBVERSION},$(error LIBVERSION not defined))
EPICS_LOCATION = /usr/local/epics

DOCUEXT = txt html htm doc pdf ps tex dvi gif jpg png
DOCUEXT += TXT HTML HTM DOC PDF PS TEX DVI GIF JPG PNG
DOCUEXT += template db dbt subs subst substitutions script

# Override config here:
-include ${MAKEHOME}/config


# Some shell commands:
LN = ln -s
EXISTS = test -e
NM = nm
RMDIR = rm -rf
RM = rm -f
CP = cp

# Some generated file names:
VERSIONFILE = ${PRJ}_version_${LIBVERSION}.c
REGISTRYFILE = ${PRJ}_registerRecordDeviceDriver.cpp
EXPORTFILE = ${PRJ}_exportAddress.c
SUBFUNCFILE = ${PRJ}_subRecordFunctions.dbd
DEPFILE = ${PRJ}.dep

# Clear potential environment variables.
TEMPLATES=
SOURCES=
DBDS=
HEADERS=

# Default target is "build" for all versions.
# Don't install anything (different from default EPICS make rules).
default: build

IGNOREFILES = .cvsignore .gitignore
%: ${IGNOREFILES}
${IGNOREFILES}:
	@echo -e "O.*\n.cvsignore\n.gitignore" > $@

# Function that removes duplicates without re-ordering (unlike sort):
define uniq
  $(eval seen :=) \
  $(foreach _,$1,$(if $(filter $_,${seen}),,$(eval seen += $_))) \
  ${seen}
endef




