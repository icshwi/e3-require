# EPICSVERSION defined 
# Second or third run (see T_A branch below)

EPICS_BASE=${EPICS_LOCATION}/base-${EPICSVERSION}



${CONFIG}/CONFIG:
	@echo "ERROR: EPICS release ${EPICSVERSION} not installed on this host."

# Some TOP and EPICS_BASE tweeking necessary to work around release check in 3.14.10+.
EB=${EPICS_BASE}

TOP:=${EPICS_BASE}

-include ${CONFIG}/CONFIG

EPICS_BASE:=${EB}
SHRLIB_VERSION=
COMMON_DIR = O.${EPICSVERSION}_Common
# do not link *everything* with readline (and curses)
COMMANDLINE_LIBRARY =
# Relax (3.13) cross compilers (default is STRICT) to allow sloppier syntax.
CMPLR=STD
GCC_STD = $(GCC)
CXXCMPLR=ANSI
G++_ANSI = $(G++) -ansi
OBJ=.o






##########>> 
ifndef T_A


include require_2_1.mk


##########>>
else # T_A


ifeq ($(filter O.%,$(notdir ${CURDIR})),)

include require_2_2.mk

else 

include require_2_3.mk

endif


##########>>
endif # T_A defined
