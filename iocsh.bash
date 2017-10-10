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

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -g  SC_VERSION="43be69b"
declare -g  STARTUP=""

# TODO
# when require install this script, at that moment, update this!
#
SC_VERSION="$(git rev-parse --short HEAD)"


set -a
. ${SC_TOP}/ess-env.conf
set +a

. ${SC_TOP}/iocsh_functions


check_mandatory_env_settings

STARTUP=/tmp/${SC_SCRIPTNAME}_${IOC}_startup.$BASHPID

trap "softIoc_end" EXIT SIGTERM

{
    printIocEnv;
    loadRequire ;
    loadFiles  "$@";

    if [ "$init" != NO ]; then
	printf "iocInit\n"
    fi
    
    
}  > ${STARTUP}

ulimit -c unlimited
# -x "PREFIX"
# PREFIX:exit & PREFIX:BaseVersion PVs are added to softIoc
# We can end this IOC via caput PREFIX:exit 1

softIoc -D ${EPICS_BASE}/dbd/softIoc.dbd   "${STARTUP}" 2>&1
