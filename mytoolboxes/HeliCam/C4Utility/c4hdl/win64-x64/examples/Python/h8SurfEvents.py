##
# \file        h8SurfEvents.py
# \author      Silvan Murer
# \date        13 Apr 2021
# \copyright   Heliotis, 2021
# \version     1.0.0
#
# \brief       Simple Python example based on C4Hdl library for heliInspect H8 register for camera events
import os
import sys
import platform
import numpy as np
import threading

if sys.version_info < (2, 7, 0):
    raise RuntimeError("Python 2.7 or later required")

if sys.platform == "win32":
    c4utilityRoot = os.environ['C4UTILITY_ROOT']
    libPath = c4utilityRoot + r'c4hdl'
    if (platform.architecture()[0] == "32bit"):
        libPath = libPath + r'\win32-i86'
    else:
        libPath = libPath + r'\win64-x64'
    if sys.version_info < (3, 0, 0):
        libPath = libPath + r'\py2.7\bin'
    else:
        libPath = libPath + r'\python\bin'
    sys.path.insert(0, libPath)
elif sys.platform == "linux":
    c4utilityRoot = os.environ['C4UTILITY_ROOT']
    libPath = c4utilityRoot + r'/c4hdl'
    if (platform.architecture()[0] == "32bit"):
        libPath = libPath + r'/linux32-i86'
    else:
        libPath = libPath + r'/linux64-x64'
    if sys.version_info < (3, 0, 0):
        libPath = libPath + r'/py2.7/bin'
    else:
        libPath = libPath + r'/python/bin'
    sys.path.insert(0, libPath)
else:
    # Only windows example is available
    raise RuntimeError('Not implemented now, only a windows example is available')

import C4HdlPY as c4hdl


##################################
# Event Thread
##################################
def event_thread(c4dev):
    global acqRun
    print("Event Thread started...")
    while(acqRun):
        try:
            ftrList = c4dev.waitForEvents(10000)
            for ftr in ftrList:
                print(ftr + ": (" + str(str(c4dev.getFeatureType(ftr))) + ") " + str(c4dev.readInteger(ftr)))
        except Exception as e:
            print("An exception occurred: " + str(e))
    print("Event Thread stopped...")


##################################
# Acquisition Thread
##################################
def acq_thread(c4dev):
    global acqRun
    print("Acquisition Thread started...")
    scanPos = c4dev.readFloat("ScanPosition")
    print("Ready for measurement. Measure on position: " + str(scanPos) + "mm")
    selection_str = input("y=yes else=exit: ")
    if (selection_str != "y"):
        c4dev.release()
        c4if.release()
        exit("User interrupt - exit")

    c4dev.startAcquisition(4)

    for i in range(0, 5):
        try:
            # trigger single measurement
            c4dev.writeString("TriggerSelector", "FrameStart")
            c4dev.executeCommand("TriggerSoftware")

            # acquire data
            c4buf = c4dev.getBuffer(10000)

            # just print some meta informations from the data
            numParts = c4buf.getNumParts()
            print("getNumParts: " + str(numParts))
            print("iteration " + str(i) + " done!\n")

            c4buf.release()
        except Exception as e:
            print(type(e))
            print("An exception occurred: " + str(e))

    c4dev.stopAcquisition()
    acqRun = False
    print("Acquisition Thread stopped...")


##
# Scan for available interfaces and print interface list
# let the user select one and open the interface
# \param c4sys system object of C4Hdl library
# \return interface object of C4Hdl library
def selectInterface(c4sys):
    nofIf = c4sys.updateInterfaceList()
    print(str(nofIf) + " interfaces detected\n")
    for i in range(0, nofIf):
        ifName = c4sys.getInterfaceName(i)
        print(str(i+1) + ") " + ifName)
    selection_str = input("Select an interface (0=exit): ")
    selection_int = int(selection_str)
    if((selection_int <= 0) or (selection_int > nofIf)):
        exit('No interface selected - exit script')
    return c4sys.openInterface(selection_int - 1)


##
# Scan for available devices and print device list
# let the user select one and open the connection to the device
# \param c4if interface object of C4Hdl library
# \return device object of C4Hdl library
def selectDevice(c4if):
    nofDev = c4if.updateDeviceList()
    print(str(nofDev) + " devices detected\n")
    for i in range(0, nofDev):
        devName = c4if.getDeviceName(i)
        print(str(i+1) + ") " + devName)
    selection_str = input("Select a device (0=exit): ")
    selection_int = int(selection_str)
    return c4if.openDevice(selection_int - 1)


##
# simple configuration example of heliInspect H8 using internal motion control
# \param c4dev device object of C4Hdl library
def initializeDevice(c4dev):
    # Motion parameters in [mm] or [mm/s]
    scanPosition = -1.4
    scanRange = 0.5
    scanSpeed = 5.0
    generalSpeed = 10.0
    # exposure ration between 0.0 and 1.0 [1.0 = 100% exposure]
    exposureRatio = 1.0

    # enable required components
    c4dev.writeString("ComponentSelector", "Intensity")
    c4dev.writeInteger("ComponentEnable", 0)
    c4dev.writeString("ComponentSelector", "Range")
    c4dev.writeInteger("ComponentEnable", 1)
    c4dev.writeString("ComponentSelector", "Reflectance")
    c4dev.writeInteger("ComponentEnable", 1)
    c4dev.writeString("ComponentSelector", "Phase")
    c4dev.writeInteger("ComponentEnable", 0)

    # enable required chunk data (optional)
    c4dev.writeInteger("ChunkModeActive", 1)
    c4dev.writeString("ChunkSelector", "PartCount")
    c4dev.writeInteger("ChunkEnable", 1)
    c4dev.writeString("ChunkSelector", "PartType")
    c4dev.writeInteger("ChunkEnable", 1)

    # trigger configuration
    c4dev.writeString("TriggerSelector", "RecordingStart")
    c4dev.writeString("TriggerMode", "On")
    c4dev.writeString("TriggerSource", "Stage")
    c4dev.writeString("TriggerSelector", "AcquisitionStart")
    c4dev.writeString("TriggerMode", "Off")
    c4dev.writeString("TriggerSelector", "FrameStart")
    c4dev.writeString("TriggerMode", "On")
    c4dev.writeString("TriggerSource", "Software")
    # Hint: The TriggerSource also controls the TriggerSoftware feature.

    # encoder configuration
    c4dev.writeString("EncoderSelector", "Camera")
    c4dev.writeInteger("EncoderInverter", 1)

    # motion and position configuration
    c4dev.writeFloat("ScanPosition", scanPosition)
    c4dev.writeFloat("ScanRange", scanRange)
    c4dev.writeFloat("ScanSpeed", scanSpeed)
    c4dev.writeFloat("GeneralSpeed", generalSpeed)

    c4dev.writeString("ScanMode", "Down")
    c4dev.executeCommand("StageInit")

    # additional camera and processing configuration
    c4dev.writeString("Scan3dExtractionMethod", "AcceleratedCenterOfMassIQCorrection")
    c4dev.writeString("Scan3dScalingMethod", "zTags")
    c4dev.writeString("Scan3dDistanceUnit", "um")

    c4dev.writeFloat("TargetVerticalSpacing", 2.5)
    c4dev.writeFloat("ExposureRatio", exposureRatio)

    c4dev.writeString("FPNCorrection", "AverageLastFrames")
    c4dev.writeInteger("FPNCorrectionNFrames", 8)
    c4dev.writeInteger("ExtSimpMaxHWin", 7)

    # illumination control (D3)
    c4dev.writeString("LightControllerSelector", "LightController0")
    c4dev.writeString("LightControllerSource", "UserOutput0")
    c4dev.writeFloat("LightBrightness", 100.0)
    # illumination control (D2)
    # LineSelector = Line2
    # LineSource = UserOutput0
    # LineInverter = true
    # switch on the illumination (D2/D3)
    c4dev.writeString("UserOutputSelector", "UserOutput0")
    c4dev.writeInteger("UserOutputValue", 1)


print('********************************************************')
print('* Configure the device and enable and register events')
print('********************************************************')

c4sys = c4hdl.C4Handler()
c4if = selectInterface(c4sys)
c4dev = selectDevice(c4if)

try:
    print('initialize camera')
    # h8SurfSimple initialisation
    initializeDevice(c4dev)

    # event specific configuration

    # enable FrameStart and FrameTransferEnd Events on the device
    c4dev.writeString("EventSelector", "FrameStart")
    c4dev.writeString("EventNotification", "On")
    c4dev.writeString("EventSelector", "FrameTransferEnd")
    c4dev.writeString("EventNotification", "On")

    # register features from EventFrameStartData and
    # EventFrameTransferEndData category
    c4dev.registerEvent("EventFrameStart")
    c4dev.registerEvent("EventFrameStartTimestamp")
    c4dev.registerEvent("EventFrameTransferEnd")
    c4dev.registerEvent("EventFrameTransferEndTimestamp")

    # generate and start an acquisition and an event handling thread
    acqRun = True
    evtT = threading.Thread(target=event_thread, args=(c4dev,))
    acqT = threading.Thread(target=acq_thread, args=(c4dev,))

    evtT.start()
    acqT.start()

    # wait until threads are joined
    acqT.join()
    evtT.join()

    # unregister events!!
    c4dev.unregisterEvent("EventFrameStart")
    c4dev.unregisterEvent("EventFrameStartTimestamp")
    c4dev.unregisterEvent("EventFrameTransferEnd")
    c4dev.unregisterEvent("EventFrameTransferEndTimestamp")

    c4dev.release()
    c4if.release()
except Exception as e:
    print(type(e))
    print("An exception occurred: " + str(e))
