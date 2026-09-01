/**
* \file        h8SurfSimpl.cpp
* \author      Silvan Murer
* \date        7 April 2021
* \copyright   Heliotis, 2021
*
* \brief Simple C example based on C4HdlC for heliInspect H8
*/
#include "C4HdlC.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * helper macro to check C function return values
 */
#define C_RETURN_CHECK(RETURN_VALUE, ERROR_MESSAGE)     \
if (RETURN_VALUE != C4HDL_ERR_SUCCESS) {   \
  printf(ERROR_MESSAGE);        \
  printf(C4Hdl_getLastError()); \
  return RETURN_VALUE;          \
}

#define C_RETURN_CHECK_AND_RELEASE(RETURN_VALUE, ERROR_MESSAGE)     \
if (RETURN_VALUE != C4HDL_ERR_SUCCESS) {   \
  printf(ERROR_MESSAGE);  \
  printf(C4Hdl_getLastError()); \
  if (c4dev != NULL) {    \
    C4Dev_release(c4dev); \
  } \
  if (c4if != NULL) {     \
    C4If_release(c4if);   \
  } \
  if (c4hdl != NULL) {    \
    C4Hdl_close(c4hdl);   \
  } \
  return RETURN_VALUE;    \
} 

/**
 * \brief  Scan for available interfaces and print interface list
 *         let the user select one and open the interface
 *
 * \param[in]     c4hdl  system object of C4HdlC library
 * \param[out]    selIf  pointer filled by function containing selected interface index
 *
 * \return C4HDL_ERROR error code
 */
C4HDL_ERROR selectInterface(C4_HANDLER c4hdl, int* selIf)
{
  C4HDL_ERROR err; /**< error handling */
  char cStr[1024];  /**< preallocated string buffer */
  size_t cStrSize = sizeof(cStr); /**< string buffer size */
  *selIf = -1;

  printf("Interfaces: \n");
  int64_t nofIf;
  err = C4Hdl_updateInterfaceList(c4hdl, &nofIf);
  C_RETURN_CHECK(err, "Failed to update interface list");
  if (nofIf == 0) {
    C_RETURN_CHECK(C4HDL_ERR_ERROR, "No interface detected!");
  }

  for (int64_t i = 0; i < nofIf; i++) {
    cStrSize = sizeof(cStr);
    err = C4Hdl_getInterfaceName(c4hdl, i, cStr, &cStrSize);
    C_RETURN_CHECK(err, "Failed to read interface name");
    printf("%lld: %s\n", (i + 1), cStr);
  }
  printf("Select a interfaces (exit with any other value)\n");
  /* wait for user input */
  char str[10];
  fgets(str, sizeof(str), stdin);
  int selection = atoi(str);
  selection--;

  if (selection < 0 || selection >= nofIf) {
    C_RETURN_CHECK(C4HDL_ERR_ERROR, "User Selection is not a valid interface!");
  }
  *selIf = selection;
  return C4HDL_ERR_SUCCESS;
}

/**
 * \brief  Scan for available devices and print device list
 *         let the user select one and open the connection to the device
 *
 * \param[in]   c4if  interface object of C4HdlC library
 * \param[out]  selDev  pointer filled by function containing selected device index
 *
 * \return C4HDL_ERROR error code
 */
C4HDL_ERROR selectDevice(C4_INTERFACE c4if, int* selDev)
{
  C4HDL_ERROR err; /**< error handling */
  char cStr[1024];  /**< preallocated string buffer */
  size_t cStrSize = sizeof(cStr); /**< string buffer size */

  *selDev = 0;

  printf("Devices: \n");
  int64_t nofDev;
  err = C4If_updateDeciveList(c4if, &nofDev);
  C_RETURN_CHECK(err, "Failed to update interface list");

  if (nofDev == 0) {
    C_RETURN_CHECK(C4HDL_ERR_ERROR, "No device detected!");
  }

  for (int64_t i = 0; i < nofDev; i++) {
    cStrSize = sizeof(cStr);
    err = C4If_getDeviceName(c4if, i, cStr, &cStrSize);
    C_RETURN_CHECK(err, "Failed to read device name");
    printf("%lld: %s\n", (i + 1), cStr);
  }
  printf("Select a device (exit with any other value)\n");
  /* wait for user input */
  char str[10];
  fgets(str, sizeof(str), stdin);
  int selection = atoi(str);
  selection--;

  if (selection < 0 || selection >= nofDev) {
    C_RETURN_CHECK(C4HDL_ERR_ERROR, "User Selection is not a valid device!");
  }
  *selDev = selection;
  return C4HDL_ERR_SUCCESS;
}

/**
 * \brief simple configuration example of heliInspect H8 using internal motion control
 *
 * \param[in]   c4dev  reference to a device object.
 */
C4HDL_ERROR initializeDevice(C4_DEVICE c4dev)
{
  C4HDL_ERROR err = 0; /**< simple error handling */
  // Motion parameters in [mm] or [mm/s]
  double scanPosition = -1.4;
  double scanRange = 0.5;
  double scanSpeed = 5.0;
  double generalSpeed = 10.0;
  // exposure ration between 0.0 and 1.0 [1.0 = 100% exposure]
  double exposureRatio = 1.0;

  // enable required components
  err += C4Dev_writeString(c4dev, "ComponentSelector", "Intensity");
  err += C4Dev_writeInteger(c4dev, "ComponentEnable", 0);
  err += C4Dev_writeString(c4dev, "ComponentSelector", "Range");
  err += C4Dev_writeInteger(c4dev, "ComponentEnable", 1);
  err += C4Dev_writeString(c4dev, "ComponentSelector", "Reflectance");
  err += C4Dev_writeInteger(c4dev, "ComponentEnable", 1);
  err += C4Dev_writeString(c4dev, "ComponentSelector", "Phase");
  err += C4Dev_writeInteger(c4dev, "ComponentEnable", 0);

  // enable required chunk data (optional)
  err += C4Dev_writeInteger(c4dev, "ChunkModeActive", 1);
  err += C4Dev_writeString(c4dev, "ChunkSelector", "PartCount");
  err += C4Dev_writeInteger(c4dev, "ChunkEnable", 1);
  err += C4Dev_writeString(c4dev, "ChunkSelector", "PartType");
  err += C4Dev_writeInteger(c4dev, "ChunkEnable", 1);

  // trigger configuration
  err += C4Dev_writeString(c4dev, "TriggerSelector", "RecordingStart");
  err += C4Dev_writeString(c4dev, "TriggerMode", "On");
  err += C4Dev_writeString(c4dev, "TriggerSource", "Stage");
  err += C4Dev_writeString(c4dev, "TriggerSelector", "AcquisitionStart");
  err += C4Dev_writeString(c4dev, "TriggerMode", "Off");
  err += C4Dev_writeString(c4dev, "TriggerSelector", "FrameStart");
  err += C4Dev_writeString(c4dev, "TriggerMode", "On");
  err += C4Dev_writeString(c4dev, "TriggerSource", "Software");
  // Hint: The TriggerSource also controls the TriggerSoftware feature.

  // encoder configuration
  err += C4Dev_writeString(c4dev, "EncoderSelector", "Camera");
  err += C4Dev_writeInteger(c4dev, "EncoderInverter", 1);

  // motion and position configuration
  err += C4Dev_writeFloat(c4dev, "ScanPosition", scanPosition);
  err += C4Dev_writeFloat(c4dev, "ScanRange", scanRange);
  err += C4Dev_writeFloat(c4dev, "ScanSpeed", scanSpeed);
  err += C4Dev_writeFloat(c4dev, "GeneralSpeed", generalSpeed);

  err += C4Dev_writeString(c4dev, "ScanMode", "Down");
  err += C4Dev_executeCommand(c4dev, "StageInit");

  // additional camera and processing configuration
  err += C4Dev_writeString(c4dev, "Scan3dExtractionMethod", "AcceleratedCenterOfMassIQCorrection");
  err += C4Dev_writeString(c4dev, "Scan3dScalingMethod", "zTags");
  err += C4Dev_writeString(c4dev, "Scan3dDistanceUnit", "um");

  err += C4Dev_writeFloat(c4dev, "TargetVerticalSpacing", 2.5);
  err += C4Dev_writeFloat(c4dev, "ExposureRatio", exposureRatio);

  err += C4Dev_writeString(c4dev, "FPNCorrection", "AverageLastFrames");
  err += C4Dev_writeInteger(c4dev, "FPNCorrectionNFrames", 8);
  err += C4Dev_writeInteger(c4dev, "ExtSimpMaxHWin", 7);

  // illumination control (D3)
  err += C4Dev_writeString(c4dev, "LightControllerSelector", "LightController0");
  err += C4Dev_writeString(c4dev, "LightControllerSource", "UserOutput0");
  err += C4Dev_writeFloat(c4dev, "LightBrightness", 100.0);
  // illumination control (D2)
  // LineSelector = Line2
  // LineSource = UserOutput0
  // LineInverter = true
  // switch on the illumination (D2/D3)
  err += C4Dev_writeString(c4dev, "UserOutputSelector", "UserOutput0");
  err += C4Dev_writeInteger(c4dev, "UserOutputValue", 1);

  return C4HDL_ERR_SUCCESS;
}


/**
 * \brief main function of the application
 *
 * \param[in]       argc     arguments are not used by this application
 * \param[in]       *argv[]  arguments are not used by this application
 *
 * \return application error code
 */
int main(int argc, char *argv[]) {
  printf("********************************************************\n");
  printf("* Configure and acquire data in '3D surface mode'\n");
  printf("********************************************************\n");

  // variable definitions 
  C4HDL_ERROR err; /**< error handling */
  char cStr[1024];  /**< preallocated string buffer */
  size_t cStrSize = sizeof(cStr); /**< string buffer size */
  
  C4_HANDLER c4hdl = NULL;  /**< system handle */
  C4_INTERFACE c4if = NULL; /**< interface handle */
  C4_DEVICE c4dev = NULL;   /**< device handle */
  C4_BUFFER c4buf0 = NULL;  /**< buffer handle */

  err = C4Hdl_open(&c4hdl);
  C_RETURN_CHECK_AND_RELEASE(err, "Failed to open C4Hdl");
  // Select and open Interface
  int ifNo = -1;
  err = selectInterface(c4hdl, &ifNo);
  C_RETURN_CHECK_AND_RELEASE(err, "Interface selection failed!");
  err = C4Hdl_openInterface(c4hdl, &c4if, ifNo);
  C_RETURN_CHECK_AND_RELEASE(err, "Failed to open interface");
  // Select and open Device
  int devNo = -1;
  err = selectDevice(c4if, &devNo);
  C_RETURN_CHECK_AND_RELEASE(err, "Device selection failed!");
  err = C4If_openDevice(c4if, &c4dev, devNo);
  C_RETURN_CHECK_AND_RELEASE(err, "Failed to open device");

  // Initialize device
  err = initializeDevice(c4dev);
  C_RETURN_CHECK_AND_RELEASE(err, "Device initialization failed!");

  // start acquisition
  err = C4Dev_startAcquisition(c4dev, 4);
  C_RETURN_CHECK_AND_RELEASE(err, "Could not switch to acquisition mode!");

  // measurement loop (10 iterations)
  for (int i = 0; i < 10; i++) {
    err = C4Dev_executeCommand(c4dev, "TriggerSoftware");
    C_RETURN_CHECK_AND_RELEASE(err, "Failed to execute software trigger!");

    err = C4Dev_getBuffer(c4dev, &c4buf0, 10000);
    C_RETURN_CHECK_AND_RELEASE(err, "Failed to acquire a buffer containing the measurement data!");

    err = C4Buf_release(c4buf0);
    C_RETURN_CHECK_AND_RELEASE(err, "Could not release buffer!");
    c4buf0 = NULL;

    printf("iteration %d done!\n", i);
  }

  err = C4Dev_stopAcquisition(c4dev);
  C_RETURN_CHECK_AND_RELEASE(err, "Could not stop acquisition mode!");

  err = C4Dev_release(c4dev);
  c4dev = NULL;
  C_RETURN_CHECK_AND_RELEASE(err, "Could not release device!");
  err = C4If_release(c4if);
  c4if = NULL;
  C_RETURN_CHECK_AND_RELEASE(err, "Could not release interface!");
  err = C4Hdl_close(c4hdl);
  c4hdl = NULL;
  C_RETURN_CHECK_AND_RELEASE(err, "Could not release handle!");
  return 0;
}
