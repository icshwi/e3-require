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
* Once one installs e3-require, one can execute the simple iocsh for testing. 


```
e3-require (master)$ . e3-env/setE3Env.bash
e3-require (master)$ iocsh.bash 
#
#
# Start at "2017-W49-Dec04-1805-28-CET"
#
# Version information:
# European Spallation Source ERIC : iocsh.bash (v0.2-0d11bf5.PID-13637)
#
# HOSTDISPLAY="kaffee:0"
# WINDOWID="157286415"
# PWD="/home/jhlee/e3/e3-require"
# USER="jhlee"
# LOGNAME="jhlee"
# EPICS_HOST_ARCH="linux-x86_64"
# EPICS_BASE="/epics/bases/base-3.15.5"
# EPICS_LOCATION="/epics/bases"
# EPICS="/epics/bases"
# EPICS_MODULES="/epics/modules"
# REQUIRE="require"
# REQUIRE_VERSION="2.5.4"
# REQUIRE_BIN="/epics/modules/require/2.5.4/bin"
# REQUIRE_LIB="/epics/modules/require/2.5.4/R3.15.5/lib"
# REQUIRE_DBD="/epics/modules/require/2.5.4/R3.15.5/dbd"
# EPICS_CA_AUTO_ADDR_LIST="yes"
# EPICS_CA_ADDR_LIST="194.47.240.7 10.0.2.15 10.4.8.11 10.4.8.12 10.4.8.13 10.4.8.14"
# PATH="/epics/modules/require/2.5.4/bin:/epics/bases/base-3.15.5/bin/linux-x86_64:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/sbin:/home/jhlee/bin:/opt/etherlab/bin:/opt/etherlab/sbin:/opt/ess/opcUa/bin"
# LD_LIBRARY_PATH="/epics/bases/base-3.15.5/lib/linux-x86_64:/epics/modules/require/2.5.4/R3.15.5/lib/linux-x86_64:/usr/local/lib:/home/jhlee/lib:/opt/etherlab/lib:/opt/ess/opcUa/lib"
#
# Please Use Version and other environment variables
# in order to report or debug this shell
#
# Loading the mandatory require module ... 
# 
dlload /epics/modules/require/2.5.4/R3.15.5/lib/linux-x86_64/librequire.so
dbLoadDatabase /epics/modules/require/2.5.4/R3.15.5/dbd/require.dbd
require_registerRecordDeviceDriver
Loading module info records for require
# 
# 
epicsEnvSet IOCSH_PS1 "0d11bf5.kaffee.13650 > "
epicsEnvShow T_A
T_A is not an environment variable.
epicsEnvShow EPICS_HOST_ARCH
EPICS_HOST_ARCH=linux-x86_64
var requireDebug 1
0d11bf5.kaffee.13650 > 

```

* By default, iocInit is removed. Thus, one should call iocInit in their startup script files.

```
0d11bf5.kaffee.13650 > iocInit
Starting iocInit
############################################################################
## EPICS R3.15.5-EEE-3.15.5-patch
## EPICS Base built Nov 28 2017
############################################################################
require: fillModuleListRecord
require: (null):MODULES[0] = "require"
require: (null):VERSIONS[0] = "2.5.4"
require: (null):MOD_VER+="require 2.5.4"

iocRun: All initialization complete
```

## TODO

## Useful commands

In case that one would like to push individual files in require-ess, disenable ignore in submodule require-ess, and carefully following the steps:

```
e3-require (target_path_test)$  cd require-ess/

require-ess ((v2.5.4))$ git st

HEAD detached at 34c293d
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   App/tools/driver.makefile

require-ess ((v2.5.4))$ git diff App/tools/driver.makefile

require-ess ((v2.5.4))$ git add App/tools/driver.makefile

require-ess ((v2.5.4))$ git commit -m "remove R_base_VERSION in module path"
[detached HEAD d7cf410] remove R_base_VERSION in module path
1 file changed, 17 insertions(+), 15 deletions(-)

require-ess ((d7cf410...))$ git push origin HEAD:master
Counting objects: 5, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 668 bytes | 0 bytes/s, done.
Total 5 (delta 2), reused 0 (delta 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To https://github.com/icshwi/require-ess
   34c293d..d7cf410  HEAD -> master
jhlee@kaffee: require-ess ((d7cf410...))$ git st
HEAD detached from 34c293d
```
Assume that individual files were changed before doing that.

