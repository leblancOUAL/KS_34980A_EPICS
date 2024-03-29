# Basic documentation for getting something working with StreamDevice

These are the notes that I've made on getting EPICS to talk to the control system 
at the Edwards Accelerator Lab at Ohio University.  These notes are rough, and
mostly intendedd for my own consumption.  Eventually I'll turn them into a disaster 
recovery document.

All of these instructions were tested on "CentOS Linux release 7.9.2009 (Core)" 
running on an older desktop PC with an Intel(R) Core(TM) i5-2500 CPU and 8 gigs
of ram.  

EPICS base was compiled using the instructions at 
https://docs.epics-controls.org/projects/how-tos/en/latest/index.html

I have the following in my .bashrc to support EPICS

```
export EPICS_BASE=${HOME}/EPICS/epics-base
export EPICS_HOST_ARCH=$(${EPICS_BASE}/startup/EpicsHostArch)
export PATH=${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:${PATH}
export SUPPORT=${HOME}/EPICS/support
export ASYN=${SUPPORT}/asyn
export CALC=${SUPPORT}/calc
export STREAM=${SUPPORT}/StreamDevice
export EPICS_CA_ADDR_LIST=127.0.0.1
```

## Building StreamDevice
EPICS StreamDevice home page is at: https://paulscherrerinstitute.github.io/StreamDevice/
The Github page is at: https://github.com/paulscherrerinstitute/StreamDevice

It also requires Asyn, calc.

NOT needed are at least: stream (obsolete), ipac (looks narrowly domain specific), SNCSEQ (again, 
narrowly domain specific), sscan (used for positioning).

Asyn github page is at: https://github.com/epics-modules/asyn
Calc github page is at: https://github.com/epics-modules/calc


First, create a SUPPORT directory.

```
mkdir ${HOME}/EPICS/support
cd ${HOME}/EPICS/support
```

### Calc
First, calc, because asyn depends on calc.

```
git clone https://github.com/epics-modules/calc.git
```

Create calc/configure/RELEASE.local and put in the following

```
SUPPORT=/home/leblanc/EPICS/support
SSCAN=
EPICS_BASE=/home/leblanc/EPICS/epics-base
```

Then run `make -j4` (pick a number, but leaving it off makes the build SLOW)

### Asyn
Now that we have calc, let's do asyn.

```
git clone https://github.com/epics-modules/asyn.git
```

Similarly, create a `asyn/configure/RELEASE.local` that contains:

```
SUPPORT=/home/leblanc/EPICS/support
CALC=$(SUPPORT)/calc
EPICS_BASE=/home/leblanc/EPICS/epics-base
```

Next, edit configure/CONFIG_SITE and uncomment the line `# TIRPC=YES`

Then run `make -j4` to get things built.

Hopefully no errors on either of these, so that we can go on to the next step.

### StreamDevice
Same bat story, new bat channel.

```
git clone https://github.com/paulscherrerinstitute/StreamDevice.git
```

Create `StreamDevice/configure/RELEASE.local` and fill it with:

```
SUPPORT=/home/leblanc/EPICS/support
ASYN=$(SUPPORT)/asyn
CALC=$(SUPPORT)/calc
PCRE=
EPICS_BASE=/home/leblanc/EPICS/epics-base
```

And next make a `StreamDevice/configure/RELEASE.Common.linux-x86_64` and populate it with:

```
PCRE_INCLUDE=/usr/include
PCRE_LIB=/usr/lib64
```
and run make -j4 to get things built.

Assuming everything went well, you should have a working stream device.

## Making an IOC

This instructions are going to be largely stolen from: 
https://epics.anl.gov/modules/soft/asyn/R4-23/HowToDoSerial/HowToDoSerial_StreamDevice.html and
https://github.com/fullerf/SRSPS365/wiki/InstallingViaTemplates
But those made me a little nervous, because they're for Epics 3.14.11, which is ancient (released 
in 2009).  Since 7.0 was release in 2017, I wasn't sure what, if anything, would actually work.  
Also, it seems like it makes sense to set things up as PVs instead of CAs, so I'm going to try to do that.

### Build the IOC

First, create a directory, and fill in the streamSCPI template.  I made a new directory called TEST under /home/leblanc/EPICS to store all of this mess.

```
mkdir KS_34980A_EPICS
cd KS_34980A_EPICS
$ASYN/bin/$EPICS_HOST_ARCH/makeSupport.pl -t streamSCPI KS_34980A_EPICS
```

Next the instructions tell you do "a bunch of stuff", and then "delete that stuff", and do "some more
stuff".  So we're going to skip to the "some more stuff" part.

```
rm -rf configure/
$EPICS_BASE/bin/$EPICS_HOST_ARCH/makeBaseApp.pl -t ioc KS_34980A_EPICStest
$EPICS_BASE/bin/$EPICS_HOST_ARCH/makeBaseApp.pl -t ioc -i KS_34980A_EPICStest
```

And it will display:

```
Using target architecture linux-x86_64 (only one available)
The following applications are available:
    KS_34980A_EPICStest
What application should the IOC(s) boot?
The default uses the IOC's name, even if not listed above.
Application name?
```

Then just push enter to accept the default application name.

Now create `configure/RELEASE.local` and populate it with:

```
SUPPORT=/home/leblanc/EPICS/support
ASYN=$(SUPPORT)/asyn
CALC=$(SUPPORT)/calc
STREAM=$(SUPPORT)/StreamDevice
EPICS_BASE=/home/leblanc/EPICS/epics-base
```

Now, edit `configure/CONFIG_SITE` to add a line that says

```
CROSS_COMPILER_TARGET_ARCHS =
```

I added it just below the existing commented out CROSS_COMPILER_TARGET_ARCHS line.

Next, edit `KS_34980A_EPICStestApp/src/Makefile` and just below the line that 
says `#KS_34980A_EPICStest_DBD += xxx.dbd` and add the following lines:

```
KS_34980A_EPICStest_DBD += calcSupport.dbd
KS_34980A_EPICStest_DBD += stream.dbd
KS_34980A_EPICStest_DBD += asyn.dbd
KS_34980A_EPICStest_DBD += drvAsynSerialPort.dbd 
KS_34980A_EPICStest_DBD += drvAsynIPPort.dbd
```

Now, just below the line that says `#KS_34980A_EPICStest_LIBS += xxx` and add the following line:

```
KS_34980A_EPICStest_LIBS += stream asyn calc
```

Type `make -j4` to build, and hopefully we're off tot the races!

### Create st.cmd

Next step is to make our st.cmd.  We added both serial and IP to the IOC, but the st.cmd will be 
set up for just IP communication.  Replace `iocBoot/iocKS_34980A_EPICStest/st.cmd` with the following:

```
#!../../bin/linux-x86_64/KS_34980A_EPICStest

############################################################################### 
# Set up environment 
< envPaths 
epicsEnvSet "STREAM_PROTOCOL_PATH" "$(TOP)/db" 

############################################################################### 
# Allow PV name prefixes and serial port name to be set from the environment 
epicsEnvSet "P" "$(P=KS_34980A_EPICS)" 
epicsEnvSet "R" "$(R=test)" 
epicsEnvSet "HOST" "$(HOST=10.0.0.105)"
epicsEnvSet "PORT" "$(PORT=5025)"

############################################################################### 
## Register all support components 
cd "${TOP}" 
dbLoadDatabase "dbd/KS_34980A_EPICStest.dbd" 
KS_34980A_EPICStest_registerRecordDeviceDriver pdbbase 

############################################################################### 
# Set up ASYN ports
drvAsynIPPortConfigure("LAN0","$(HOST):$(PORT)",0,0,0)
#1st argument is the port's name
#2nd argument is the "IP address: port num"
#3rd argument is priority; 0 means medium
#4th argument is noAutoConnect; 0 means yes, autoconnect
#5th argument is noProcessEOS; 0 something complicated, 1 also complicated

# Set output and input end of command terminators to be newlines.
asynOctetSetOutputEos("LAN0", 0, "\n")
asynOctetSetInputEos("LAN0", 0, "\n")
############################################################################### 

asynSetTraceIOMask("LAN0", 0, "ESCAPE")
asynSetTraceMask("LAN0", 0, "ERROR|DRIVER")

var streamError 1
var streamDebug 1
var streamDebugColored 1
var streamErrorDeadTime 30
var streamMsgTimeStamped 1
streamSetLogfile("logfile.txt")

############################################################################### 
## Load record instances 
dbLoadRecords("db/devKS_34980A_EPICS.db","P=$(P),R=$(R),PORT=LAN0,A=0") 

############################################################################### 
## Start EPICS 
cd "${TOP}/iocBoot/${IOC}" 
iocInit
```

Now make it excutable by running `chmod +x iocBoot/iocKS_34980A_EPICStest/st.cmd`. Next, change to 
`iocBoot/iocKS_34980A_EPICStest` amd run `./st.cmd`.  It only works from that directory, so don't try to run 
it from elsewhere with a longer path.
