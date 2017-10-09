#!/bin/bash


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"


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


if [[ $(checkIfDir ${EPICS_BASE}) -eq "$NON_EXIST" ]]; then

    printf "${EPICS_BASE} is defined to use. \n";
    printf "HOWEVER, ${SC_SCRIPTNAME} cannot find the real directory at EPICS_BASE at ${EPICS_BASE}\n";
    printf "Please check your environment!\n";
    exit;
fi


## Extract selected EPICS BASE version from the active
## environment 

declare -g RUNNING_EPICS_BASE_VER=${EPICS_BASE##*/*-}
declare -g RUNNING_REQUIRE_PATH=${EPICS_MODULES}/${REQUIRE}/${REQUIRE_VERSION}/R${RUNNING_EPICS_BASE_VER}

startup=/tmp/iocsh.startup.$$

# clean up and kill the softIoc when killed by any signal
trap "kill -s SIGTERM 0; stty sane; echo; rm -f $startup; " EXIT

{
    echo "# date=\"$(date)\""
    echo "# user=\"${USER:-$(whoami)}\""
    
    for var in PWD BASE EPICS_HOST_ARCH SHELLBOX EPICS_CA_ADDR_LIST EPICS_DRIVER_PATH
    do
	echo "# $var=\"${!var}\""
    done


    LIBPREFIX=lib
    LIBPOSTFIX=.so

    REQUIRE_LIB=${RUNNING_REQUIRE_PATH}/lib/$EPICS_HOST_ARCH/$LIBPREFIX$REQUIRE$LIBPOSTFIX
    REQUIRE_DBD=${REQUIRE_LIB%/lib/*}/dbd/$REQUIRE.dbd

    EXE=softIoc
    ARGS="-D $EPICS_BASE/dbd/softIoc.dbd"
    LDCMD="dlload"


#    echo "$LDCMD $REQUIRE_LIB"
#    echo "dbLoadDatabase $REQUIRE_DBD"
#    echo "${REQUIRE%-*}_registerRecordDeviceDriver"


#    loadFiles "$@"

    if [ "$init" != NO ]
    then
	echo "iocInit"
    fi
} > $startup

echo $EXE $ARGS $startup
ulimit -c unlimited
eval "$LOADER $LOADERARGS $EXE" $ARGS "$startup" 2>&1

