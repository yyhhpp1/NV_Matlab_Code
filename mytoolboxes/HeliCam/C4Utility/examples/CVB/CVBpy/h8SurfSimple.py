##
# \file        h8SurfSimple.py
# \author      Silvan Murer
# \date        24 May 2023
# \copyright   Heliotis, 2023
# \version     1.0.0
#
# \brief       Simple Python example using CVBPy library

import os
import cvb 

import numpy as np
import matplotlib.pyplot as plt

##
# Scan for available devices and print device list
# let the user select one and open the connection to the device
# \return camera object
def selectDevice():
    discover = cvb.DeviceFactory.discover_from_root( cvb.DiscoverFlags.IgnoreVins | cvb.DiscoverFlags.IgnoreGevFD | cvb.DiscoverFlags.IgnoreGevSD )
    print(f"{len(discover)} devices detected on the Network\n\n")
    cnt = 0
    devices = []
    for info in discover:
        if info.discovery_layer == cvb.ModuleLayer.TransportLayerDevice:
            cnt = cnt + 1
            print(f"{cnt}) {info.read_property(cvb.DiscoveryProperties.DeviceId)} ({info.read_property(cvb.DiscoveryProperties.DeviceSerialNumber)})")
            devices.append(info)
    if cnt == 0:
        exit('No device detected...')
    elif cnt == 1:
        selection_int = 1
    else:
        selection_str = input("Select a device (0=exit): ")
        selection_int = int(selection_str)
        if((selection_int <= 0) or (selection_int > cnt)):
            exit('No device selected - exit script')

    print(f"selected device: {devices[selection_int-1].read_property(cvb.DiscoveryProperties.DeviceId)}")
    # cvb.AcquisitionStack.GenTL is important to get the Multi-Part functionality!
    return cvb.DeviceFactory.open(devices[selection_int-1].access_token, cvb.AcquisitionStack.GenTL)


##
# simple configuration example of heliInspect H8 using internal motion control
# \param dev_node_map cvb device node map object
def initializeDevice(dev_node_map, scanPosition, scanRange):
    # enable required components
    dev_node_map["ComponentSelector"].value = "Intensity"
    dev_node_map["ComponentEnable"].value = True
    dev_node_map["ComponentSelector"].value = "Range"
    dev_node_map["ComponentEnable"].value = False
    dev_node_map["ComponentSelector"].value = "Reflectance"
    dev_node_map["ComponentEnable"].value = True
    dev_node_map["ComponentSelector"].value = "Phase"
    dev_node_map["ComponentEnable"].value = False

    # enable required chunk data (optional)
    dev_node_map["ChunkModeActive"].value = True
    dev_node_map["ChunkSelector"].value = "PartCount"
    dev_node_map["ChunkEnable"].value = True
    dev_node_map["ChunkSelector"].value = "PartType"
    dev_node_map["ChunkEnable"].value = True

    # trigger configuration
    dev_node_map["TriggerSelector"].value = "RecordingStart"
    dev_node_map["TriggerMode"].value = "On"
    dev_node_map["TriggerSource"].value = "Stage"
    dev_node_map["TriggerSelector"].value = "AcquisitionStart"
    dev_node_map["TriggerMode"].value = "Off"
    dev_node_map["TriggerSelector"].value = "FrameStart"
    dev_node_map["TriggerMode"].value = "On"
    dev_node_map["TriggerSource"].value = "Software"
    # Hint: The TriggerSource also controls the TriggerSoftware feature.

    # encoder configuration
    dev_node_map["EncoderSelector"].value = "Camera"
    dev_node_map["EncoderInverter"].value = True

    # motion and position configuration
    dev_node_map["ScanPosition"].value = scanPosition
    dev_node_map["ScanRange"].value = scanRange
    dev_node_map["ScanSpeed"].value = 5.0
    dev_node_map["GeneralSpeed"].value = 10.0

    dev_node_map["ScanMode"].value = "Down"
    dev_node_map["StageInit"].execute()

    # additional camera and processing configuration
    dev_node_map["Scan3dExtractionMethod"].value = "AcceleratedCenterOfMassIQCorrection"
    dev_node_map["Scan3dScalingMethod"].value = "zTags"
    dev_node_map["Scan3dDistanceUnit"].value = "um"

    dev_node_map["TargetVerticalSpacing"].value = 4.0
    dev_node_map["ExposureRatio"].value = 1.0

    dev_node_map["FPNCorrection"].value = "AverageLastFrames"
    dev_node_map["FPNCorrectionNFrames"].value = 8
    dev_node_map["ExtSimpMaxHWin"].value = 7

    # illumination control (D3)
    dev_node_map["LightControllerSelector"].value = "LightController0"
    dev_node_map["LightControllerSource"].value = "UserOutput0"
    dev_node_map["LightBrightness"].value = 100.0
    # illumination control (D2)
    # LineSelector = Line2
    # LineSource = UserOutput0
    # LineInverter = true
    # switch on the illumination (D2/D3)
    dev_node_map["UserOutputSelector"].value = "UserOutput0"
    dev_node_map["UserOutputValue"].value = True


camera = selectDevice()
dev_node_map = camera.node_maps["Device"]

# Motion parameters in [mm] or [mm/s]
scanPosition = -16.6
scanRange = 0.5
initializeDevice(dev_node_map, scanPosition, scanRange)

# In this example, we use the 'Intensity' component for the sruface information
# This component has the type 'uint16_t' with a value range of 0..65535
# With Scan3dCoordinateOffset[CoordinateC] and Scan3dCoordinateScale[CoordinateC]
# we move the surface into this range...
dev_node_map["Scan3dCoordinateSelector"].value = "CoordinateC"
dev_node_map["Scan3dCoordinateOffset"].value = (scanPosition - (scanRange / 2.0)) * 1000.0
dev_node_map["Scan3dCoordinateScale"].value = scanRange * 1000.0 / 65535.0

scanPos = dev_node_map["ScanPosition"].value
print("Ready for measurement. Measure on position: " + str(scanPos) + "mm")
selection_str = input("y=yes else=exit: ")
if (selection_str != "y"):
    camera.close()
    exit("User interrupt - exit")

print('start acquisition')
stream = camera.stream(cvb.CompositeStream)
print(type(stream))
stream.start()

# setup plot
gridsize = (1, 2)
fig = plt.figure()
axSurf = plt.subplot2grid(gridsize, (0, 0))
axAmp = plt.subplot2grid(gridsize, (0, 1))
fig.suptitle('Measurements')
axSurf.set_title('Component[0] - Surface')
imSurf = axSurf.imshow(np.ones([512, 542]))
axAmp.set_title('Component[1] - Amplitude')
imAmp = axAmp.imshow(np.ones([512, 542]))
plt.show(block=False)
plt.draw()
plt.pause(0.1)

# measurement loop (10 iterations)
for itr in range(10):
    try:
        # trigger single measurement
        dev_node_map["TriggerSelector"].value = "FrameStart"
        dev_node_map["TriggerSoftware"].execute()

        # acquire data
        composite, waitStatus, enumerator = stream.wait()
        if waitStatus != cvb.WaitStatus.Ok:
            print(f"Failed to acquire data! {waitStatus}")
            continue

        print(f"item_count: {composite.item_count}")
        print(f"Purpose: {composite.purpose}")

        # plot surface and amplitude component
        if (composite.item_count >= 1):
            composite_0_array = cvb.as_array(composite[0], copy=True)
            composite_0_array = composite_0_array * (scanRange * 1000.0 / 65535.0) + ((scanPosition - (scanRange / 2.0)) * 1000.0)
            imSurf.set_data(composite_0_array)
            imSurf.set_clim(vmin=np.min(composite_0_array), vmax=np.max(composite_0_array))
            pass
        if (composite.item_count >= 2):
            amplitude = composite[1]
            composite_1_array = cvb.as_array(composite[1], copy=True)
            imAmp.set_data(composite_1_array)
            imAmp.set_clim(vmin=np.min(composite_1_array), vmax=np.max(composite_1_array))
        plt.draw()
        plt.pause(0.1)
        print("iteration " + str(itr) + " done!\n")

    except Exception as error:
        print(error)
        exit('acquisition error')

# stop acquisition and close camera connection
stream.abort()
camera.close()
print('example end')
