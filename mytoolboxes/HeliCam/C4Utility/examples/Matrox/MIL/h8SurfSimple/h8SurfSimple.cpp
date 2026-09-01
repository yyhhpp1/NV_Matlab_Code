/********************************************************************************/
/*
* File name: h8SurfSimple.cpp
*
* Synopsis:  This program demonstrates MIL features for GenICam's™ GenTL.
*            For more information about GenTL see the EMVA's GenICam section
*            at http://www.emva.org. The MIL M_SYSTEM_GENTL is a GenICam™
*            GenTL consumer. As such it requires a third party supplied
*            GenTL producer to be installed.
*
* Copyright © Matrox Electronic Systems Ltd., 1992-2017.
* All Rights Reserved
*/

#include <chrono>
#include <thread>

#include <mil.h>
#include <vector>
#include <map>

#include "h8SurfSimple.h"

using namespace std;

/* Utility function declarations. */

/* GenTL Producer selection and info functions. */
MIL_INT SelectGenTLProducerLibrary();
MIL_INT SelectGenTLProducerInterface(std::vector<MIL_ID> MilSystem);
MIL_ID SelectGenTLProducerDevice(MIL_ID MilSystem);

/* Device selection and usage functions. */
void UseGenTLDevice(GenTLDevice& Device);
void FreeGenTLDevice(GenTLDevice& Device);

/* Initialize H8 Device */
void InitializeDevice(GenTLDevice& Device);

/* function to allocate memory for display */
void AllocateDisplay(GenTLDevice& Device);

/* Utility function used to disable error messages while cycling MIL system allocation. */
void DisableErrorPrint() { MappControl(M_ERROR, M_PRINT_DISABLE); }
void EnableErrorPrint() { MappControl(M_ERROR, M_PRINT_ENABLE); }

/* helper variables and functions */
volatile bool dataReceived;
void rescaleDisplay(GenTLDevice& Device, MIL_ID component, int dispIdx);

/* Main function. */
int MosMain(void)
{
  MIL_ID MilApplication = 0;       /* Application identifier.  */
  std::vector<MIL_ID> MilSystem;   /* System identifier.       */

  /* vector to a vector of devices. */
  /* There is one vector of devices per MIL system allocated.*/
  vector<vector<GenTLDevice>> Devices(MAX_SYSTEMS, vector<GenTLDevice>());
  MIL_INT NumDevices = 0;

  /* Allocate the MIL application module. */
  MappAlloc(M_DEFAULT, &MilApplication);

  MosPrintf(MIL_TEXT("This example shows how to use heliInspect H8\n"));
  MosPrintf(MIL_TEXT("as GenTL producer in MATROX imaging library.\n\n"));
  MosPrintf(MIL_TEXT("Press <Enter> to continue.\n\n"));
  MosGetch();

  /* Select a GenTL producer library */
  MIL_INT selectedProducer = SelectGenTLProducerLibrary();
  if (selectedProducer == -1)
  {
    MappFree(MilApplication);
    return 0;
  }

  /* Allocate MilSystem (M_SYSTEM_GENTL) */
  for (MIL_INT i = M_DEV0; i < MAX_SYSTEMS; i++)
  {
    MIL_ID milSys = M_NULL;
    if (i != M_DEV0)
      DisableErrorPrint();
    MsysAlloc(M_SYSTEM_GENTL, i + M_GENTL_PRODUCER(selectedProducer), M_DEFAULT, &milSys);
    if (i != M_DEV0)
      EnableErrorPrint();
    if (milSys != M_NULL)
      MilSystem.push_back(milSys);
    else
      break;
  }

  /* Select a GenTL interface */
  MIL_INT selectedInterface = SelectGenTLProducerInterface(MilSystem);
  /* Select a GenTL device */
  GenTLDevice Device;
  Device.MilSystem = MilSystem[selectedInterface];
  Device.MilDigitizer = SelectGenTLProducerDevice(MilSystem[selectedInterface]);
  
  UseGenTLDevice(Device);


  /* Free resources associated to the device. */
  FreeGenTLDevice(Device);

  /* Free allocated MIL systems. */
  for (auto milSys : MilSystem)
  {
    if (milSys)
      MsysFree(milSys);
  }

  /* Free MIL application module. */
  MappFree(MilApplication);
  return 0;
}

/* Used to enumerate and select a GenTL producer library. */
MIL_INT SelectGenTLProducerLibrary()
{
  MosPrintf(MIL_TEXT("---------------------- Detecting installed GenTL producers ---------------------\n"));

  MIL_INT Selection = 1;
  MIL_INT NumLibraries = 0;

  /* Inquire the number of installed GenTL producers. */
  MappInquire(M_GENTL_PRODUCER_COUNT, &NumLibraries);
  if (NumLibraries == 0)
  {
    MosPrintf(MIL_TEXT("A third party software component, a GenTL Producer, is missing.\n"));
    return -1;
  }

  MosPrintf(MIL_TEXT("Found the following GenTL producer libraries: \n\n"));

  /* Get the installed GenTL producer libraries. */
  MIL_INT Size = 0;
  for (MIL_INT i = 0; i < NumLibraries; i++)
  {
    milstring Descriptor;
    MappInquire(M_GENTL_PRODUCER_DESCRIPTOR + i, Descriptor);
    MosPrintf(MIL_TEXT("%2.d %s.\n"), i + 1, Descriptor.c_str());
  }

  /* Ask the user to select a GenTL producer to use. */
  MosPrintf(MIL_TEXT("\nWhich GenTL producer do you want to use? "));
  do
  {
    MOs_scanf_s(MIL_TEXT("%lld"), &Selection);
    if (Selection > NumLibraries)
      MosPrintf(MIL_TEXT("Invalid selection.\n"));
  } while (Selection > NumLibraries);
  MosPrintf(MIL_TEXT("\n"));
  return Selection - 1;
}

MIL_INT SelectGenTLProducerInterface(std::vector<MIL_ID> MilSystem)
{
  MosPrintf(MIL_TEXT("---------------------- Detecting available interfaces ---------------------\n"));

  MIL_INT Selection = 1;
  MIL_INT NumInterfaces = 0;

  for (int i = 0; i < MilSystem.size(); i++) {
    /* Get the number of GenTL interfaces associated to this MIL system. */
    MIL_INT numInterfacesOnMilSystem = 0;
    MsysInquire(MilSystem[i], M_GENTL_INTERFACE_COUNT, &numInterfacesOnMilSystem);
    

    /* Get the available GenTL producer interfaces. */
    for (MIL_INT64 j = 0; j < numInterfacesOnMilSystem; j++)
    {
      milstring InterfaceID;
      MsysInquireFeature(MilSystem[i], M_GENTL_INTERFACE_NUMBER(j) + M_FEATURE_VALUE, MIL_TEXT("InterfaceID"), M_TYPE_STRING, InterfaceID);
      NumInterfaces++;
      MosPrintf(MIL_TEXT("%2.d %s.\n"), NumInterfaces, InterfaceID.c_str());
    }
  }

  if (NumInterfaces == 0)
  {
    MosPrintf(MIL_TEXT("No GenTL interfaces found.\n"));
    MosPrintf(MIL_TEXT("Make sure your GenTL Producer drivers are properly installed.\n"));
    return -1;
  }

  MosPrintf(MIL_TEXT("\nWhich interface do you want to use? "));
  do
  {
    MOs_scanf_s(MIL_TEXT("%lld"), &Selection);
    if (Selection > NumInterfaces)
      MosPrintf(MIL_TEXT("Invalid selection.\n"));
  } while (Selection > NumInterfaces);
  MosPrintf(MIL_TEXT("\n"));
  return Selection - 1;
}

MIL_ID SelectGenTLProducerDevice(MIL_ID MilSystem)
{
  MosPrintf(MIL_TEXT("---------------------- Detecting available devices ---------------------\n"));

  MIL_INT Selection = 1;
  MIL_INT NumDevices = 0;

  /* Get the number of devices associated to the Interface. */
  MsysInquire(MilSystem, M_GENTL_INTERFACE_NUMBER(0) + M_GENTL_DEVICE_COUNT, &NumDevices);

  if (NumDevices == 0)
  {
    MosPrintf(MIL_TEXT("\tNo devices found.\n"));
    MosPrintf(MIL_TEXT("\tMake sure a device is connected to this interface and\n"));
    MosPrintf(MIL_TEXT("\tthat your GenTL Producer's drivers are properly installed.\n"));
    return -1;
  }

  /* For each device inquire its vendor info and add the device to the device vector. */
  for (MIL_INT64 i = 0; i < NumDevices; i++)
  {
    milstring deviceID;
    milstring serialNo;
    MsysControlFeature(MilSystem, M_GENTL_INTERFACE_NUMBER(0) + M_FEATURE_VALUE, MIL_TEXT("DeviceSelector"), M_TYPE_INT64, &i);
    MsysInquireFeature(MilSystem, M_GENTL_INTERFACE_NUMBER(0) + M_FEATURE_VALUE, MIL_TEXT("DeviceID"), M_TYPE_STRING, deviceID);
    MsysInquireFeature(MilSystem, M_GENTL_INTERFACE_NUMBER(0) + M_FEATURE_VALUE, MIL_TEXT("DeviceSerialNumber"), M_TYPE_STRING, serialNo);

    MosPrintf(MIL_TEXT("%2.d %s (%s)\n"), i + 1, deviceID.c_str(), serialNo.c_str());
  }

  MosPrintf(MIL_TEXT("\nWhich device do you want to use? "));
  do
  {
    MOs_scanf_s(MIL_TEXT("%lld"), &Selection);
    if (Selection > NumDevices)
      MosPrintf(MIL_TEXT("Invalid selection.\n"));
  } while (Selection > NumDevices);
  MosPrintf(MIL_TEXT("\n"));

  MIL_ID MilDigitizer;
  MdigAlloc(MilSystem, Selection - 1, MIL_TEXT("M_DEFAULT"), M_DEFAULT, &MilDigitizer);
  return MilDigitizer;
}

/* User's processing function called every time a grab buffer is ready. */
/* -------------------------------------------------------------------- */
MIL_INT MFTYPE ProcessingFunction(MIL_INT HookType, MIL_ID HookId, void* HookDataPtr)
{
  GenTLDevice *DevicePtr = (GenTLDevice *)HookDataPtr;

  /* Retrieve the MIL_ID of the grabbed buffer */
  MIL_INT ModifiedContainerId = M_NULL;
  MIL_INT64 Attribute = 0;
  MdigGetHookInfo(HookId, M_MODIFIED_BUFFER + M_BUFFER_ID, &ModifiedContainerId);
  MbufInquire(ModifiedContainerId, M_EXTENDED_ATTRIBUTE, &Attribute);

  MIL_INT nofParts = 0;
  MbufInquire(ModifiedContainerId, M_COMPONENT_COUNT, &nofParts);

  // We should receive 2 image parts.
  // 0: surface (float) ; 1: amplitude (Mono16)
  MIL_ID surfaceComponent = M_NULL;
  MbufInquire(ModifiedContainerId, M_COMPONENT_ID_BY_INDEX(0), &surfaceComponent);

  MIL_ID amplitudeComponent = M_NULL;
  MbufInquire(ModifiedContainerId, M_COMPONENT_ID_BY_INDEX(1), &amplitudeComponent);

  MbufExport(MIL_TEXT("Surface.tif"), M_TIFF, surfaceComponent);
  MbufExport(MIL_TEXT("Amplitude.tif"), M_TIFF, amplitudeComponent);

  /* rescale the buffer shown in the window (if the size [x, y] has changed) */
  rescaleDisplay(*DevicePtr, surfaceComponent, 0);
  MbufCopy(surfaceComponent, DevicePtr->MilImageDisp[0]);

  rescaleDisplay(*DevicePtr, amplitudeComponent, 1);
  MbufCopy(amplitudeComponent, DevicePtr->MilImageDisp[1]);

  /* sync with main thread... */
  dataReceived = true;
  return 0;
}

/* Used to allocate and start acquisition from a device. */
void UseGenTLDevice(GenTLDevice& Device)
{
 

  if (Device.MilDigitizer)
  {
    // e.g. Show the feature browser of the H8
    //MdigControl(Device.MilDigitizer, M_GC_FEATURE_BROWSER, M_OPEN + M_ASYNCHRONOUS);
    // enable all components on device, initialize and allocate memory for the display
    AllocateDisplay(Device);

    // allocate the containers (buffers) used to acquire data.
    for (int i = 0; i < NOF_MIL_CONTAINERS; i++) {
      MbufAllocDefault(Device.MilSystem, Device.MilDigitizer, M_CONTAINER + M_3D_SCENE + M_GRAB + M_PROC, M_DEFAULT, M_DEFAULT, &Device.MilContainers[i]);
      if (Device.MilContainers[i] == M_NULL) {
        // error
        MosPrintf(MIL_TEXT("\nBuffer allocation ERROR\n"));
        return;
      }
    }

    /* configuration sequence for heliInspect H8 */
    InitializeDevice(Device);

    MdigControl(Device.MilDigitizer, M_GRAB_MODE, M_ASYNCHRONOUS);

    MdigControl(Device.MilDigitizer, M_GRAB_TIMEOUT, 30000);
    MdigControl(Device.MilDigitizer, M_PROCESS_TIMEOUT, 30000);
    /* enable software trigger */
    MdigControl(Device.MilDigitizer, M_GRAB_TRIGGER_SOURCE, M_SOFTWARE);
    MdigControl(Device.MilDigitizer, M_GRAB_TRIGGER_STATE, M_ENABLE);


    for (int i = 0; i < 10; ++i)
    {
      MosPrintf(MIL_TEXT("Press <Enter> to acquire, N to abort, F for opening feature browser before acquisition\n\n"));
      char c = MosGetch();
      if (c == 'n' || c == 'N')
        break;

      if (c == 'f' || c == 'f')
      {
        MdigControl(Device.MilDigitizer, M_GC_FEATURE_BROWSER, M_OPEN + M_ASYNCHRONOUS);
        MosPrintf(MIL_TEXT("Press <Enter> to start acquire\n\n"));
        MosGetch();
        MosPrintf(MIL_TEXT("start acquire\n\n"));
      }

      dataReceived = false;
      // start acquisition
      MdigProcess(Device.MilDigitizer, Device.MilContainers, NOF_MIL_CONTAINERS, M_START, M_DEFAULT, ProcessingFunction, &Device);

      // create a software trigger
      //MdigControlFeature(Device.MilDigitizer, M_FEATURE_EXECUTE, MIL_TEXT("TriggerSoftware"), M_DEFAULT, M_NULL);
      MdigControl(Device.MilDigitizer, M_GRAB_TRIGGER_SOFTWARE, M_ACTIVATE);

      // wait for data...
      while (!dataReceived) {
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
      }

      // stop acquisition
      MdigProcess(Device.MilDigitizer, Device.MilContainers, NOF_MIL_CONTAINERS, M_STOP, M_DEFAULT, ProcessingFunction, &Device);
    }

  }
}

/*
 * simple configuration example of heliInspect H8 using internal motion control
 */
void InitializeDevice(GenTLDevice& Device)
{
  MIL_INT64 i64Value = 0;
  MIL_DOUBLE dValue = 0.0;
  milstring sValue = MIL_TEXT("");
  const MIL_BOOL bTrue = M_TRUE;
  const MIL_BOOL bFalse = M_FALSE;

  // Motion parameters in [mm] or [mm/s]
  MIL_DOUBLE scanPosition = -1.4;
  MIL_DOUBLE scanRange = 0.5;
  MIL_DOUBLE scanSpeed = 5.0;
  MIL_DOUBLE generalSpeed = 10.0;
  // exposure ration between 0.0 and 1.0 [1.0 = 100% exposure]
  MIL_DOUBLE exposureRatio = 1.0;

  // enable required components
  sValue = MIL_TEXT("Intensity");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentEnable"), M_TYPE_BOOLEAN, &bFalse);
  sValue = MIL_TEXT("Range");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentEnable"), M_TYPE_BOOLEAN, &bTrue);
  sValue = MIL_TEXT("Reflectance");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentEnable"), M_TYPE_BOOLEAN, &bTrue);
  sValue = MIL_TEXT("Phase");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ComponentEnable"), M_TYPE_BOOLEAN, &bFalse);

  // enable required chunk data (optional)
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ChunkModeActive"), M_TYPE_BOOLEAN, &bTrue);
  sValue = MIL_TEXT("PartCount");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ChunkSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ChunkEnable"), M_TYPE_BOOLEAN, &bTrue);
  sValue = MIL_TEXT("PartType");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ChunkSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ChunkEnable"), M_TYPE_BOOLEAN, &bTrue);

  // trigger configuration
  sValue = MIL_TEXT("RecordingStart");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerSelector"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("On");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerMode"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("Stage");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerSource"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("AcquisitionStart");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerSelector"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("Off");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerMode"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("FrameStart");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerSelector"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("On");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerMode"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("Software");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TriggerSource"), M_TYPE_STRING_PTR, sValue);
  // Hint: The TriggerSource also controls the TriggerSoftware feature.

  // encoder configuration
  sValue = MIL_TEXT("Camera");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("EncoderSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("EncoderInverter"), M_TYPE_BOOLEAN, &bTrue);

  // motion and position configuration
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ScanPosition"), M_TYPE_DOUBLE, &scanPosition);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ScanRange"), M_TYPE_DOUBLE, &scanRange);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ScanSpeed"), M_TYPE_DOUBLE, &scanSpeed);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("GeneralSpeed"), M_TYPE_DOUBLE, &generalSpeed);

  sValue = MIL_TEXT("Down");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ScanMode"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_EXECUTE, MIL_TEXT("StageInit"), M_DEFAULT, M_NULL);

  // additional camera and processing configuration
  sValue = MIL_TEXT("AcceleratedCenterOfMassIQCorrection");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("Scan3dExtractionMethod"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("zTags");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("Scan3dScalingMethod"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("um");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("Scan3dDistanceUnit"), M_TYPE_STRING_PTR, sValue);

  dValue = 4.0;
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("TargetVerticalSpacing"), M_TYPE_DOUBLE, &dValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ExposureRatio"), M_TYPE_DOUBLE, &exposureRatio);

  sValue = MIL_TEXT("AverageLastFrames");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("FPNCorrection"), M_TYPE_STRING_PTR, sValue);
  i64Value = 8;
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("FPNCorrectionNFrames"), M_TYPE_INT64, &i64Value);
  i64Value = 7;
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("ExtSimpMaxHWin"), M_TYPE_INT64, &i64Value);

  // illumination control (D3)
  sValue = MIL_TEXT("LightController0");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("LightControllerSelector"), M_TYPE_STRING_PTR, sValue);
  sValue = MIL_TEXT("UserOutput0");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("LightControllerSource"), M_TYPE_STRING_PTR, sValue);
  dValue = 100.0;
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("LightBrightness"), M_TYPE_DOUBLE, &dValue);
  // illumination control (D2)
  // LineSelector = Line2
  // LineSource = UserOutput0
  // LineInverter = true
  // switch on the illumination (D2/D3)
  sValue = MIL_TEXT("UserOutput0");
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("UserOutputSelector"), M_TYPE_STRING_PTR, sValue);
  MdigControlFeature(Device.MilDigitizer, M_FEATURE_VALUE, MIL_TEXT("UserOutputValue"), M_TYPE_BOOLEAN, &bTrue);
}

/* enable components */
void AllocateDisplay(GenTLDevice& Device)
{
  /* allocate memory for visualization of 2 components (surface and amplitude) */
  MIL_INT SizeX;
  MIL_INT SizeY;
  MdigInquire(Device.MilDigitizer, M_SIZE_X, &SizeX);
  MdigInquire(Device.MilDigitizer, M_SIZE_Y, &SizeY);

  /* initialize displays and allocate some default buffer */
  for (int i = 0; i < NOF_MIL_DISPLAY; i++)
  {
    MdispAlloc(Device.MilSystem, M_DEFAULT, MIL_TEXT("M_DEFAULT"), M_DEFAULT, &Device.MilDisplay[i]);

    milstring mTitle;
    switch (i) {
    case 0:
      mTitle = MIL_TEXT("Surface");
      break;
    case 1:
      mTitle = MIL_TEXT("Amplitude");
      break;
    default:
      mTitle = MIL_TEXT("---");
      break;
    }

#if (MIL_COMPILE_VERSION >= 1030)
    MdispControl(Device.MilDisplay[i], M_TITLE, mTitle);
#else
    MdispControl(Device.MilDisplay[i], M_TITLE, M_PTR_TO_DOUBLE(title.c_str()));
#endif

    MdispControl(Device.MilDisplay[i], M_VIEW_MODE, M_AUTO_SCALE);
    /* preallocate a image buffer for each display. */
    MbufAlloc2d(Device.MilSystem, SizeX, SizeY, 16 + M_UNSIGNED, M_IMAGE + M_DISP + M_PROC, &Device.MilImageDisp[i]);
    MbufClear(Device.MilImageDisp[i], M_COLOR_BLACK);
    MdispSelect(Device.MilDisplay[i], Device.MilImageDisp[i]);
  }
}


/* rescale the MilImageDisp[#] buffer to the size of the component. */
void rescaleDisplay(GenTLDevice& Device, MIL_ID component, int dispIdx)
{
  /* read component size */
  MIL_INT xSizeComponent = 0;
  MbufInquire(component, M_SIZE_X, &xSizeComponent);
  MIL_INT ySizeComponent = 0;
  MbufInquire(component, M_SIZE_Y, &ySizeComponent);
  MIL_INT typeComponent = 0;
  //MdigInquire(component, M_TYPE, &typeComponent);
  MdigInquire(Device.MilDigitizer, M_TYPE, &typeComponent);
  MIL_INT bitSizeComponent = 0;
  MbufInquire(component, M_SIZE_BIT, &bitSizeComponent);
  printf("xSize: %d, ySize: %d, type: %d, bitSize: %d\n", (int)xSizeComponent, (int)ySizeComponent, (int)typeComponent, (int)bitSizeComponent);

  /* read current MilImageDisp[#] size */
  MIL_INT xSizeImgDisp = 0;
  MbufInquire(Device.MilImageDisp[dispIdx], M_SIZE_X, &xSizeImgDisp);
  MIL_INT ySizeImgDisp = 0;
  MbufInquire(Device.MilImageDisp[dispIdx], M_SIZE_Y, &ySizeImgDisp);
  MIL_INT typeImgDisp = typeComponent;
  //MdigInquire(Device.MilImageDisp[dispIdx], M_TYPE, &typeImgDisp);

  /* if the size not equal, reallocate the buffer */
  if ((xSizeComponent != xSizeImgDisp) || (ySizeComponent != ySizeImgDisp) || (typeComponent != typeImgDisp)) {
    // resize buffer
    MbufFree(Device.MilImageDisp[dispIdx]);
    MbufAlloc2d(Device.MilSystem, xSizeComponent, ySizeComponent, typeComponent, M_IMAGE + M_DISP + M_PROC, &Device.MilImageDisp[dispIdx]);
    MbufClear(Device.MilImageDisp[dispIdx], M_COLOR_BLACK);
    MdispSelect(Device.MilDisplay[dispIdx], Device.MilImageDisp[dispIdx]);
  }
}

/* Used to stop acquisition and free device resources. */
void FreeGenTLDevice(GenTLDevice& Device)
{
  if (Device.MilDigitizer) {
    MdigHalt(Device.MilDigitizer);
    
    for (int i = 0; i < NOF_MIL_DISPLAY; i++) {
      MdispFree(Device.MilDisplay[i]);
      MbufFree(Device.MilImageDisp[i]);
    }

    for (int i = 0; i < NOF_MIL_CONTAINERS; i++) {
      MbufFree(Device.MilContainers[i]);
    }

    MdigFree(Device.MilDigitizer);
  }
}

