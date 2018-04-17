#!/bin/bash
#  Copyright (c) 2017 - Present  Jeong Han Lee
#  Copyright (c) 2017 - Present  European Spallation Source ERIC
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
#   Shell   : setE3Env.bash
#   Author  : Jeong Han Lee
#   email   : jeonghan.lee@gmail.com
#   date    : Tuesday, April 17 13:53:25 CEST 2018
#
#   version : 0.3.0



unset EPICS_BASE
unset EPICS_HOST_ARCH
unset E3_REQUIRE_NAME
unset E3_REQUIRE_VERSION
unset E3_REQUIRE_LOCATION

unset E3_REQUIRE_BIN
unset E3_REQUIRE_LIB
unset E3_REQUIRE_INC
unset E3_REQUIRE_DB

unset E3_SITEMODS_PATH
unset E3_SITELIBS_PATH
unset E3_SITEAPPS_PATH


unset EPICS_DRIVER_PATH

unset PATH
unset LD_LIBRARY_PATH

unset SCRIPT_DIR



THIS_SRC=${BASH_SOURCE[0]}
SRC_PATH=${THIS_SRC%/*}
SRC_NAME=${THIS_SRC##*/}


# e3.cfg will be generated via make e3-site-conf
# The Global Variables are defined in configure/E3/DEFINES_REQUIRE
# RULES is defined in configure/E3/RULES_REQUIRE
#
# Dynamic Changes according to the time when one installs REQUIRE
# 
# declare -g DEFAULT_EPICS_BASE=/epics/base-3.15.5
# declare -g DEFAULT_REQUIRE_NAME=require
# declare -g DEFAULT_REQUIRE_VERSION=3.0.0

set -a
source $SRC_PATH/e3.cfg
set +a



#ESS_LIBS=/opt/ess
#ESS_ETHERLAB=/opt/etherlab
#ESS_OPCUA=${ESS_LIBS}/opcUa
#ESS_ETHERLAB=${ESS_LIBS}/etherlab

#export ESS_OPCUA_LIB=${ESS_OPCUA}/lib
#export ESS_OPCUA_INC=${ESS_OPCUA}/include
#export ESS_OPCUA_BIN=${ESS_OPCUA}/bin


# export ESS_ETHERLAB_LIB=${ESS_ETHERLAB}/lib
# export ESS_ETHERLAB_BIN=${ESS_ETHERLAB}/bin
# export ESS_ETHERLAB_SBIN=${ESS_ETHERLAB}/sbin


# shared libs seach directory by require.c
#
# EPICS_DRIVER_PATH


EPICS_BASE=${DEFAULT_EPICS_BASE}
E3_REQUIRE_NAME=${DEFAULT_REQUIRE_NAME}
E3_REQUIRE_VERSION=${DEFAULT_REQUIRE_VERSION}

EPICS_HOST_ARCH=$("${EPICS_BASE}/startup/EpicsHostArch.pl")
E3_REQUIRE_LOCATION=${EPICS_BASE}/${E3_REQUIRE_NAME}/${E3_REQUIRE_VERSION}

E3_REQUIRE_BIN=${E3_REQUIRE_LOCATION}/bin
E3_REQUIRE_LIB=${E3_REQUIRE_LOCATION}/lib
E3_REQUIRE_INC=${E3_REQUIRE_LOCATION}/include
E3_REQUIRE_DB=${E3_REQUIRE_LOCATION}/db
E3_REQUIRE_DBD=${E3_REQUIRE_LOCATION}/dbd


E3_SITEMODS_PATH=${E3_REQUIRE_LOCATION}/siteMods
E3_SITELIBS_PATH=${E3_REQUIRE_LOCATION}/siteLibs
E3_SITEAPPS_PATH=${E3_REQUIRE_LOCATION}/siteApps


EPICS_DRIVER_PATH=${E3_SITEMODS_PATH}


export EPICS_BASE
export E3_REQUIRE_NAME
export E3_REQUIRE_VERSION

export EPICS_HOST_ARCH
export E3_REQUIRE_LOCATION

export E3_REQUIRE_BIN
export E3_REQUIRE_LIB
export E3_REQUIRE_INC
export E3_REQUIRE_DB
export E3_REQUIRE_DBD

export E3_SITEMODS_PATH
export E3_SITELIBS_PATH
export E3_SITEAPPS_PATH


export EPICS_DRIVER_PATH


export PATH=${E3_REQUIRE_BIN}:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/sbin:${HOME}/bin

export LD_LIBRARY_PATH=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}:${E3_REQUIRE_LIB}/${EPICS_HOST_ARCH}:/usr/local/lib:${E3_SITE_LIBS}


printf "\nSet the ESS EPICS Environment as follows:\n";
printf "THIS Source         : %s\n" "${THIS_SRC}"
printf "EPICS_BASE          : %s\n" "${EPICS_BASE}"
printf "EPICS_HOST_ARCH     : %s\n" "${EPICS_HOST_ARCH}"
printf "E3_REQUIRE_LOCATION : %s\n" "${E3_REQUIRE_LOCATION}"
printf "\n";
printf "Enjoy E3!\n";


