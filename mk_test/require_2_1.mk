## RUN 2
# Target achitecture not yet defined
# but EPICSVERSION is already known.
# Still in source directory.

# Look for sources etc.
# Select target architectures to build.
# Export everything for third run:

AUTOSRCS := $(filter-out ~%,$(wildcard *.c *.cc *.cpp *.st *.stt *.gt))
SRCS = $(if ${SOURCES},$(filter-out -none-,${SOURCES}),${AUTOSRCS})
#SRCS += ${SOURCES_${EPICS_BASETYPE}} # added later by VAR_EXTENSIONS
#SRCS += ${SOURCES_${EPICSVERSION}}
export SRCS

DBD_SRCS = $(if ${DBDS},$(filter-out -none-,${DBDS}),$(wildcard menu*.dbd *Record.dbd) $(strip $(filter-out %Include.dbd dbCommon.dbd %Record.dbd,$(wildcard *.dbd)) ${BPTS}))
DBD_SRCS += ${DBDS_${EPICS_BASETYPE}}
DBD_SRCS += ${DBDS_${EPICSVERSION}}
export DBD_SRCS

#record dbd files given in DBDS
RECORDS1 = $(patsubst %Record.dbd, %, $(filter-out dev%, $(filter %Record.dbd, $(notdir ${DBD_SRCS}))))
#record dbd files included by files given in DBDS
RECORDS2 = $(filter-out dev%, $(shell ${MAKEHOME}/expandDBD.tcl -r $(addprefix -I, $(sort $(dir ${DBD_SRCS}))) $(realpath ${DBDS})))
RECORDS = $(sort ${RECORDS1} ${RECORDS2})
export RECORDS

MENUS = $(patsubst %.dbd,%.h,$(wildcard menu*.dbd))
export MENUS

BPTS = $(patsubst %.data,%.dbd,$(wildcard bpt*.data))
export BPTS

HDRS = ${HEADERS} $(addprefix ${COMMON_DIR}/,$(addsuffix Record.h,${RECORDS}))
HDRS += ${HEADERS_${EPICS_BASETYPE}}
HDRS += ${HEADERS_${EPICSVERSION}}
export HDRS

TEMPLS = $(if ${TEMPLATES},$(filter-out -none-,${TEMPLATES}),$(wildcard *.template *.db *.subs))
TEMPLS += ${TEMPLATES_${EPICS_BASETYPE}}
TEMPLS += ${TEMPLATES_${EPICSVERSION}}
export TEMPLS

SCR = $(if ${SCRIPTS},$(filter-out -none-,${SCRIPTS}),$(wildcard *.cmd))
SCR += ${SCRIPTS_${EPICS_BASETYPE}}
SCR += ${SCRIPTS_${EPICSVERSION}}
export SCR

DOCUDIR = .
#DOCU = $(foreach DIR,${DOCUDIR},$(wildcard ${DIR}/*README*) $(foreach EXT,${DOCUEXT}, $(wildcard ${DIR}/*.${EXT})))
export DOCU

# Loop over all target architectures for third run.
# Go to O.${T_A} subdirectory because RULES.Vx only work there:


#>>>
# Filter architectures to build using EXCLUDE_ARCHS and ARCH_FILTER.
ifneq (${EPICS_BASETYPE},3.13)
CROSS_COMPILER_TARGET_ARCHS := ${EPICS_HOST_ARCH} ${CROSS_COMPILER_TARGET_ARCHS}
endif # !3.13
#<<<


CROSS_COMPILER_TARGET_ARCHS := $(filter-out $(addprefix %,${EXCLUDE_ARCHS}),$(filter-out $(addsuffix %,${EXCLUDE_ARCHS}),$(if ${ARCH_FILTER},$(filter ${ARCH_FILTER},${CROSS_COMPILER_TARGET_ARCHS}),${CROSS_COMPILER_TARGET_ARCHS})))



#>>>
define MAKELINKDIRS
LINKDIRS+=O.${EPICSVERSION}_$1
O.${EPICSVERSION}_$1:
	$(LN) O.${EPICSVERSION}_$2 O.${EPICSVERSION}_$1
endef
#<<<



$(foreach a,${CROSS_COMPILER_TARGET_ARCHS},$(foreach l,$(LINK_$a),$(eval $(call MAKELINKDIRS,$l,$a))))

SRCS_Linux = ${SOURCES_Linux}
SRCS_Linux += ${SOURCES_${EPICS_BASETYPE}_Linux}
SRCS_Linux += ${SOURCES_Linux_${EPICS_BASETYPE}}
export SRCS_Linux
SRCS_vxWorks = ${SOURCES_vxWorks}
SRCS_vxWorks += ${SOURCES_${EPICS_BASETYPE}_vxWorks}
SRCS_vxWorks += ${SOURCES_vxWorks_${EPICS_BASETYPE}}
export SRCS_vxWorks

install build debug:: $(MAKE_FIRST)
	@echo "MAKING EPICS VERSION R${EPICSVERSION}"

uninstall::
	$(RMDIR) ${INSTALL_REV}

debug::
	@echo "EPICS_BASE = ${EPICS_BASE}"
	@echo "EPICSVERSION = ${EPICSVERSION}" 
	@echo "EPICS_BASETYPE = ${EPICS_BASETYPE}" 
	@echo "CROSS_COMPILER_TARGET_ARCHS = ${CROSS_COMPILER_TARGET_ARCHS}"
	@echo "EXCLUDE_ARCHS = ${EXCLUDE_ARCHS}"
	@echo "LIBVERSION = ${LIBVERSION}"

install build::
# Delete old build if INSTBASE has changed and module depends on other modules.
	@for ARCH in ${CROSS_COMPILER_TARGET_ARCHS}; do \
	    echo '$(realpath ${EPICS_MODULES})' | cmp -s O.${EPICSVERSION}_$$ARCH/INSTBASE || \
	    ( grep -qs "^[^#]" O.${EPICSVERSION}_$$ARCH/*.dep && \
	     (echo "rebuilding $$ARCH"; $(RMDIR) O.${EPICSVERSION}_$$ARCH) ) || true; \
	done

# Loop over all architectures.
install build debug::
	@for ARCH in ${CROSS_COMPILER_TARGET_ARCHS}; do \
	    umask 002; ${MAKE} -f ${USERMAKEFILE} T_A=$$ARCH $@; \
	done

