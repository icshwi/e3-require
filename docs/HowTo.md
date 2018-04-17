#

Edit configure/RELEASE file in order to use *ONLY* one epics base

```
EPICS_BASE=/testing/epics/base-3.15.5
```

VARIABLES are printed via

```

jhlee@kaffee: e3-require (target_path_test)$ make vars

------------------------------------------------------------
>>>>     Current EPICS and E3 Envrionment Variables     <<<<
------------------------------------------------------------

E3_MODULES_PATH = /testing/epics/base-3.15.5
E3_MODULE_MAKEFILE = require.Makefile
E3_MODULE_MAKE_CMDS = make -C require-ess -f require.Makefile LIBVERSION="2.5.4" PROJECT="require" EPICS_MODULES="/testing/epics/base-3.15.5" EPICS_LOCATION="/testing/epics/base-3.15.5" BUILDCLASSES="Linux"
E3_MODULE_NAME = require
E3_MODULE_SRC_PATH = require-ess
E3_MODULE_SRC_PATH_INFO = 0
E3_MODULE_VERSION = 2.5.4
E3_REQUIRE_BIN = /testing/epics/base-3.15.5/require/2.5.4/bin
E3_REQUIRE_DB = /testing/epics/base-3.15.5/require/2.5.4/db
E3_REQUIRE_INC = /testing/epics/base-3.15.5/require/2.5.4/include
E3_REQUIRE_LIB = /testing/epics/base-3.15.5/require/2.5.4/lib
E3_REQUIRE_LOCATION = /testing/epics/base-3.15.5/require/2.5.4
E3_REQUIRE_NAME = require
E3_REQUIRE_TOOLS = /testing/epics/base-3.15.5/require/2.5.4/tools
E3_REQUIRE_VERSION = 2.5.4
EPICS_BASE = /testing/epics/base-3.15.5
EPICS_MODULE_NAME = require
EPICS_MODULE_TAG = tags/v2.5.4
SUDO = sudo
SUDOBASH = sudo -E bash -c
SUDO_INFO = 1
```


```
make init
make rebuild
```


Sometimes, configure/CONFIG_MODULE should be edited according to what we want to do..

```
EPICS_MODULE_NAME:=require
EPICS_MODULE_TAG:=target_path_test

E3_MODULE_SRC_PATH:=$(EPICS_MODULE_NAME)-ess
E3_MODULE_MAKEFILE:=$(EPICS_MODULE_NAME).Makefile

E3_MODULE_NAME:=$(EPICS_MODULE_NAME)
E3_MODULE_VERSION:=9.9.9
```

```
make checkout
make rebuild
```


```
jhlee@kaffee: e3-require (target_path_test)$ tree -L 2 /testing/epics/
/testing/epics/
├── [root     4.0K]  base-3.15.5
│   ├── [root     4.0K]  bin
│   ├── [root     4.0K]  configure
│   ├── [root     4.0K]  db
│   ├── [root     4.0K]  dbd
│   ├── [root     4.0K]  html
│   ├── [root      12K]  include
│   ├── [root     4.0K]  lib
│   ├── [root     4.0K]  require
│   ├── [root     4.0K]  startup
│   └── [root     4.0K]  templates
└── [root     4.0K]  base-3.16.1
    ├── [root     4.0K]  bin
    ├── [root     4.0K]  configure
    ├── [root     4.0K]  db
    ├── [root     4.0K]  dbd
    ├── [root     4.0K]  html
    ├── [root      12K]  include
    ├── [root     4.0K]  lib
    ├── [root     4.0K]  require
    ├── [root     4.0K]  startup
    └── [root     4.0K]  templates
	```
	


```
jhlee@kaffee: e3-require (target_path_test)$ tree -L 2 /testing/epics/base-3.16.1/require/
/testing/epics/base-3.16.1/require/
├── [root     4.0K]  0.0.0
│   ├── [root     4.0K]  bin
│   ├── [root     4.0K]  db
│   ├── [root     4.0K]  dbd
│   ├── [root     4.0K]  include
│   ├── [root     4.0K]  lib
│   └── [root     4.0K]  tools
└── [root     4.0K]  9.9.9
    ├── [root     4.0K]  bin
    ├── [root     4.0K]  db
    ├── [root     4.0K]  dbd
    ├── [root     4.0K]  include
    ├── [root     4.0K]  lib
    └── [root     4.0K]  tools

14 directories, 0 files
```
