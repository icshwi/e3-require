#!/bin/bash
#
#  Copyright (c) 2004 - 2017    Paul Scherrer Institute 
#  Copyright (c) 2017 - 2019    European Spallation Source ERIC
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
#  Add IOCSH_TOP in order to access where the iocsh.bash is executed
#  Thursday, May 31 00:04:07 CEST 2018, jhlee
#  
#  Add PVA support to call softIOCPVA if BASE >= 7.0.1.1
#  Tuesday, October  2 14:26:49 CEST 2018, jhlee

#  Tweak REQUIRE PVs to be an unique per a single IOC in OS
#  Set Hostname up to 30 chars
#  Thursday, October  4 17:00:53 CEST 2018, jhlee
#
#  0.3.5 : Set the proper limitation of REQUIRE PV name
#  0.3.6 : In case, we know where $0 is, sourcing setE3Env.bash by itself
#  0.3.7 : Introduce the local mode with -l
#  0.3.8 : Use mktemp, and protect iocsh.bash when there is no diskspace
#  0.3.9 : LD_BIND_NOW=1 for resolving symbols at startup.
#  0.4.0 : fixed registryJLinkAdd failed pva error from base 7.0.3
#          Wednesday, September 11 17:27:59 CEST 2019
#
declare -gr SC_SCRIPT="$(realpath "$0")";
declare -gr SC_SCRIPTNAME=${0##*/};
declare -gr SC_TOP="${SC_SCRIPT%/*}";
declare -g  SC_VERSION="v0.3.9";
declare -g  STARTUP="";
declare -g  BASECODE="";


set -a
. ${SC_TOP}/ess-env.conf
set +a

. ${SC_TOP}/iocsh_functions


# The most unique environment variable for e3 is EPICS_DRIVER_PATH
#
if [[ $(checkIfVar ${EPICS_DRIVER_PATH}) -eq "$NON_EXIST" ]]; then
    set -a
    . ${SC_TOP}/setE3Env.bash "no_msg"
    set +a
fi


BASECODE="$(basecode_generator)"

check_mandatory_env_settings

#
# IOCSH_HASH_VERSION is defined when doing 'make install'
SC_VERSION+=-${IOCSH_HASH_VERSION}.PID-${BASHPID}
#
# We define IOCSH Git HASH + HOSTNAME + BASHPID
IOCSH_PS1=$(iocsh_ps1     "${IOCSH_HASH_VERSION}" "${BASHPID}")
REQUIRE_IOC=$(require_ioc "${IOCSH_HASH_VERSION}" "${BASHPID}")
#
# Default Initial Startup file for REQUIRE and minimal environment
IOC_STARTUP=$(mktemp -q --suffix=_iocsh_${SC_VERSION}) || die 1 "${SC_SCRIPTNAME} CANNOT create the startup file, please check the disk space";
#
# To get the absolute path where iocsh.bash is executed
IOCSH_TOP=${PWD}

# EPICS_DRIVER_PATH defined in iocsh and startup.script_common
# Remember, driver is equal to module, so EPICS_DRIVER_PATH is the module directory
# In our jargon. It is the same as ${EPICS_MODULES}

trap "softIoc_end ${IOC_STARTUP}" EXIT HUP INT TERM

{
    printIocEnv;
    printf "# Set REQUIRE_IOC for its internal PVs\n";
    printf "epicsEnvSet REQUIRE_IOC \"${REQUIRE_IOC}\"\n";
    printf "#\n";
    printf "# Set E3_IOCSH_TOP for the absolute path where %s is executed.\n" "${SC_SCRIPTNAME}"
    printf "epicsEnvSet E3_IOCSH_TOP \"${IOCSH_TOP}\"\n";
    printf "#\n";
    
    loadRequire;

    loadFiles "$@";

    printf "# Set the IOC Prompt String One \n";
    printf "epicsEnvSet IOCSH_PS1 \"$IOCSH_PS1\"\n";
    printf "#\n";

    if [ "$REALTIME" == "RT" ]; then
	printf "# Real Time \"$REALTIME\"\n";
    fi
    
    if [ "$init" != NO ]; then
	printf "# \n";
	printf "iocInit\n"
    fi
    
}  > ${IOC_STARTUP}

ulimit -c unlimited

if [ "$REALTIME" == "RT" ]; then
    export LD_BIND_NOW=1;
    __CHRT__="chrt --fifo 1 ";
    printf "## \n";
    printf "## Better support for Real-Time IOC Application.\n"
    printf "## Now we set 'export LD_BIND_NOW=%s'\n" "$LD_BIND_NOW";
    printf "## If one may meet the 'Operation not permitted' message, \n";
    printf "## please run %s without the real-time option\n" "$SC_SCRIPTNAME";
    printf "##\n";
else
    __CHRT__="";
fi

if [[ ${BASECODE} -ge  07000101 ]]; then
    __PVA__="PVA"
else
    __PVA__=""
fi

#
#
${__CHRT__}${EPICS_BASE}/bin/${EPICS_HOST_ARCH}/softIoc${__PVA__} -D ${EPICS_BASE}/dbd/softIoc${__PVA__}.dbd "${IOC_STARTUP}" 2>&1

