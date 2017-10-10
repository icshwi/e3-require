# e3-require

This repository works with the following dependent repositories as well. And ESS will use the same environment of PSI, where is the inventor of the dynamic loading EPICS environment. It doesn't cover all requirements which any accelerator or EPICS users want to do, but it has covered the PSI requirements, and it is covering the ESS requirements. Since the current ESS EPICS environment doesn't sync with PSI one, this approach may guide ESS to keep the synchronization, and to minimize any further maintenance issues.

## Rules
* ESS DOES NOT touch or modify any original source from EPICS community developer. If needed, ESS forks their repository into github, and does some patches. And ESS will use the patches one as the repository address before merging the patches to the original repository. This workflow reduces ESS resources in many forms.
* ESS SHOULD NOT develop its own dynamic loading EPICS environment.

## Goals

*Building Environment SHOULD*
* Be transparent to any Linux flavors, then any users can enjoy this environment if they want to. At least, Debian and CentOS MUST be supported. 
* Minimize to use additional scripts, i.e., Python, which made some troubles on early environment building system.
* Use the restricted and manual version control to resolve many troubles in terms of modules version dependency
* Use the one global environmental variables to allow us to track which systems are installed
* Use the transparent EPICS environment in order to switch version between require versions, and to enable or disable the E3 environment
* Provide a way to setup the Generic EPICS BASE environment also. 

## Dependent Repositories

* e3-base https://github.com/icshwi/e3-base 
* e3-env  https://github.com/icshwi/e3-env

## Setup

* Load all git submodules

```
$ make init
```

* Print pre-defined environments. Note that this should be synced with e3-base one. 
```
$ make env
```
If it is not the same as e3-base one, please modify e3-env/e3-env file according to e3-base one.
One can check it again.

```
$ make env
```

* Build e3-require
```
$ make build
```

* Install e3-require
```
make install
```

## Execute iocsh
Once one installs e3-require, one can execute the simple iocsh for testing. 


```
e3-require (master)$ . e3-env/setE3Env.bash
e3-require (master)$ iocsh.bash 
#
# Start at "2017-W41-Oct10-1604-57-CEST"
#
# Version information:
# European Spallation Source ERIC : iocsh.bash (v0.2-fd4e0b5.PID-10102)
#
# HOSTDISPLAY="kaffee:0"
# WINDOWID="54525967"
# PWD="/home/jhlee/gitsrc/e3-require"
# USER="jhlee"
# LOGNAME="jhlee"
# EPICS_HOST_ARCH="linux-x86_64"
# EPICS_BASE="/e3/bases/base-3.15.5"
# EPICS_LOCATION="/e3/bases"
# EPICS="/e3/bases"
# EPICS_MODULES="/e3/modules"
# REQUIRE="require"
# REQUIRE_VERSION="2.5.3"
# REQUIRE_BIN="/e3/modules/require/2.5.3/bin"
# REQUIRE_LIB="/e3/modules/require/2.5.3/R3.15.5/lib"
# REQUIRE_DBD="/e3/modules/require/2.5.3/R3.15.5/dbd"
# EPICS_CA_AUTO_ADDR_LIST="yes"
# EPICS_CA_ADDR_LIST="194.47.240.7 10.0.2.15 10.4.8.11 10.4.8.12 10.4.8.13 10.4.8.14"
# PATH="/e3/modules/require/2.5.3/bin:/e3/bases/base-3.15.5/bin/linux-x86_64:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
# LD_LIBRARY_PATH="/e3/bases/base-3.15.5/lib/linux-x86_64:/e3/modules/require/2.5.3/R3.15.5/lib/linux-x86_64"
#
# Please Use Version and other environment variables
# in order to report or debug this shell
#
dlload /e3/modules/require/2.5.3/R3.15.5/lib/linux-x86_64/librequire.so
dbLoadDatabase /e3/modules/require/2.5.3/R3.15.5/dbd/require.dbd
require_registerRecordDeviceDriver
Loading module info records for require
iocInit
Starting iocInit
############################################################################
## EPICS R3.15.5-EEE-3.15.5
## EPICS Base built Oct 10 2017
############################################################################
iocRun: All initialization complete
epicsEnvSet IOCSH_PS1 "fd4e0b5.kaffee.10115 > "
fd4e0b5.kaffee.10115 >
```

Switch the difference EPICS base, i.e., 3.15.4

```
e3-require (master)$ . e3-env/setE3Env.bash 3.15.4
e3-require (master)$ iocsh.bash 
#
# Start at "2017-W41-Oct10-1606-06-CEST"
#
# Version information:
# European Spallation Source ERIC : iocsh.bash (v0.2-fd4e0b5.PID-11400)
#
# HOSTDISPLAY="kaffee:0"
# WINDOWID="54525967"
# PWD="/home/jhlee/gitsrc/e3-require"
# USER="jhlee"
# LOGNAME="jhlee"
# EPICS_HOST_ARCH="linux-x86_64"
# EPICS_BASE="/e3/bases/base-3.15.4"
# EPICS_LOCATION="/e3/bases"
# EPICS="/e3/bases"
# EPICS_MODULES="/e3/modules"
# REQUIRE="require"
# REQUIRE_VERSION="2.5.3"
# REQUIRE_BIN="/e3/modules/require/2.5.3/bin"
# REQUIRE_LIB="/e3/modules/require/2.5.3/R3.15.4/lib"
# REQUIRE_DBD="/e3/modules/require/2.5.3/R3.15.4/dbd"
# EPICS_CA_AUTO_ADDR_LIST="yes"
# EPICS_CA_ADDR_LIST="194.47.240.7 10.0.2.15 10.4.8.11 10.4.8.12 10.4.8.13 10.4.8.14"
# PATH="/e3/modules/require/2.5.3/bin:/e3/bases/base-3.15.4/bin/linux-x86_64:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
# LD_LIBRARY_PATH="/e3/bases/base-3.15.4/lib/linux-x86_64:/e3/modules/require/2.5.3/R3.15.4/lib/linux-x86_64"
#
# Please Use Version and other environment variables
# in order to report or debug this shell
#
dlload /e3/modules/require/2.5.3/R3.15.4/lib/linux-x86_64/librequire.so
dbLoadDatabase /e3/modules/require/2.5.3/R3.15.4/dbd/require.dbd
require_registerRecordDeviceDriver
Loading module info records for require
iocInit
Starting iocInit
############################################################################
## EPICS R3.15.4-EEE-3.15.4 $$Date$$
## EPICS Base built Oct 10 2017
############################################################################
iocRun: All initialization complete
epicsEnvSet IOCSH_PS1 "fd4e0b5.kaffee.11413 > "
fd4e0b5.kaffee.11413 >
```

## TODO

