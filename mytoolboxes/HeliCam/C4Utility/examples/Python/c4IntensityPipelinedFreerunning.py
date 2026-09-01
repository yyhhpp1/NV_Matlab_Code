import time
import os
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.widgets import Button


from harvesters.core import Harvester

import warnings
warnings.simplefilter('always')


def selectDevice(h):

    h.update()
    NDevices = len(h.device_info_list)
    print("{} device(s) detected on the Network:\n".format(NDevices))
    for i,dev in enumerate(h.device_info_list):
        print("{}) {} ({})".format(i+1,dev.id_,dev.serial_number))

    if NDevices == 1:
        selectionInt = 1
    else:
        selectionStr = input("Select a device (0=exit): ")
        selectionInt = int(selectionStr)
        if((selectionInt <= 0) or (selectionInt > NDevices)):
            exit('No device selected - exit script')

    deviceID = h.device_info_list[selectionInt-1].id_
    print('selected device:', deviceID,'\n')
    return h.create(selectionInt-1)

def cameraConfig(camera):

    # Number of intergration periods
    NPeriods = 100
    refFrequency = 12000
    NFrames = 4

    camera.remote_device.node_map.TransferQueueMaxBlockCount.value = 2
    camera.remote_device.node_map.TriggerSelector.value = "RecordingStart"
    camera.remote_device.node_map.TriggerMode.value = "Off"
    camera.remote_device.node_map.TriggerSelector.value = "FrameStart"
    camera.remote_device.node_map.TriggerMode.value = "Off"
    camera.remote_device.node_map.TriggerSelector.value = "AcquisitionStart"
    camera.remote_device.node_map.TriggerMode.value = "Off"
    camera.remote_device.node_map.ReverseX.value = False
    camera.remote_device.node_map.ReverseY.value = True
    camera.remote_device.node_map.Rotation.value = 270

    # LIA
    camera.remote_device.node_map.DeviceOperationMode.value = "LockInCam"
    camera.remote_device.node_map.Scan3dExtractionMethod.value = "rawIQ"
    camera.remote_device.node_map.LockInTargetTimeConstantNPeriods.value = NPeriods
    camera.remote_device.node_map.LockInTargetReferenceFrequency.value = refFrequency
    camera.remote_device.node_map.AcquisitionBurstFrameCount.value = NFrames

    # intensity mode configuration
    # Grey scale exposure times in ÃŽÂ¼s (two channels)

    texp1=8000
    texp2=1
    tdead1=1
    frameDuration = camera.remote_device.node_map.LockInActualTimeConstantNPeriods.value / camera.remote_device.node_map.LockInActualReferenceFrequency.value /1e-6
    tdead2 = int(frameDuration - texp1 -texp2 - tdead1)
    S4recordingMode = 1
    S4DarkEn = 1
    S4DarkNFrm = 2
    recordingModeDark = 1

    camera.remote_device.node_map.LowLevelMode.value = 'On'   
    camera.remote_device.node_map.S4DevU32Selector.value = 0
    camera.remote_device.node_map.S4DevU32Value.value = S4recordingMode
    camera.remote_device.node_map.S4DevU32Selector.value = 1
    camera.remote_device.node_map.S4DevU32Value.value = recordingModeDark
    camera.remote_device.node_map.S4DevU32Selector.value = 2
    camera.remote_device.node_map.S4DevU32Value.value = S4DarkEn
    camera.remote_device.node_map.S4DevU32Selector.value = 3
    camera.remote_device.node_map.S4DevU32Value.value = S4DarkNFrm
    camera.remote_device.node_map.S4DevFloatSelector.value = 1
    camera.remote_device.node_map.S4DevFloatValue.value = tdead1
    camera.remote_device.node_map.S4DevFloatSelector.value = 2
    camera.remote_device.node_map.S4DevFloatValue.value = texp1
    camera.remote_device.node_map.S4DevFloatSelector.value = 3
    camera.remote_device.node_map.S4DevFloatValue.value = tdead2
    camera.remote_device.node_map.S4DevFloatSelector.value = 4
    camera.remote_device.node_map.S4DevFloatValue.value = texp2
    
    # set vrefpix_load (required for grayscale mode)
    camera.remote_device.node_map.DAC0Selector.value = 4
    camera.remote_device.node_map.DAC0Value.value = int(1.7/3.3*4096)



def acquire3(camera,imagehandle,timeout=30):
    buffer = camera.fetch()
    #take only first 4 components (nframes=4, I only)
    data = np.array([img.data%2**15//4 for img in (buffer.payload.components)[0:4]]).reshape([4,512,542]).astype(int)

    #display the difference between the second exposed and the first electrically dark frame
    imagehandle.set_data(data[1,:,:] - data[-2,:,:]) #data[1,:,:]-
    #imagehandle.set_data(data[2,:,:])
    plt.draw()
    plt.pause(0.005)
    buffer.queue()



nxview = 512
nyview = 542
camin = 0
camax = 600

plt.ion()  # Turn on interactive mode
fig0=plt.figure()
axAmpl = fig0.add_axes([0.04,0.12,0.9,0.82],xlim=(0,nxview),ylim=(nyview,0))
im2=axAmpl.imshow(np.zeros([nyview,nxview]),interpolation='nearest',vmin=camin,vmax=camax,cmap='gist_gray')
fig0.colorbar(im2, ax=axAmpl)

def autoNormalize(event):
    data = im2.get_array()
    im2.set_clim(vmin=data.min(), vmax=data.max())
    plt.draw()

axAutoNorm = fig0.add_axes([0.04,0.02,0.2,0.05])
btnAutoNorm = Button(axAutoNorm,'Auto Normalize')
btnAutoNorm.on_clicked(autoNormalize)

plt.show(block=False)  # Show plot without blocking

h = Harvester()
# read heliotis *.CTI path from environment variable
ctiFile = os.environ['DIAPHUS_GENTL64_FILE']
h.add_file(ctiFile)

# create camera object for interaction
camera = selectDevice(h)
cameraConfig(camera)


camera.start()

nacquisitions = 500
t1=time.time()
# for i in range(nacquisitions):
while(True):
    acquire3(camera,im2)
print('average display rate (Hz):',1/((time.time()-t1)/nacquisitions))

# free resources
camera.stop()
camera.destroy()
