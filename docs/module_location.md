


driver.makefile OPTIONS (M_OPTINS)

EPICS_MODULES
* requrie : $(BASE_INSTALL_LOCATION)
/testing/epics/base-3.15.5/


```
/testing/epics/base-3.15.5# tree -L 1
.
├── bin
├── configure
├── db
├── dbd
├── html
├── include
├── lib
├── require
├── startup
└── templates
```

* siteMods :
$(REQUIRE_PATH)/siteMods

/testing/epics/base-3.15.5/require/2.5.4/siteMods

* siteApps
$(REQUIRE_PATH)/siteApps
/testing/epics/base-3.15.5/require/2.5.4/siteApps

* siteLibs :
$(REQUIRE_PATH)/siteLibs
/testing/epics/base-3.15.5/require/2.5.4/siteLibs

* siteSthEls:
$(REQUIRE_PATH)/siteSthEls
/testing/epics/base-3.15.5/require/2.5.4/siteSthEls




Tuesday, December  5 15:50:42 CET 2017, jhlee

driver.makefile

1) Remove base_VERSION directory below modules 

  uninstall.%:
	$(RMDIR) $(wildcard ${MODULE_LOCATION}/R*${@:uninstall.%=%}*)

2 ) Change
From
${MODULE_LOCATION}/R${EPICSVERSION}/lib/${T_A}

To

${MODULE_LOCATION}/lib/${T_A}




