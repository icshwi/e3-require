## RUN 3
# Target architecture defined.
# Still in source directory, third run.



#------>#

ifeq ($(filter ${OS_CLASS},${OS_CLASS_LIST}),)

install% build%: build
install build:
	@echo Skipping ${T_A} because $(if ${OS_CLASS},OS_CLASS=\"${OS_CLASS}\" is not in BUILDCLASSES=\"${BUILDCLASSES}\",it is not available for R$(EPICSVERSION).)
%:
	@true



#<----->#
else ifeq ($(shell which $(firstword ${CC})),)

install% build%: build
install build:
	@echo Warning: Skipping ${T_A} because cross compiler $(firstword ${CC}) is not installed.
%:
	@true

#<----->#
else




O.%:
	$(MKDIR) $@




##----->##
ifeq ($(shell echo "${LIBVERSION}" | grep -v -E "^[0-9]+\.[0-9]+\.[0-9]+\$$"),)
install:: build
	@test ! -d ${MODULE_LOCATION}/R${EPICSVERSION}/lib/${T_A} || \
        (echo -e "Error: ${MODULE_LOCATION}/R${EPICSVERSION}/lib/${T_A} already exists.\nNote: If you really want to overwrite then uninstall first."; false)

##<---->##
else
install:: build
	@test ! -d ${MODULE_LOCATION}/R${EPICSVERSION}/lib/${T_A} || \
        (echo -e "Warning: Re-installing ${MODULE_LOCATION}/R${EPICSVERSION}/lib/${T_A}"; \
        $(RMDIR) ${MODULE_LOCATION}/R${EPICSVERSION}/lib/${T_A})

##<-----##
endif



install build debug:: O.${EPICSVERSION}_Common O.${EPICSVERSION}_${T_A}
	@${MAKE} -C O.${EPICSVERSION}_${T_A} -f ../${USERMAKEFILE} $@

#<------#
endif










# Add sources for specific epics types (3.13 or 3.14) or architectures.
ARCH_PARTS     = ${T_A} $(subst -, ,${T_A}) ${OS_CLASS}

VAR_EXTENSIONS = ${EPICS_BASETYPE} ${EPICSVERSION} ${ARCH_PARTS} ${ARCH_PARTS:%=${EPICS_BASETYPE}_%} ${ARCH_PARTS:%=${EPICSVERSION}_%}

REQ            = ${REQUIRED} $(foreach x, ${VAR_EXTENSIONS}, ${REQUIRED_$x})

SRCS          += $(foreach x, ${VAR_EXTENSIONS}, ${SOURCES_$x})

USR_LIBOBJS   += ${LIBOBJS} $(foreach x,${VAR_EXTENSIONS},${LIBOBJS_$x})

BINS          += $(foreach x, ${VAR_EXTENSIONS}, ${BINS_$x})


export VAR_EXTENSIONS
export REQ
export USR_LIBOBJS
export BINS
export CFG


