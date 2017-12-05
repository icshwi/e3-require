#!/bin/bash
#
#  Copyright (c) 2004 - 2017    Paul Scherrer Institute 
#  Copyright (c) 2017 - Present European Spallation Source ERIC
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
#
#  PSI original iocsh author : Dirk Zimoch
#  ESS specific iocsh author : Jeong Han Lee
#                     email  : han.lee@esss.se
#
#
# 

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -g  SC_VERSION="v0.2"
declare -g  STARTUP=""

set -a
. ${SC_TOP}/ess-env.conf
set +a

. ${SC_TOP}/iocsh_functions


check_mandatory_env_settings

#
# IOCSH_HASH_VERSION is defined when doing 'make install'
SC_VERSION+=-${IOCSH_HASH_VERSION}.PID-${BASHPID}

#
# PS1 is defined as IOCSH Git HASH + HOSTNAME + BASHPID
IOCSH_PS1=$(iocsh_ps1 "${IOCSH_HASH_VERSION}" "${BASHPID}")

#
# Default Initial Startup file for REQUIRE and minimal environment

IOC_STARTUP=/tmp/${SC_SCRIPTNAME}-${SC_VERSION}-startup

# EPICS_DRIVER_PATH defined in iocsh and startup.script_common
# Remember, driver is equal to module, so EPICS_DRIVER_PATH is the module directory
# In our jargon. It is the same as ${EPICS_MODULES}

trap "softIoc_end ${IOC_STARTUP}" EXIT HUP INT TERM


{
    printIocEnv;
    loadRequire;
    loadFiles "$@";

    printf "epicsEnvSet IOCSH_PS1 \"$IOCSH_PS1\"\n";
    printf "epicsEnvShow T_A\n";
    printf "epicsEnvShow EPICS_HOST_ARCH\n";
    #    printf "var requireDebug 1\n";

    if [ "$init" != NO ]; then
	printf "iocInit\n"
    fi
    
}  > ${IOC_STARTUP}

ulimit -c unlimited

# -x "PREFIX"
# PREFIX:exit & PREFIX:BaseVersion PVs are added to softIoc
# We can end this IOC via caput PREFIX:exit 1

softIoc -D ${EPICS_BASE}/dbd/softIoc.dbd "${IOC_STARTUP}" 2>&1

