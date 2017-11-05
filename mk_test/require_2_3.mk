## RUN 4
# In O.* directory.



#>>>>
define ADD_FOREIGN_INCLUDES
$(eval $(1)_VERSION := $(patsubst ${EPICS_MODULES}/$(1)/%/R${EPICSVERSION}/include,%,$(firstword $(shell ls -dvr ${EPICS_MODULES}/$(1)/+([0-9]).+([0-9]).+([0-9])/R${EPICSVERSION}/include 2>/dev/null))))
INSTALL_INCLUDES += $$(patsubst %,-I${EPICS_MODULES}/$(1)/%/R${EPICSVERSION}/include,$$($(1)_VERSION))
endef
#>>>>


#>>>>
# Manually required modules.
define ADD_MANUAL_DEPENDENCIES
$(eval $(1)_VERSION := $(or $(patsubst ${EPICS_MODULES}/$(1)/%/R${EPICSVERSION},%,$(firstword $(shell ls -dvr ${EPICS_MODULES}/$(1)/+([0-9]).+([0-9]).+([0-9])/R${EPICSVERSION} 2>/dev/null))),$(basename $(lastword $(subst -, ,$(basename $(realpath ${INSTBASE}/iocBoot/R${EPICSVERSION}/${T_A}/$(1).dep)))))))
endef
#>>>>




# Add macros like USR_CFLAGS_vxWorks.
EXTENDED_VARS=INCLUDES CFLAGS CXXFLAGS CPPFLAGS CODE_CXXFLAGS LDFLAGS
$(foreach v,${EXTENDED_VARS},$(foreach x,${VAR_EXTENSIONS},$(eval $v+=$${$v_$x}) $(eval USR_$v+=$${USR_$v_$x})))




CFLAGS += ${EXTRA_CFLAGS}

COMMON_DIR_3.14 = ../O.${EPICSVERSION}_Common
COMMON_DIR_3.13 = .
COMMON_DIR = ${COMMON_DIR_${EPICS_BASETYPE}}

# Remove include directory for this module from search path.
# 3.13 and 3.14 use different variables
INSTALL_INCLUDES =
EPICS_INCLUDES =

# Add include directory of foreign modules to include file search path.
# Default is to use latest version of any module.
# The user can overwrite the version by defining <module>_VERSION=<version>.
# For each foreign module look for include/ for the EPICS base version in use.
# The user can overwrite (or add) by defining <module>_INC=<relative/path> (not recommended!).
# Only really existing directories are added to the search path.

# The tricky part is to sort versions numerically. Make can't but ls -v can.
# Only accept numerical versions (needs extended glob).



$(eval $(foreach m,$(filter-out $(PRJ),$(notdir $(wildcard ${EPICS_MODULES}/*))),$(call ADD_FOREIGN_INCLUDES,$m)))

$(eval $(foreach m,${REQ},$(call ADD_MANUAL_DEPENDENCIES,$m)))


INSTALLRULE = install:

BUILDRULE   = build:

BASERULES   = ${EPICS_BASE}/configure/RULES



INSTALL_REV     = ${MODULE_LOCATION}/R${EPICSVERSION}
INSTALL_BIN     = ${INSTALL_REV}/bin/$(T_A)
INSTALL_LIB     = ${INSTALL_REV}/lib/$(T_A)
INSTALL_INCLUDE = ${INSTALL_REV}/include
INSTALL_DBD     = ${INSTALL_REV}/dbd
INSTALL_DB      = ${INSTALL_REV}/db
INSTALL_CFG     = ${INSTALL_REV}/cfg
INSTALL_DOC     = ${MODULE_LOCATION}/doc
INSTALL_SCR     = ${INSTALL_REV}


LIBRARY_OBJS = $(strip ${LIBOBJS} $(foreach l,${USR_LIBOBJS},$(addprefix ../,$(filter-out /%,$l))$(filter /%,$l)))

MODULELIB    = $(if ${LIBRARY_OBJS},${LIB_PREFIX}${PRJ}${SHRLIB_SUFFIX},)


# PROD_vxWorks=${MODULELIB}
LIBOBJS         += $(addsuffix $(OBJ),$(notdir $(basename $(filter-out %.$(OBJ) %(LIB_SUFFIX),$(sort ${SRCS})))))
LIBOBJS         += $(filter /%.$(OBJ) /%(LIB_SUFFIX),${SRCS})
LIBOBJS         += ${LIBRARIES:%=${INSTALL_LIB}/%Lib}
LIBS             = -L ${EPICS_BASE_LIB} ${BASELIBS:%=-l%}
LINK.cpp        += ${LIBS}
PRODUCT_OBJS     = ${LIBRARY_OBJS}


# Linux
LOADABLE_LIBRARY = $(if ${LIBRARY_OBJS},${PRJ},)

# Handle registry stuff automagically if we have a dbd file.
# See ${REGISTRYFILE} and ${EXPORTFILE} rules below.
LIBOBJS         += $(if $(MODULEDBD), $(addsuffix $(OBJ),$(basename ${REGISTRYFILE} ${EXPORTFILE})))








# For backward compatibility:
# Provide a global symbol for every version with the same
# major and equal or smaller minor version number.
# Other code using this will look for one of those symbols.
# Add an undefined symbol for the version of every used driver.
# This is done with the #define in the used headers (see below).


MAJOR_MINOR_PATCH=$(subst ., ,${LIBVERSION})
MAJOR=$(word 1,${MAJOR_MINOR_PATCH})
MINOR=$(word 2,${MAJOR_MINOR_PATCH})
PATCH=$(word 3,${MAJOR_MINOR_PATCH})



ifneq (${MINOR},)


ALLMINORS     := $(shell for ((i=0;i<=${MINOR};i++));do echo $$i;done)
PREREQUISITES = $(shell ${MAKEHOME}/getPrerequisites.tcl ${INSTALL_INCLUDE} | grep -vw ${PRJ})

PROVIDES      = ${ALLMINORS:%=-Wl,--defsym,${PRJ}Lib_${MAJOR}.%=0}


endif # MINOR





LDFLAGS += ${PROVIDES} ${USR_LDFLAGS_${T_A}}

# Create and include dependency files.
# 3.14.8 uses HDEPENDS to select depends mode
# 3.14.12 uses 'HDEPENDSCFLAGS -MMD' (does not catch #include <...>)
# 3.15 uses 'HDEPENDS_COMPFLAGS = -MM -MF $@' (does not catch #include <...>)


HDEPENDS = 
HDEPENDS_METHOD = COMP
HDEPENDS_COMPFLAGS = -c
MKMF = DO_NOT_USE_MKMF
CPPFLAGS += -MD



-include *.d

# Need to find source dbd files relative to one dir up but generated dbd files in this dir.
DBDFILES += ${DBD_SRCS:%=../%}
DBD_PATH = $(sort $(dir ${DBDFILES}))

DBDEXPANDPATH = $(addprefix -I , ${DBD_PATH} ${EPICS_BASE}/dbd)
USR_DBDFLAGS += $(DBDEXPANDPATH)

# Search all directories where sources or headers come from, plus existing os dependend subdirectories.
SRC_INCLUDES = $(addprefix -I, $(wildcard $(foreach d,$(call uniq, $(filter-out /%,$(dir ${SRCS:%=../%} ${HDRS:%=../%}))), $d $(addprefix $d/, os/${OS_CLASS} $(POSIX_$(POSIX)) os/default))))

# Different macro name for 3.14.8.
GENERIC_SRC_INCLUDES = $(SRC_INCLUDES)




# Create dbd file for snl code.
DBDFILES += $(patsubst %.st,%_snl.dbd,$(notdir $(filter %.st,${SRCS})))
DBDFILES += $(patsubst %.stt,%_snl.dbd,$(notdir $(filter %.stt,${SRCS})))

# Create dbd file for GPIB code.
DBDFILES += $(patsubst %.gt,%.dbd,$(notdir $(filter %.gt,${SRCS})))

# Create dbd file with references to all subRecord functions.
# Problem: functions may be commented out. Better preprocess, but then generate headers first.
#define maksubfuncfile
#/static/ {static=1} \
#/\([\t ]*(struct)?[\t ]*(genSub|sub|aSub)Record[\t ]*\*[\t ]*\w+[\t ]*\)/ { \
#    match ($$0,/(\w+)[\t ]*\([\t ]*(struct)?[\t ]*\w+Record[\t ]*\*[\t ]*\w+[\t ]*\)/, a); \
#    n=a[1];if(!static && !f[n]){f[n]=1;print "function (" n ")"}} \
#/[;{}]/ {static=0}
#endef 
#
#$(shell awk '$(maksubfuncfile)' $(addprefix ../,$(filter %.c %.cc %.C %.cpp, $(SRCS))) > ${SUBFUNCFILE})
#DBDFILES += $(if $(shell cat ${SUBFUNCFILE}),${SUBFUNCFILE})

# snc location in 3.14: From latest version of module seq or fall back to globally installed snc.
SNC=$(lastword $(dir ${EPICS_BASE})seq/bin/$(EPICS_HOST_ARCH)/snc $(shell ls -dv ${EPICS_MODULES}/seq/$(or $(seq_VERSION),+([0-9]).+([0-9]).+([0-9]))/R${EPICSVERSION}/bin/${EPICS_HOST_ARCH}/snc 2>/dev/null))







ifneq ($(strip ${DBDFILES}),)
MODULEDBD=${PRJ}.dbd
endif



# If we build a library, provide a version variable.
ifneq ($(MODULELIB),)
LIBOBJS += $(addsuffix $(OBJ),$(basename ${VERSIONFILE}))
endif # MODULELIB





debug::
	@echo "BUILDCLASSES = ${BUILDCLASSES}"
	@echo "OS_CLASS = ${OS_CLASS}"
	@echo "T_A = ${T_A}"
	@echo "MODULEDBD = ${MODULEDBD}"
	@echo "RECORDS = ${RECORDS}"
	@echo "MENUS = ${MENUS}"
	@echo "BPTS = ${BPTS}"
	@echo "HDRS = ${HDRS}"
	@echo "SOURCES = ${SOURCES}" 
	@echo "SOURCES_${EPICS_BASETYPE} = ${SOURCES_${EPICS_BASETYPE}}" 
	@echo "SOURCES_${OS_CLASS} = ${SOURCES_${OS_CLASS}}" 
	@echo "SRCS = ${SRCS}" 
	@echo "LIBOBJS = ${LIBOBJS}"
	@echo "DBDS = ${DBDS}"
	@echo "DBDS_${EPICS_BASETYPE} = ${DBDS_${EPICS_BASETYPE}}"
	@echo "DBDS_${OS_CLASS} = ${DBDS_${OS_CLASS}}"
	@echo "DBD_SRCS = ${DBD_SRCS}"
	@echo "DBDFILES = ${DBDFILES}"
	@echo "TEMPLS = ${TEMPLS}"
	@echo "LIBVERSION = ${LIBVERSION}"
	@echo "MODULE_LOCATION = ${MODULE_LOCATION}"





${BUILDRULE} MODULEINFOS
${BUILDRULE} ${MODULEDBD}
${BUILDRULE} $(addprefix ${COMMON_DIR}/,$(addsuffix Record.h,${RECORDS}))
${BUILDRULE} ${DEPFILE}




# Include default EPICS Makefiles (version dependent).
# Avoid library installation when doing 'make build'.
INSTALL_LOADABLE_SHRLIBS=
# Avoid installing *.munch to bin directory.
INSTALL_MUNCHS=
include ${BASERULES}





# Fix incompatible release rules.
RELEASE_DBDFLAGS = -I ${EPICS_BASE}/dbd
RELEASE_INCLUDES = -I${EPICS_BASE}/include


# For EPICS 3.15:
RELEASE_INCLUDES += -I${EPICS_BASE}/include/compiler/${CMPLR_CLASS}
RELEASE_INCLUDES += -I${EPICS_BASE}/include/os/${OS_CLASS}
# Dor EPICS 3.13:
# EPICS_INCLUDES += -I$(EPICS_BASE_INCLUDE) -I$(EPICS_BASE_INCLUDE)/os/$(OS_CLASS)



# Find all sources and set vpath accordingly.
$(foreach file, ${SRCS} ${TEMPLS} ${SCR}, $(eval vpath $(notdir ${file}) ../$(dir ${file})))

# Do not treat %.dbd the same way because it creates a circular dependency
# if a source dbd has the same name as the project dbd. Have to clear %.dbd and not use ../ path.
# But the %Record.h and menu%.h rules need to find their dbd files (example: asyn).


vpath %.dbd
vpath %Record.dbd ${DBD_PATH}
vpath menu%.dbd ${DBD_PATH}

# Find header files to install.
vpath %.h $(addprefix ../,$(sort $(dir $(filter-out /%,${HDRS}) ${SRCS}))) $(sort $(dir $(filter /%,${HDRS})))

PRODUCTS = ${MODULELIB} ${MODULEDBD} ${DEPFILE}



MODULEINFOS:
	@echo ${PRJ} > MODULENAME
	@echo $(realpath ${EPICS_MODULES}) > INSTBASE
	@echo ${PRODUCTS} > PRODUCTS
	@echo ${LIBVERSION} > LIBVERSION

# Build one module dbd file by expanding all source dbd files.
# We can't use dbExpand (from the default EPICS make rules)
# because it has too strict checks to be used for a loadable module.
${MODULEDBD}: ${DBDFILES}
	@echo "Expanding $@"
	${MAKEHOME}expandDBD.tcl -$(basename ${EPICSVERSION}) ${DBDEXPANDPATH} $^ > $@




# Install everything.
INSTALL_LIBS = ${MODULELIB:%=${INSTALL_LIB}/%}
INSTALL_DEPS = ${DEPFILE:%=${INSTALL_LIB}/%}
INSTALL_DBDS = ${MODULEDBD:%=${INSTALL_DBD}/%}
INSTALL_HDRS = $(addprefix ${INSTALL_INCLUDE}/,$(notdir ${HDRS}))
INSTALL_DBS  = $(addprefix ${INSTALL_DB}/,$(notdir ${TEMPLS}))
INSTALL_SCRS = $(addprefix ${INSTALL_SCR}/,$(notdir ${SCR}))
INSTALL_BINS = $(addprefix ${INSTALL_BIN}/,$(notdir ${BINS}))
INSTALL_CFGS = $(CFG:%=${INSTALL_CFG}/%)





debug::
	@echo "INSTALL_LIB = $(INSTALL_LIB)"
	@echo "INSTALL_LIBS = $(INSTALL_LIBS)"
	@echo "INSTALL_DEPS = $(INSTALL_DEPS)"
	@echo "INSTALL_DBD = $(INSTALL_DBD)"
	@echo "INSTALL_DBDS = $(INSTALL_DBDS)"
	@echo "INSTALL_INCLUDE = $(INSTALL_INCLUDE)"
	@echo "INSTALL_HDRS = $(INSTALL_HDRS)"
	@echo "INSTALL_DB = $(INSTALL_DB)"
	@echo "INSTALL_DBS = $(INSTALL_DBS)"
	@echo "INSTALL_SCR = $(INSTALL_SCR)"
	@echo "INSTALL_SCRS = $(INSTALL_SCRS)"
	@echo "INSTALL_CFG = $(INSTALL_CFG)"
	@echo "INSTALL_CFGS = $(INSTALL_CFGS)"
	@echo "INSTALL_BIN = $(INSTALL_BIN)"
	@echo "INSTALL_BINS = $(INSTALL_BINS)"

INSTALLS += ${INSTALL_CFGS} ${INSTALL_SCRS} ${INSTALL_HDRS} ${INSTALL_DBDS} ${INSTALL_DBS} ${INSTALL_LIBS} ${INSTALL_BINS} ${INSTALL_DEPS}





${INSTALLRULE} ${INSTALLS}





${INSTALL_DBDS}: $(notdir ${INSTALL_DBDS})
	@echo "Installing module dbd file $@"
	$(INSTALL) -d -m444 $< $(@D)



${INSTALL_LIBS}: $(notdir ${INSTALL_LIBS})
	@echo "Installing module library $@"
	$(INSTALL) -d -m555 $< $(@D)



${INSTALL_DEPS}: $(notdir ${INSTALL_DEPS})
	@echo "Installing module dependency file $@"
	$(INSTALL) -d -m444 $< $(@D)

# Fix templates for older EPICS versions:
# Remove 'alias' for EPICS <= 3.14.10
# and 'info' and macro defaults for EPICS 3.13.
# Make use of differences in defined variables.


# 3.14.10+
${INSTALL_DBS}: $(notdir ${INSTALL_DBS})
	@echo "Installing module template files $^ to $(@D)"
	$(INSTALL) -d -m444 $^ $(@D)


${INSTALL_SCRS}: $(notdir ${SCR})
	@echo "Installing scripts $^ to $(@D)"
	$(INSTALL) -d -m555 $^ $(@D)

${INSTALL_CFGS}: ${CFGS}
	@echo "Installing configuration files $^ to $(@D)"
	$(INSTALL) -d -m444 $^ $(@D)

${INSTALL_BINS}: $(addprefix ../,$(filter-out /%,${BINS})) $(filter /%,${BINS})
	@echo "Installing binaries $^ to $(@D)"
	$(INSTALL) -d -m555 $^ $(@D)

# Create SNL code from st/stt file.
# (RULES.Vx only allows ../%.st, 3.14 has no .st rules at all.)
# Important to have %.o: %.st and %.o: %.stt rule before %.o: %.c rule!
# Preprocess in any case because docu and implemented EPICS rules mismatch here.

CPPSNCFLAGS1  = $(filter -D%, ${OP_SYS_CFLAGS})
CPPSNCFLAGS1 += $(filter-out ${OP_SYS_INCLUDE_CPPFLAGS} ,${CPPFLAGS}) ${CPPSNCFLAGS}
CPPSNCFLAGS1 += -I $(dir $(SNC))../../include
SNCFLAGS += -r

%$(OBJ) %_snl.dbd: %.st
	@echo "Preprocessing $(<F)"
	$(RM) $(*F).i
	$(CPP) ${CPPSNCFLAGS1} $< > $(*F).i
	@echo "Converting $(*F).i"
	$(RM) $@
	$(SNC) $(TARGET_SNCFLAGS) $(SNCFLAGS) $(*F).i
	@echo "Compiling $(*F).c"
	$(RM) $@
	$(COMPILE.c) ${SNC_CFLAGS} $(*F).c


%$(OBJ) %_snl.dbd: %.stt
	@echo "Preprocessing $(<F)"
	$(RM) $(*F).i
	$(CPP) ${CPPSNCFLAGS1} $< > $(*F).i
	@echo "Converting $(*F).i"
	$(RM) $@
	$(SNC) $(TARGET_SNCFLAGS) $(SNCFLAGS) $(*F).i
	@echo "Compiling $(*F).c"
	$(RM) $@
	$(COMPILE.c) ${SNC_CFLAGS} $(*F).c


# Create GPIB code from *.gt file.
%.c %.dbd %.list: %.gt
	@echo "Converting $*.gt"
	${LN} $< $(*F).gt
	gdc $(*F).gt



${VERSIONFILE}:
	echo "char _${PRJ}LibRelease[] = \"${LIBVERSION}\";" >> $@

# EPICS R3.14.*:
# Create file to fill registry from dbd file.
${REGISTRYFILE}: ${MODULEDBD}
	$(RM) $@ temp.cpp
	$(PERL) $(EPICS_BASE_HOST_BIN)/registerRecordDeviceDriver.pl $< $(basename $@) | grep -v iocshRegisterCommon > temp.cpp
	$(MV) temp.cpp $@

# 3.14.12 complains if this rule is not overwritten
./%Include.dbd:



CORELIB = ${CORELIB_${OS_CLASS}}

LSUFFIX_YES=$(SHRLIB_SUFFIX)
LSUFFIX_NO=$(LIB_SUFFIX)
LSUFFIX=$(LSUFFIX_$(SHARED_LIBRARIES))


${EXPORTFILE}: $(filter-out $(basename ${EXPORTFILE})$(OBJ),${LIBOBJS})
	$(RM) $@
	$(NM) $^ ${BASELIBS:%=${EPICS_BASE}/lib/${T_A}/${LIB_PREFIX}%$(LSUFFIX)} ${CORELIB} | awk '$(makexportfile)' > $@

# Create dependency file for recursive requires.
${DEPFILE}: ${LIBOBJS} $(USERMAKEFILE)
	@echo "Collecting dependencies"
	$(RM) $@
	@echo "# Generated file. Do not edit." > $@
	# Check dependencies on other module headers.
	cat *.d 2>/dev/null | sed 's/ /\n/g' | sed -n 's%${EPICS_MODULES}/*\([^/]*\)/\([0-9]*\.[0-9]*\)\.[0-9]*/.*%\1 \2%p;s%$(EPICS_MODULES)/*\([^/]*\)/\([^/]*\)/.*%\1 \2%p'| sort -u >> $@
ifneq ($(strip ${REQ}),)
	# Manully added dependencies: ${REQ}
	@$(foreach m,${REQ},echo "$m $(or ${$m_VERSION},$(and $(wildcard ${EPICS_MODULES}/$m),$(error REQUIRED module $m has no numbered version. Set $m_VERSION)),$(warning REQUIRED module $m not found for ${T_A}.))" >> $@;)
endif



# Remove MakefileInclude after we are done because it interfers with our way to build.
$(BUILDRULE)
	$(RM) MakefileInclude
