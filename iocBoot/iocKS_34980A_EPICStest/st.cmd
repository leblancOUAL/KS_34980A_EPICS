#!../../bin/linux-x86_64/KS_34980A_EPICStest

#- You may have to change KS_34980A_EPICStest to something else
#- everywhere it appears in this file

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/KS_34980A_EPICStest.dbd"
KS_34980A_EPICStest_registerRecordDeviceDriver pdbbase

## Load record instances
#dbLoadRecords("db/KS_34980A_EPICStest.db","user=leblanc")

cd "${TOP}/iocBoot/${IOC}"
iocInit

## Start any sequence programs
#seq sncxxx,"user=leblanc"
