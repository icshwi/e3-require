# e3-require

This is the pilot project in order to build the reliable and easy-to-understand approach for ESS EPICS environment. The golden rule is to keep any other EPICS base, and modules sources intact. Still, ESS EPICS environment needs more resource to maintain the additional work load, however, we don't need to maintain different and synced (not well maintain) almost same repositories for entire EPICS community resouces.


## Dependency

* e3-base
* e3-env

## Setup

```
make init
make build
make install
```

## Execute iocsh

``
cd e3-env
. setE3env.bash
iocsh
```
