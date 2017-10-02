
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

# We need to find the Linux link.h before the EPICS link.h
USR_INCLUDES_Linux=-idirafter ${EPICS_BASE}/include 

# Pass T_A to the code
USR_CFLAGS += -DT_A=${T_A}

# This should really go into some global WIN32 config file
USR_CFLAGS_WIN32 += /D_WIN32_WINNT=0x501

dbLoadTemplate.c: dbLoadTemplate_lex.c ../dbLoadTemplate.h


