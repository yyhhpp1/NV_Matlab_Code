##
# \file        h8SurfSimple.py
# \author      Silvan Murer
# \date        07 April 2021
# \copyright   Heliotis, 2021
# \version     1.0.2
#
# \brief       Simple Python example based on Harvester package for heliInspect H8
import os
import numpy as np
import matplotlib.pyplot as plt

from harvesters.core import Harvester

##
# Scan for available devices and print device list
# let the user select one and open the connection to the device
# if just one device available, open it without user interaction
# \param h harvester object
# \return harvesters camera object
def selectDevice(h):
    h.update()
    print(str(len(h.device_info_list)) + " devices detected on the Network\n\n")
    cnt = 0
    for dev in h.device_info_list:
        cnt = cnt + 1
        msg = str(cnt) + ") " + dev.id_ + " (sn:" + dev.serial_number + ")"
        print(msg)
    if cnt == 1:
        selection_int = 1
    else:
        selection_str = input("Select a device (0=exit): ")
        selection_int = int(selection_str)
        if((selection_int <= 0) or (selection_int > cnt)):
            exit('No device selected - exit script')

    deviceID = h.device_info_list[selection_int-1].id_
    print('selected device:', deviceID)
    return h.create(selection_int-1)


##
# simple configuration example of heliInspect H8 using internal motion control
# \param camera harvesters camera object
def initializeDevice(camera):
    # Motion parameters in [mm] or [mm/s]
    scanPosition = -1.4
    scanRange = 0.5
    scanSpeed = 5.0
    generalSpeed = 10.0
    # exposure ration between 0.0 and 1.0 [1.0 = 100% exposure]
    exposureRatio = 1.0

    camera.remote_device.node_map.DeviceOperationMode.value = 'Topography'

    # enable required components
    camera.remote_device.node_map.ComponentSelector.value = "Intensity"
    camera.remote_device.node_map.ComponentEnable.value = False
    camera.remote_device.node_map.ComponentSelector.value = "Range"
    camera.remote_device.node_map.ComponentEnable.value = True
    camera.remote_device.node_map.ComponentSelector.value = "Reflectance"
    camera.remote_device.node_map.ComponentEnable.value = True
    camera.remote_device.node_map.ComponentSelector.value = "Phase"
    camera.remote_device.node_map.ComponentEnable.value = False

    # enable required chunk data (optional)
    camera.remote_device.node_map.ChunkModeActive.value = True
    camera.remote_device.node_map.ChunkSelector.value = "PartCount"
    camera.remote_device.node_map.ChunkEnable.value = True
    camera.remote_device.node_map.ChunkSelector.value = "PartType"
    camera.remote_device.node_map.ChunkEnable.value = True

    # trigger configuration
    camera.remote_device.node_map.TriggerSelector.value = "RecordingStart"
    camera.remote_device.node_map.TriggerMode.value = "On"
    camera.remote_device.node_map.TriggerSource.value = "Stage"
    camera.remote_device.node_map.TriggerSelector.value = "AcquisitionStart"
    camera.remote_device.node_map.TriggerMode.value = "Off"
    camera.remote_device.node_map.TriggerSelector.value = "FrameStart"
    camera.remote_device.node_map.TriggerMode.value = "On"
    camera.remote_device.node_map.TriggerSource.value = "Software"
    # Hint: The TriggerSource also controls the TriggerSoftware feature.

    # encoder configuration
    camera.remote_device.node_map.EncoderSelector.value = "Camera"
    camera.remote_device.node_map.EncoderInverter.value = True

    # motion and position configuration
    camera.remote_device.node_map.ScanPosition.value = scanPosition
    camera.remote_device.node_map.ScanRange.value = scanRange
    camera.remote_device.node_map.ScanSpeed.value = scanSpeed
    camera.remote_device.node_map.GeneralSpeed.value = generalSpeed

    camera.remote_device.node_map.ScanMode.value = "Down"
    camera.remote_device.node_map.StageInit.execute()

    # additional camera and processing configuration
    camera.remote_device.node_map.Scan3dExtractionMethod.value = "AcceleratedCenterOfMassIQCorrection"
    camera.remote_device.node_map.Scan3dScalingMethod.value = "zTags"
    camera.remote_device.node_map.Scan3dDistanceUnit.value = "um"

    camera.remote_device.node_map.TargetVerticalSpacing.value = 4.0
    camera.remote_device.node_map.ExposureRatio.value = exposureRatio

    camera.remote_device.node_map.ExtSimpMaxHWin.value = 7

    # illumination control (D3)
    camera.remote_device.node_map.LightControllerSelector.value = "LightController0"
    camera.remote_device.node_map.LightControllerSource.value = "UserOutput0"
    camera.remote_device.node_map.LightBrightness.value = 100.0
    # illumination control (D2)
    # LineSelector = Line2
    # LineSource = UserOutput0
    # LineInverter = true
    # switch on the illumination (D2/D3)
    camera.remote_device.node_map.UserOutputSelector.value = "UserOutput0"
    camera.remote_device.node_map.UserOutputValue.value = True


print('********************************************************')
print('* Configure and acquire data in "3D surface mode"')
print('********************************************************')

h = Harvester()
# read heliotis *.CTI path from environment variable
ctiFile = os.environ['DIAPHUS_GENTL64_FILE']
h.add_file(ctiFile)

camera = selectDevice(h)

try:
    print('initialize camera')
    initializeDevice(camera)
except Exception as error:
    print(error)
    exit('init failed')

scanPos = camera.remote_device.node_map.ScanPosition.value
print("Ready for measurement. Measure on position: " + str(scanPos) + "mm")
selection_str = input("y=yes else=exit: ")
if (selection_str != "y"):
    camera.destroy()
    exit("User interrupt - exit")

print('start acquisition')
camera.start()

# setup plot
gridsize = (1, 2)
fig = plt.figure()
axSurf = plt.subplot2grid(gridsize, (0, 0))
axAmp = plt.subplot2grid(gridsize, (0, 1))
fig.suptitle('Measurements')
axSurf.set_title('Surface')
imSurf = axSurf.imshow(np.ones([512, 542]))
axAmp.set_title('Amplitude')
imAmp = axAmp.imshow(np.ones([512, 542]))
plt.show(block=False)
plt.draw()
plt.pause(0.1)

# measurement loop (10 iterations)
for itr in range(0, 10):
    try:
        # trigger single measurement
        camera.remote_device.node_map.TriggerSelector.value = "FrameStart"
        camera.remote_device.node_map.TriggerSoftware.execute()

        # acquire data
        with camera.fetch(timeout=10.0) as buffer:
            # look for float surface and amplitude component
            surfPart = -1
            ampPart = -1
            nofParts = camera.remote_device.node_map.ChunkPartCount.value
            for i in range(0, nofParts):
                camera.remote_device.node_map.ChunkPartSelector.value = i
                partType = camera.remote_device.node_map.ChunkPartType.value
                if(partType == "Surface"):
                    curPixelFormat = buffer.payload.components[i].data_format
                    if(curPixelFormat == 'Mono16'):
                        pass
                    elif(curPixelFormat == 'Coord3D_C32f'):
                        surfPart = i
                elif(partType == "Amplitude"):
                    ampPart = i

            # plot surface and amplitude component
            if (surfPart >= 0):
                height = buffer.payload.components[surfPart].height
                width = buffer.payload.components[surfPart].width
                surface = buffer.payload.components[surfPart].data.reshape(height, width)
                surface = np.copy(surface)
                imSurf.set_data(surface)
                imSurf.set_clim(vmin=np.min(surface), vmax=np.max(surface))
            if (ampPart >= 0):
                height = buffer.payload.components[ampPart].height
                width = buffer.payload.components[ampPart].width
                amplitude = buffer.payload.components[ampPart].data.reshape(height, width)
                amplitude = np.copy(amplitude)
                imAmp.set_data(amplitude)
                imAmp.set_clim(vmin=np.min(amplitude), vmax=np.max(amplitude))
            plt.draw()
            plt.pause(0.1)
            print("iteration " + str(itr) + " done!\n")
    except Exception as error:
        print(error)
        exit('acquisition error')

# stop acquisition and close camera connection
camera.stop()
camera.destroy()
print('example end')
