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
jhlee@kaffee: e3-require (master)$ iocsh
Library /work/iocBoot/R3.15.4/linux-x86_64/libmisc.so not found.
Command 'require' is not available.
/e3/bases/base-3.15.4/bin/linux-x86_64/softIoc -D /e3/bases/base-3.15.4/dbd/softIoc.dbd /tmp/iocsh.startup.31197
# date="Fri Oct  6 14:30:32 CEST 2017"
# user="jhlee"
# PWD="/home/jhlee/gitsrc/e3-require"
# BASE="3.15.4"
# EPICS_HOST_ARCH="linux-x86_64"
# SHELLBOX=""
# EPICS_CA_ADDR_LIST="194.47.240.7 10.0.2.15 10.4.8.11 10.4.8.12 10.4.8.13 10.4.8.14"
# EPICS_DRIVER_PATH=".:bin/linux-x86_64:bin:snl:../snl:O.3.15.4_linux-x86_64:src/O.3.15.4_linux-x86_64:snl/O.3.15.4_linux-x86_64:../snl/O.3.15.4_linux-x86_64:/ioc/modules:/work/iocBoot/R3.15.4/linux-x86_64"
iocInit
Starting iocInit
############################################################################
## EPICS R3.15.4-EEE-3.15.4 $$Date$$
## EPICS Base built Oct  6 2017
############################################################################
cas warning: Configured TCP port was unavailable.
cas warning: Using dynamically assigned TCP port 37010,
cas warning: but now two or more servers share the same UDP port.
cas warning: Depending on your IP kernel this server may not be
cas warning: reachable with UDP unicast (a host's IP in EPICS_CA_ADDR_LIST)
iocRun: All initialization complete
epicsEnvSet IOCSH_PS1,"kaffee> "

jhlee@kaffee: e3-require (master)$ . e3-env/setE3Env.bash "3.15.5"
jhlee@kaffee: e3-require (master)$ iocsh

Library /work/iocBoot/R3.15.5/linux-x86_64/libmisc.so not found.
Command 'require' is not available.
/e3/bases/base-3.15.5/bin/linux-x86_64/softIoc -D /e3/bases/base-3.15.5/dbd/softIoc.dbd /tmp/iocsh.startup.31257
# date="Fri Oct  6 14:32:32 CEST 2017"
# user="jhlee"
# PWD="/home/jhlee/gitsrc/e3-require"
# BASE="3.15.5"
# EPICS_HOST_ARCH="linux-x86_64"
# SHELLBOX=""
# EPICS_CA_ADDR_LIST="194.47.240.7 10.0.2.15 10.4.8.11 10.4.8.12 10.4.8.13 10.4.8.14"
# EPICS_DRIVER_PATH=".:bin/linux-x86_64:bin:snl:../snl:O.3.15.5_linux-x86_64:src/O.3.15.5_linux-x86_64:snl/O.3.15.5_linux-x86_64:../snl/O.3.15.5_linux-x86_64:/ioc/modules:/work/iocBoot/R3.15.5/linux-x86_64"
iocInit
Starting iocInit
############################################################################
## EPICS R3.15.5-EEE-3.15.5
## EPICS Base built Oct  6 2017
############################################################################
cas warning: Configured TCP port was unavailable.
cas warning: Using dynamically assigned TCP port 42529,
cas warning: but now two or more servers share the same UDP port.
cas warning: Depending on your IP kernel this server may not be
cas warning: reachable with UDP unicast (a host's IP in EPICS_CA_ADDR_LIST)
iocRun: All initialization complete
epicsEnvSet IOCSH_PS1,"kaffee> "




```

## TODO

It is working version, so please don't expect the actual running ioc... since we miss the following library:

```
Library /work/iocBoot/R3.15.4/linux-x86_64/libmisc.so not found.
Command 'require' is not available.
```
