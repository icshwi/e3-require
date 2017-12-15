#  Copyright (c) 2016 - Present  Jeong Han Lee
#  Copyright (c) 2016            European Spallation Source ERIC
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
#   date    : Monday, December  4 13:25:21 CET 2017
#
#   version : 0.0.2


unset ESS_ETHERLAB_LIB
unset ESS_ETHERLAB_BIN
unset ESS_ETHERLAB_SBIN


unset ESS_LIBS

unset ESS_OPCUA
unset ESS_OPCUA_LIB
unset ESS_OPCUA_BIN
unset ESS_OPCUA_INC

unset EPICS_DRIVER_PATH
unset EPICS_BASE
unset EPICS_HOST_ARCH

unset E3_REQUIRE
unset E3_REQUIRE_VERSION
unset E3_REQUIRE_LOCATION
unset E3_REQUIRE_BIN
unset E3_REQUIRE_LIB
unset E3_REQUIRE_DBD

unset PATH
unset LD_LIBRARY_PATH



base_ver=$1
require_ver=$2

if [ -z "$require_ver" ]; then
    require_ver="0.0.1"
fi

if [ -z "$base_ver" ]; then
    base_ver="3.15.5"
fi



export EPICS_BASE=/testing/epics/base-3.15.5


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
#export EPICS_DRIVER_PATH=${EPICS_MODULES}:${ESS_ETHERLAB_LIB}
#export EPICS_BASE=${EPICS}/base-${base_ver}



# export EPICS_LOCATION=${ESS_EPICS_PATH}/bases
# export EPICS_MODULES=${ESS_EPICS_PATH}/modules



EPICS_HOST_ARCH=$("${EPICS_BASE}/startup/EpicsHostArch.pl")
export EPICS_HOST_ARCH

# Select REQUIRE Environment Variables

export E3_REQUIRE=require
export E3_REQUIRE_VERSION=${require_ver}
export E3_REQUIRE_LOCATION=${EPICS_BASE}/${E3_REQUIRE}/${E3_REQUIRE_VERSION}

export E3_REQUIRE_BIN=${E3_REQUIRE_LOCATION}/bin
export E3_REQUIRE_LIB=${E3_REQUIRE_LOCATION}/lib
export E3_REQUIRE_DBD=${E3_REQUIRE_LOCATION}/dbd

export PATH=${E3_REQUIRE_BIN}:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/sbin:${HOME}/bin

export LD_LIBRARY_PATH=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}:${E3_REQUIRE_LIB}/${EPICS_HOST_ARCH}:/usr/local/lib:${HOME}/lib

