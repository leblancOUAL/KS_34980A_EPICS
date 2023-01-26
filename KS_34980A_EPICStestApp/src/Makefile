TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build the IOC application

PROD_IOC = KS_34980A_EPICStest
# KS_34980A_EPICStest.dbd will be created and installed
DBD += KS_34980A_EPICStest.dbd

# KS_34980A_EPICStest.dbd will be made up from these files:
KS_34980A_EPICStest_DBD += base.dbd

# Include dbd files from all support applications:
#KS_34980A_EPICStest_DBD += xxx.dbd

# Add all the support libraries needed by this IOC
#KS_34980A_EPICStest_LIBS += xxx

# KS_34980A_EPICStest_registerRecordDeviceDriver.cpp derives from KS_34980A_EPICStest.dbd
KS_34980A_EPICStest_SRCS += KS_34980A_EPICStest_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
KS_34980A_EPICStest_SRCS_DEFAULT += KS_34980A_EPICStestMain.cpp
KS_34980A_EPICStest_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#KS_34980A_EPICStest_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
KS_34980A_EPICStest_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
