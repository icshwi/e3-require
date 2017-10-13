
# This is the one time path in order to compile and install
# require within EPICS Environment. After the installation
# include $(REQUIRE_TOOLS)/driver.makefile should be used
#
where_am_I := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include ${where_am_I}/App/tools/driver.makefile

BUILDCLASSES += Linux

SOURCES += require.c
DBDS    += require.dbd
SOURCES += runScript.c
DBDS    += runScript.dbd

SOURCES += dbLoadTemplate.y
DBDS    += dbLoadTemplate.dbd

SOURCES_T2 += strdup.c
SOURCES_vxWorks   += asprintf.c
HEADERS += strdup.h asprintf.h
HEADERS += require.h
HEADERS += require_env.h

# We need to find the Linux link.h before the EPICS link.h
USR_INCLUDES_Linux=-idirafter $(EPICS_BASE)/include 


# This should really go into some global WIN32 config file
USR_CFLAGS_WIN32 += /D_WIN32_WINNT=0x501

TEMPLATES += moduleversion.template

dbLoadTemplate.c: dbLoadTemplate_lex.c ../dbLoadTemplate.h


