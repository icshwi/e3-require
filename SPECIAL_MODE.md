Special Modes for ESS EPICS Environment (e3)
===

The Special modes are optional. However it will give users to explore more posssibilities while running IOC in any circumstances. 

## Cell Mode

When a user faces the difficulty to work within entire work-flow in terms of the tighted-controlled deployment or within limited RW permissions. Sometimes, it is very difficult to compile and run any IOC appplication within the ESS EPICS environment. Thus, the Cell Mode is introduced. 

One should define `E3_CELL_PATH`, where one can has the RW permission. The default is `$(TOP)/cellMods` because the e3 has the assumption that one can download the e3-modules or e3-application within a writable path. This variable can be overried with `CONFIG_CELL.local` or `configure/CONFIG_CELL.local` as the same as other `CONFIG_MODULE` or `RELEASE` files. The different commands are shown in 
```
make cellinstall
make celluninstall
make cellvars
```
Once one install an application with the cell mode, one can run an IOC via
```
iocsh.bash -l ${E3_CELL_PATH}
```




## Real-Time Mode

The e3 will handle all modules and applications as a dynamic libraries, which we have to consider when all symbols are resolved. We put this time at startup moment. Although it can slow down any IOC initialization, it is only way to avoid non-deterministic latencies during IOC execution [1].

Here we set the `LD_BIND_NOW=1` before we are going into actually IOC application, and run a IOC application with a scheduler policy of FIFO and a prority of 1. One needs the proper permission to execute it `chrt`, mostly `realtime` group should be created and a user should be in that group. 

* Command
```
iocsh.bash -rt 
```

## References
[1] Original paragraph from Red Hat Enterprise Linux for Real Time 7 Tuning Guide. 2018-04-30 / CC BY-SA 3.0 https://creativecommons.org/licenses/by-sa/3.0/ 
