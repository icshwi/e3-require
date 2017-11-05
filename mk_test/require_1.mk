## RUN 1
# In source directory

# Find out which EPICS versions to build.
INSTALLED_EPICS_VERSIONS := $(patsubst ${EPICS_LOCATION}/base-%,%,$(wildcard ${EPICS_LOCATION}/base-*[0-9]))
EPICS_VERSIONS = $(filter-out ${EXCLUDE_VERSIONS:=%},${DEFAULT_EPICS_VERSIONS})
MISSING_EPICS_VERSIONS = $(filter-out ${BUILD_EPICS_VERSIONS},${EPICS_VERSIONS})
BUILD_EPICS_VERSIONS = $(filter ${INSTALLED_EPICS_VERSIONS},${EPICS_VERSIONS})
$(foreach v,$(sort $(basename ${BUILD_EPICS_VERSIONS})),$(eval EPICS_VERSIONS_$v=$(filter $v.%,${BUILD_EPICS_VERSIONS})))

# Check only version of files needed to build the module. But which are they?
VERSIONCHECKFILES = $(filter-out /% -none-, $(wildcard *makefile* *Makefile* *.db *.template *.subs *.dbd *.cmd) ${SOURCES} ${DBDS} ${TEMPLATES} ${SCRIPTS} $(foreach v,3.13 3.14 3.15, ${SOURCES_$v} ${DBDS_$v}))
VERSIONCHECKCMD = ${MAKEHOME}/getVersion.tcl ${VERSIONDEBUGFLAG} ${VERSIONCHECKFILES}
LIBVERSION = $(or $(filter-out test,$(shell ${VERSIONCHECKCMD} 2>/dev/null)),${USER},test)
VERSIONDEBUGFLAG = $(if ${VERSIONDEBUG}, -d)

# Default module name is name of current directory.
# But in case of "src" or "snl", use parent directory instead.
# Avoid using environment variables for MODULE or PROJECT
MODULE=
PROJECT=
PRJDIR:=$(subst -,_,$(subst .,_,$(notdir $(patsubst %Lib,%,$(patsubst %/snl,%,$(patsubst %/src,%,${PWD}))))))
PRJ = $(strip $(or ${MODULE},${PROJECT},${PRJDIR}))
export PRJ

OS_CLASS_LIST = $(BUILDCLASSES)
export OS_CLASS_LIST

export ARCH_FILTER
export EXCLUDE_ARCHS
export MAKE_FIRST

# Some shell commands:
RMDIR = rm -rf
LN = ln -s
EXISTS = test -e
NM = nm
RM = rm -f
MKDIR = mkdir -p -m 775

clean::
	$(RMDIR) O.*

clean.%::
	$(RMDIR) $(wildcard O.*${@:clean.%=%}*)

uninstall:
	$(RMDIR) ${MODULE_LOCATION}

uninstall.%:
	$(RMDIR) $(wildcard ${MODULE_LOCATION}/R*${@:uninstall.%=%}*)

help:
	@echo "usage:"
	@for target in '' build '<EPICS version>' \
	install 'install.<EPICS version>' \
	uninstall 'uninstall.<EPICS version>' \
        installui uninstallui \
	clean help version; \
	do echo "  make $$target"; \
	done
	@echo "Makefile variables:(defaults) [comment]"
	@echo "  EPICS_VERSIONS   (${DEFAULT_EPICS_VERSIONS})"
	@echo "  MODULE           (${PRJ}) [from current directory name]"
	@echo "  PROJECT          [older name for MODULE]"
	@echo "  SOURCES          (*.c *.cc *.cpp *.st *.stt *.gt)"
	@echo "  DBDS             (*.dbd)"
	@echo "  HEADERS          () [only those to install]"
	@echo "  TEMPLATES        (*.template *.db *.subs) [db files]"
	@echo "  SCRIPTS          (*.cmd) [startup and other scripts]"
	@echo "  BINS             () [programs to install]"
	@echo "  QT               (qt/*) [QT user interfaces to install]"
	@echo "  EXCLUDE_VERSIONS () [versions not to build, e.g. 3.14]"
	@echo "  EXCLUDE_ARCHS    () [target architectures not to build]"
	@echo "  ARCH_FILTER      () [target architectures to build, e.g. SL6%]"
	@echo "  BUILDCLASSES     (vxWorks) [other choices: Linux]"
	@echo "  <module>_VERSION () [build against specific version of other module]"

# "make version" shows the module version and why it is what it is.       
version: ${IGNOREFILES}
	@${VERSIONCHECKCMD}

debug::
	@echo "INSTALLED_EPICS_VERSIONS = ${INSTALLED_EPICS_VERSIONS}"
	@echo "BUILD_EPICS_VERSIONS = ${BUILD_EPICS_VERSIONS}"
	@echo "MISSING_EPICS_VERSIONS = ${MISSING_EPICS_VERSIONS}"
	@echo "EPICS_VERSIONS_3.13 = ${EPICS_VERSIONS_3.13}"
	@echo "EPICS_VERSIONS_3.14 = ${EPICS_VERSIONS_3.14}"
	@echo "EPICS_VERSIONS_3.15 = ${EPICS_VERSIONS_3.15}"
	@echo "BUILDCLASSES = ${BUILDCLASSES}"
	@echo "LIBVERSION = ${LIBVERSION}"
	@echo "VERSIONCHECKFILES = ${VERSIONCHECKFILES}"
	@echo "ARCH_FILTER = ${ARCH_FILTER}"
	@echo "PRJ = ${PRJ}"

# Loop over all EPICS versions for second run.
MAKEVERSION = ${MAKE} -f ${USERMAKEFILE} LIBVERSION=${LIBVERSION}

build install debug:: ${IGNOREFILES}
	for VERSION in ${BUILD_EPICS_VERSIONS}; do ${MAKEVERSION} EPICSVERSION=$$VERSION $@; done

# Handle cases where user requests a group of EPICS versions:
# make <action>.3.13 or make <action>.3.14 instead of make <action> or
# make 3.13 or make 3.14 instead of make.



#>>
define VERSIONRULES
$(1): ${IGNOREFILES}
	for VERSION in $${EPICS_VERSIONS_$(1)}; do $${MAKEVERSION} EPICSVERSION=$$$$VERSION build; done

%.$(1): ${IGNOREFILES}
	for VERSION in $${EPICS_VERSIONS_$(1)}; do $${MAKEVERSION} EPICSVERSION=$$$$VERSION $${@:%.$(1)=%}; done
endef
#<<




$(foreach v,$(sort $(basename ${INSTALLED_EPICS_VERSIONS})),$(eval $(call VERSIONRULES,$v)))

# Handle cases where user requests one specific version:
# make <action>.<version> instead of make <action> or
# make <version> instead of make
# EPICS version must be installed but need not be in EPICS_VERSIONS
${INSTALLED_EPICS_VERSIONS}:
	${MAKEVERSION} EPICSVERSION=$@ build

${INSTALLED_EPICS_VERSIONS:%=build.%}:
	${MAKEVERSION} EPICSVERSION=${@:build.%=%} build

${INSTALLED_EPICS_VERSIONS:%=install.%}:
	${MAKEVERSION} EPICSVERSION=${@:install.%=%} install

${INSTALLED_EPICS_VERSIONS:%=debug.%}:
	${MAKEVERSION} EPICSVERSION=${@:debug.%=%} debug


# Install user interfaces to global location.
# Keep a list of installed files in a hidden file for uninstall.




#>>
define INSTALL_UI_RULE
INSTALL_$(1)=$(2)
$(1)_FILES=$$(wildcard $$(or $${$(1)},$(3)))
installui: install$(1)
install$(1): uninstall$(1)
	@$$(if $${$(1)_FILES},echo "Installing $(1) user interfaces";$$(MKDIR) $${INSTALL_$(1)})
	@$$(if $${$(1)_FILES},$(CP) -v -t $${INSTALL_$(1)} $${$(1)_FILES:%='%'})
	@$$(if $${$(1)_FILES},echo "$$(patsubst %,'%',$$(notdir $${$(1)_FILES}))" > $${INSTALL_$(1)}/.$${PRJ}-$$(LIBVERSION)-$(1).txt)

uninstallui: uninstall$(1)
uninstall$(1):
	@echo "Removing old $(1) user interfaces"
	@$$(RM) -v $$(addprefix $${INSTALL_$(1)}/,$$(sort $$(patsubst %,'%',$$(notdir $${$(1)_FILES})) $$(shell cat $${INSTALL_$(1)}/.$${PRJ}-*.txt 2>/dev/null)) .$${PRJ}-*-$(1).txt)
endef
#<<




# You can add more UI rules following this pattern:
#$(eval $(call INSTALL_UI_RULE,VARIABLE,installdir,sourcedefaultlocation))
$(eval $(call INSTALL_UI_RULE,QT,${CONFIGBASE}/qt,qt/*))




