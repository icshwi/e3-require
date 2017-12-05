uninstall.%:
	$(RMDIR) $(wildcard ${MODULE_LOCATION}/R*${@:uninstall.%=%}*)


From
${MODULE_LOCATION}/R${EPICSVERSION}/lib/${T_A}

To

${MODULE_LOCATION}/lib/${T_A}
