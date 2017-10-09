#!/bin/bash

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -g  STARTUP=""


set -a
. ${SC_TOP}/ess-env.conf
set +a

. ${SC_TOP}/iocsh_functions


case $1 in
    ( -h | "-?" | -help | --help )
    help
    ;;
    ( -v | -ver | --ver | -version | --version )
    version
    ;;
    ( -3.* )
    unset EPICS_BASE;
    EPICS_BASE=$(select_epics_base "$1");
    shift
    ;;
esac

if [[ $(checkIfDir ${EPICS_BASE}) -eq "$NON_EXIST" ]]; then

    printf "EPICS_BASE is defined to use. \n";
    printf "Please check your environment!\n";
    exit;
fi

declare -g RUNNING_EPICS_BASE_VER=${EPICS_BASE##*/*-}
declare -g RUNNING_REQUIRE_PATH=${REQUIRE_PATH}/R${RUNNING_EPICS_BASE_VER}

STARTUP=/tmp/${SC_SCRIPTNAME}_${IOC}_startup.$BASHPID

declare -a ioc_env=(PWD EPICS_HOST_ARCH  REQUIRE_PATH EPICS_CA_ADDR_LIST);

trap "softIoc_end" EXIT SIGTERM

{
    printIocEnv "${ioc_env}"

    loadRequire 
    loadFiles   "$@"

    if [ "$init" != NO ]; then
	printf "iocInit\n"
    fi

    
}  > ${STARTUP}

ulimit -c unlimited
# -x "PREFIX"
# PREFIX:exit & PREFIX:BaseVersion PVs are added to softIoc
# We can end this IOC via caput PREFIX:exit 1

softIoc -D ${EPICS_BASE}/dbd/softIoc.dbd  -x "TEST" "${STARTUP}" 2>&1
