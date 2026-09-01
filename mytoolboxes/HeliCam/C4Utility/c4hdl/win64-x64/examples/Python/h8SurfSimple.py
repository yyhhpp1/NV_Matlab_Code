##
# \file        h8SurfSimple.py
# \author      Silvan Murer
# \date        07 April 2021
# \copyright   Heliotis, 2021
# \version     1.0.2
#
# \brief       Simple Python example based on C4Hdl library for heliInspect H8
import os
import sys
import platform
import numpy as np
import matplotlib.pyplot as plt

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
print('* Configure and acquire data in "3D surface mode"')
print('********************************************************')

c4sys = c4hdl.C4Handler()
c4if = selectInterface(c4sys)
c4dev = selectDevice(c4if)

try:
    print('initialize camera')
    initializeDevice(c4dev)
except Exception as error:
    print(error)
    exit('init failed')

scanPos = c4dev.readFloat("ScanPosition")
print("Ready for measurement. Measure on position: " + str(scanPos) + "mm")
selection_str = input("y=yes else=exit: ")
if (selection_str != "y"):
    c4dev.release()
    c4if.release()
    exit("User interrupt - exit")

print('start acquisition')
c4dev.startAcquisition(4)

# setup plot
gridsize = (1, 2)
fig = plt.figure()
axSurf = plt.subplot2grid(gridsize, (0, 0))
axAmp = plt.subplot2grid(gridsize, (0, 1))
fig.suptitle('Measurements')
axSurf.set_title('Surface')
imSurf = axSurf.imshow(np.ones([542, 512]))
axAmp.set_title('Amplitude')
imAmp = axAmp.imshow(np.ones([542, 512]))
plt.show(block=False)
plt.draw()
plt.pause(0.1)

# measurement loop (10 iterations)
for itr in range(0, 10):
    try:
        # trigger single measurement
        c4dev.writeString("TriggerSelector", "FrameStart")
        c4dev.executeCommand("TriggerSoftware")

        # acquire data
        c4buf = c4dev.getBuffer(10000)

        # look for float surface and amplitude component
        surfPart = -1
        ampPart = -1
        nofParts = c4buf.readInteger("ChunkPartCount")
        for i in range(0, nofParts):
            c4buf.writeInteger("ChunkPartSelector", i)
            partType = c4buf.readString("ChunkPartType")
            if(partType == "Surface"):
                surfPart = i
            elif(partType == "Amplitude"):
                ampPart = i

        # plot surface and amplitude component
        if (surfPart >= 0):
            rawSurf = c4buf.getDataPartFloat(surfPart).asNpArray()
            rawSurfDim = c4buf.getPartDimension(surfPart).asNpArray()
            surfWidth = rawSurfDim[0]
            surfHeight = rawSurfDim[1]
            surface = rawSurf.reshape(surfHeight, surfWidth)
            imSurf.set_data(surface)
            imSurf.set_clim(vmin=np.min(surface), vmax=np.max(surface))
            imSurf.set_extent((0, surfWidth, surfHeight, 0))
        if (ampPart >= 0):
            rawAmp = c4buf.getDataPartUint16(ampPart).asNpArray()
            rawAmpDim = c4buf.getPartDimension(ampPart).asNpArray()
            ampWidth = rawAmpDim[0]
            ampHeight = rawAmpDim[1]
            amplitude = rawAmp.reshape(ampHeight, ampWidth)
            imAmp.set_data(amplitude)
            imAmp.set_clim(vmin=np.min(amplitude), vmax=np.max(amplitude))
            imAmp.set_extent((0, ampWidth, ampHeight, 0))
        plt.draw()
        plt.pause(0.1)
        print("iteration " + str(itr) + " done!\n")

        # release buffer
        c4buf.release()
    except Exception as error:
        print(error)
        exit('acquisition error')

c4dev.stopAcquisition()
c4dev.release()
c4if.release()
