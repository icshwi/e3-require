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

# Default, use the default EPICS_BASE in env setup script
# echo ${EPICS_BASE}
# What about EPICS_BASE exists, however, require doesn't compile with that base...?


if [[ $(checkIfDir ${EPICS_BASE}) -eq "$NON_EXIST" ]]; then

    printf "${EPICS_BASE} is defined to use. \n";
    printf "HOWEVER, ${SC_SCRIPTNAME} cannot find the real directory at EPICS_BASE at ${EPICS_BASE}\n";
    printf "Please check your environment!\n";
    exit;
fi

declare -g RUNNING_EPICS_BASE_VER=${EPICS_BASE##*/*-}
declare -g RUNNING_REQUIRE_PATH=${EPICS_MODULES}/${REQUIRE}/${REQUIRE_VERSION}/R${RUNNING_EPICS_BASE_VER}

declare -g SOFTIOC_CMD="softIoc"
declare -g SOFTIOC_ARGS="-D ${EPICS_BASE}/dbd/softIoc.dbd"

STARTUP=/tmp/${SC_SCRIPTNAME}_${IOC}_startup.$BASHPID

trap "softIoc_end" EXIT SIGTERM

{
    echo "# date=\"$(date)\""
    echo "# user=\"${USER:-$(whoami)}\""
    
    for var in PWD EPICS_HOST_ARCH  REQUIRE_PATH EPICS_CA_ADDR_LIST
    do
	echo "# $var=\"${!var}\""
    done


    LIBPREFIX=lib
    LIBPOSTFIX=.so

    REQUIRE_LIB=${RUNNING_REQUIRE_PATH}/lib/${EPICS_HOST_ARCH}/${LIBPREFIX}${REQUIRE}${LIBPOSTFIX}
    REQUIRE_DBD=${REQUIRE_LIB%/lib/*}/dbd/${REQUIRE}.dbd

    LDCMD="dlload"

    echo "$LDCMD $REQUIRE_LIB"
    echo "dbLoadDatabase $REQUIRE_DBD"
    echo "${REQUIRE%-*}_registerRecordDeviceDriver"

    loadFiles "$@"

    if [ "$init" != NO ]
    then
	echo "iocInit"
    fi

    
} > ${STARTUP}


    
command='${SOFTIOC_CMD} ${SOFTIOC_ARGS} "${STARTUP}"'
ulimit -c unlimited
eval "${command}" 2>&1

