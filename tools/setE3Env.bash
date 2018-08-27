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
#   date    : Tuesday, August 28 00:03:07 CEST 2018
#
#   version : 0.6.0


# the following function drop_from_path was copied from
# the ROOT build system in ${ROOTSYS}/bin/, and modified
# a little to return its result
# Wednesday, July 11 23:19:00 CEST 2018, jhlee 
function drop_from_path
{
    #
    # Assert that we got enough arguments
    if test $# -ne 2 ; then
	echo "drop_from_path: needs 2 arguments"
	return 1
    fi

    local p=$1
    local drop=$2

    local new_path=`echo $p | sed -e "s;:${drop}:;:;g" \
                 -e "s;:${drop};;g"   \
                 -e "s;${drop}:;;g"   \
                 -e "s;${drop};;g";`
    echo ${new_path}
}


function set_variable
{
    if test $# -ne 2 ; then
	echo "set_variable: needs 2 arguments"
	return 1
    fi

    local old_path="$1"
    local add_path="$2"

    local new_path=""
    local system_old_path=""

    if [ -z "$old_path" ]; then
	new_path=${add_path}
    else
	system_old_path=$(drop_from_path ${old_path} ${add_path})
	if [ -z "$system_old_path" ]; then
	    new_path=${add_path}
	else
	    new_path=${add_path}:${system_old_path}
	fi
   
    fi

    echo "${new_path}"
    
}



# Reset all EPICS, E3, and EEE related PRE-EXIST VARIABLES
# Remove them from PATH and LD_LIBRARY_PATH
# 
# If EPICS_BASE is defined,
# 1) Remove EPICS_BASE bin in the system PATH
# 2) Remove EPICS_BASE lib in the system LD_LIBRARY_PATH
# 3) Unset EPICS_BASE, EPICS_HOST_ARCH, and so on
if [ -n "$EPICS_BASE" ]; then
    
    system_path=${PATH}
    drop_base_path="${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"
    
    PATH=$(drop_from_path "${system_path}" "${drop_base_path}")
    export PATH
    
    system_ld_path=${LD_LIBRARY_PATH}
    drop_ld_path="${EPICS_BASE}/lib/${EPICS_HOST_ARCH}"
    
    LD_LIBRARY_PATH=$(drop_from_path "${system_ld_path}" "${drop_ld_path}")
    export LD_LIBRARY_PATH
    
    # If EPICS_ENTENSIONS, it is epics_builder
    if [ -n "$EPICS_EXTENSIONS" ]; then
	ext_path=${PATH}
	drop_ext_path="${EPICS_EXTENSIONS}/bin/${EPICS_HOST_ARCH}"
	
	PATH=$(drop_from_path "${ext_path}" "${drop_ext_path}")
	export PATH
	
	unset EPICS_EXTENSIONS
	unset EPICS_PATH
	unset EPICS_MODULES
	unset EPICS_EXTENSIONS
	unset EPICS_AREADETECTOR
	unset EPICS_APPS
    fi

    # If E3_REQUIRE_NAME, it is E3
    if [ -n "$E3_REQUIRE_NAME" ]; then

	e3_path=${PATH}
	
	PATH=$(drop_from_path "${e3_path}" "${E3_REQUIRE_BIN}")
	export PATH
	
	e3_ld_path=${LD_LIBRARY_PATH}
	drop_e3_ld_path1="${E3_REQUIRE_LIB}/${EPICS_HOST_ARCH}"
	drop_e3_ld_path2="${E3_SITELIBS_PATH}/${EPICS_HOST_ARCH}"
	e3_ld_path_0=$(drop_from_path "${e3_ld_path}" "${drop_e3_ld_path1}")
	
	LD_LIBRARY_PATH=$(drop_from_path "${e3_ld_path_0}" "${drop_e3_ld_path2}")
	export LD_LIBRARY_PATH
	
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
	unset SCRIPT_DIR
	
    fi
    
    # If EPICS_ENV_PATH, it is EEE
    if [ -n "$EPICS_ENV_PATH" ]; then

	eee_path=${PATH}
	PATH=$(drop_from_path "${eee_path}" "${EPICS_ENV_PATH}")
	export PATH

	eee_pvaccess_path=${PATH}
	drop_eee_pvaccess_path="${EPICS_MODULES_PATH}/pvAccessCPP/5.0.0/${BASE}/bin/${EPICS_HOST_ARCH}"
	
	PATH=$(drop_from_path "${eee_pvaccess_path}" "${drop_eee_pvaccess_path}")
	export PATH
	
	unset EPICS_BASES_PATH
	unset EPICS_MODULES_PATH
	unset BASE
	unset EPICS_ENV_PATH
	unset PYTHONPATH
    fi
    
    unset EPICS_BASE
    unset EPICS_HOST_ARCH
    
fi







THIS_SRC=${BASH_SOURCE[0]}
SRC_PATH="$( cd -P "$( dirname "$THIS_SRC" )" && pwd )"
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


old_path=${PATH}
E3_PATH="${E3_REQUIRE_BIN}:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"

PATH=$(set_variable "${old_path}" "${E3_PATH}")

# # We have a problem, if we have the multiple versions of one module, we have the same executable file names.
# # "echo" selects the lower version number by default. And if the version is used with a string,
# # we don't rely upon echo result.
# # Rethink how we handle each binary files within a module
# # 
# E3_SITELIBS_BINS=`echo ${E3_SITELIBS_PATH}/*_bin`;

# for each_bins in ${E3_SITELIBS_BINS}; do
#     PATH="${PATH}:$each_bins/${EPICS_HOST_ARCH}"
# #    echo $each_bins
# done

export PATH

old_ld_path=${LD_LIBRARY_PATH}
E3_LD_LIBRARY_PATH="${EPICS_BASE}/lib/${EPICS_HOST_ARCH}:${E3_REQUIRE_LIB}/${EPICS_HOST_ARCH}:${E3_SITELIBS_PATH}/${EPICS_HOST_ARCH}"

LD_LIBRARY_PATH=$(set_variable "${old_ld_path}" "${E3_LD_LIBRARY_PATH}")
export LD_LIBRARY_PATH

printf "\nSet the ESS EPICS Environment as follows:\n";
printf "THIS Source NAME    : %s\n" "${SRC_NAME}"
printf "THIS Source PATH    : %s\n" "${SRC_PATH}"
printf "EPICS_BASE          : %s\n" "${EPICS_BASE}"
printf "EPICS_HOST_ARCH     : %s\n" "${EPICS_HOST_ARCH}"
printf "E3_REQUIRE_LOCATION : %s\n" "${E3_REQUIRE_LOCATION}"
printf "PATH                : %s\n" "${PATH}"
printf "LD_LIBRARY_PATH     : %s\n" "${LD_LIBRARY_PATH}"
printf "\n";
printf "Enjoy E3!\n";


