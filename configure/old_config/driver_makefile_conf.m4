dnl   Global ESS EPICS configration for driver.makefile
dnl   per $(REQUIRE)/$(REQIRE_VERSION)
dnl   
dnl   It is installed via make install
dnl
dnl   conf file is loaded in driver.makefile
dnl   to override the default environment in driver.makefile 

dnl $  m4  config_site.m4
dnl    CROSS_COMPILER_TARGET_ARCHS = 

dnl    CROSS_COMPILER_HOST_ARCHS = 
dnl    CROSS_COMPILER_RUNTEST_ARCHS = 
dnl    SHARED_LIBRARIES = YES
dnl    STATIC_BUILD = NO
dnl    HOST_OPT = YES
dnl    CROSS_OPT = YES
dnl    HOST_WARN = YES
dnl    CROSS_WARN = YES
dnl    #INSTALL_LOCATIOIN = 
dnl    USE_POSIX_THREAD_PRIORITY_SCHEDULING = YES
dnl    EPICS_SITE_VERSION =
dnl    GCC_PIPE = NO
dnl    LINKER_USE_RPATH = YES

dnl   Set the cross compiler target archs
dnl   $ m4  -D_CROSS_COMPILER_TARGET_ARCHS=linux-ppc64e6500 config_site.m4
dnl     CROSS_COMPILER_TARGET_ARCHS = linux-ppc64e6500
dnl
dnl
ifdef(`_DEFAULT_EPICS_VERSIONS',
	`DEFAULT_EPICS_VERSIONS = _DEFAULT_EPICS_VERSIONS',
	`DEFAULT_EPICS_VERSIONS = ')
	
ifdef(`_BUILDCLASSES',
	`BUILDCLASSES = _BUILDCLASSES',
	`BUILDCLASSES = ')
	
ifdef(`_EPICS_MODULES',
	`EPICS_MODULES = _EPICS_MODULES',
	`EPICS_MODULES = ')

ifdef(`_EPICS_LOCATION',
	`EPICS_LOCATION = _EPICS_LOCATION',
	`EPICS_LOCATION =')
