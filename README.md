# e3-require


## Setup

```
e3-require (master)$ make init
e3-require (master)$ make vars
e3-require (master)$ make build
e3-require (master)$ make install
```

## Update shell environment
```
e3-require (master)$ make requireconf
```

## Execute iocsh.bash


```
 e3-require (master)$ source tools/setE3Env.bash 

Set the ESS EPICS Environment as follows:
THIS Source NAME    : setE3Env.bash
THIS Source PATH    : /home/jhlee/e3/e3-require/tools
EPICS_BASE          : /epics/base-3.15.5
EPICS_HOST_ARCH     : linux-x86_64
E3_REQUIRE_LOCATION : /epics/base-3.15.5/require/3.0.0
PATH                : /epics/base-3.15.5/require/3.0.0/bin:/epics/base-3.15.5/bin/linux-x86_64:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/jhlee/bin
LD_LIBRARY_PATH     : /epics/base-3.15.5/lib/linux-x86_64:/epics/base-3.15.5/require/3.0.0/lib/linux-x86_64:/epics/base-3.15.5/require/3.0.0/siteLibs/linux-x86_64

Enjoy E3!

jhlee@faiserver: e3-require (master)$ iocsh.bash 
#
# Start at "2018-W35-Aug28-0012-23-CEST"
#
# Version information:
# European Spallation Source ERIC : iocsh.bash (v0.3.1-6690f8a.PID-9225)
#
# --->--> snip -->--> 
# Please Use Version and other environment variables
# in order to report or debug this shell
#
# HOSTDISPLAY=""
# WINDOWID="54535878"
# PWD="/home/jhlee/e3/e3-require"
# USER="jhlee"
# LOGNAME="jhlee"
# EPICS_HOST_ARCH="linux-x86_64"
# EPICS_BASE="/epics/base-3.15.5"
# E3_REQUIRE_NAME="require"
# E3_REQUIRE_VERSION="3.0.0"
# E3_REQUIRE_LOCATION="/epics/base-3.15.5/require/3.0.0"
# E3_REQUIRE_BIN="/epics/base-3.15.5/require/3.0.0/bin"
# E3_REQUIRE_DB="/epics/base-3.15.5/require/3.0.0/db"
# E3_REQUIRE_DBD="/epics/base-3.15.5/require/3.0.0/dbd"
# E3_REQUIRE_INC="/epics/base-3.15.5/require/3.0.0/include"
# E3_REQUIRE_LIB="/epics/base-3.15.5/require/3.0.0/lib"
# E3_SITEAPPS_PATH="/epics/base-3.15.5/require/3.0.0/siteApps"
# E3_SITELIBS_PATH="/epics/base-3.15.5/require/3.0.0/siteLibs"
# E3_SITEMODS_PATH="/epics/base-3.15.5/require/3.0.0/siteMods"
# EPICS_DRIVER_PATH="/epics/base-3.15.5/require/3.0.0/siteMods"
# EPICS_CA_AUTO_ADDR_LIST="no"
# EPICS_CA_ADDR_LIST="10.0.6.172 10.0.6.60"
# PATH="/epics/base-3.15.5/require/3.0.0/bin:/epics/base-3.15.5/bin/linux-x86_64:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/jhlee/bin"
# LD_LIBRARY_PATH="/epics/base-3.15.5/lib/linux-x86_64:/epics/base-3.15.5/require/3.0.0/lib/linux-x86_64:/epics/base-3.15.5/require/3.0.0/siteLibs/linux-x86_64"
# --->--> snip -->--> 
#
# Set REQUIRE_IOC for its internal PVs
epicsEnvSet REQUIRE_IOC "E3R:FAISERVER"
#
# Set E3_IOCSH_TOP for the absolute path where iocsh.bash is executed.
epicsEnvSet E3_IOCSH_TOP "/home/jhlee/e3/e3-require"
#
# 
# Load require module, which has the version 3.0.0
# 
dlload /epics/base-3.15.5/require/3.0.0/lib/linux-x86_64/librequire.so
dbLoadDatabase /epics/base-3.15.5/require/3.0.0/dbd/require.dbd
require_registerRecordDeviceDriver
Loading module info records for require
# 
# Set the IOC Prompt String One 
epicsEnvSet IOCSH_PS1 "6690f8a.faiserver.9240 > "
#
# 
iocInit
Starting iocInit
############################################################################
## EPICS R3.15.5-E3-3.15.5-patch
## EPICS Base built Aug 27 2018
############################################################################
iocRun: All initialization complete
6690f8a.faiserver.9240 > 



```


## TODO
