/*  \file     C4HdlC.h
 *  \brief    C wrapper of C4Hdl Library for access to heliotis GenICam based camera C4
 *  \version  1.0.0
 *  \author   Silvan Murer, heliotis
 *  \date     2020
 */
 
#ifndef __C4HDLC_H
#define __C4HDLC_H

#include <stdint.h> /* int#_t uint#_t */
#include <stddef.h>

struct _C4Handler_Hdl; //forward declaration
typedef struct _C4Handler_Hdl* C4_HANDLER; /**< C handler to C4Handler class */
struct _C4Interface_Hdl; //forward declaration
typedef struct _C4Interface_Hdl* C4_INTERFACE; /**< C handler to C4Interface class */
struct _C4Device_Hdl; //forward declaration
typedef struct _C4Device_Hdl* C4_DEVICE; /**< C handler to C4Device class */
struct _C4Buffer_Hdl; //forward declaration
typedef struct _C4Buffer_Hdl* C4_BUFFER; /**< C handler to C4Buffer class */
struct _C4FeatureInfo_Hdl; //forward declaration
typedef struct _C4FeatureInfo_Hdl* C4_FEATUREINFO; /**< C handler to C4FeatureInfo class */

#ifdef __cplusplus
extern "C" {
#endif

#if defined(SWIG) // SWIG
#  define C4CLIB_API 
#elif defined(_WIN32) // windows
#if defined(MAKESHAREDLIB)
#  define C4CLIB_API __declspec(dllexport)
#else
#  define C4CLIB_API __declspec(dllimport)
#endif
#else // Linux
#  define C4CLIB_API __attribute__ ((visibility("default"))) 
#endif

/* Errors */
enum C4HDL_ERROR_LIST
{
  C4HDL_ERR_SUCCESS = 0,          /**< operation successful, no erro*/
  C4HDL_ERR_ERROR = -100,         /**< error, read last error for additional information */
  C4HDL_ERR_INV_HDL = -101,       /**< invalide object handle */
  C4HDL_ERR_SMALL_BUFFER = -102   /**< given data buffer is to small - required size is written in bufferSize parameter of the calling function */
};
typedef int32_t C4HDL_ERROR;

enum _Type_e { C4FTR_TYPE_UNKNOWN, C4FTR_TYPE_INTEGER, C4FTR_TYPE_FLOAT, C4FTR_TYPE_STRING, C4FTR_TYPE_ENUMERATION, C4FTR_TYPE_COMMAND, C4FTR_TYPE_BOOLEAN }; /**< enumeration of feature types */
typedef enum _Type_e Type_e;
enum _Visibility_e { C4FTR_VISIBILITY_UNKNOWN, C4FTR_VISIBILITY_BEGINNER, C4FTR_VISIBILITY_EXPERT, C4FTR_VISIBILITY_GURU, C4FTR_VISIBILITY_INVISIBLE }; /**< enumeration of visibility types */
typedef enum _Visibility_e Visibility_e;
enum _AccessMode_e { C4FTR_ACCESSMODE_UNKNOWN, C4FTR_ACCESSMODE_NI, C4FTR_ACCESSMODE_NA, C4FTR_ACCESSMODE_RO, C4FTR_ACCESSMODE_WO, C4FTR_ACCESSMODE_RW }; /**< enumeration of access types */
typedef enum _AccessMode_e AccessMode_e;

/*
 * C API specific functions
 */
C4CLIB_API const char* C4Hdl_getLastError();

/*
 * C4Handler
 */
C4CLIB_API C4HDL_ERROR C4Hdl_open(C4_HANDLER* c4hdl);

C4CLIB_API C4HDL_ERROR C4Hdl_close(C4_HANDLER c4hdl);

C4CLIB_API C4HDL_ERROR C4Hdl_reset(const C4_HANDLER c4hdl);

C4CLIB_API C4HDL_ERROR C4Hdl_getC4HdlVersion(const C4_HANDLER c4hdl, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Hdl_getDiaphusVersion(const C4_HANDLER c4hdl, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Hdl_getDiaphusLocation(const C4_HANDLER c4hdl, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Hdl_updateInterfaceList(const C4_HANDLER c4hdl, int64_t* nofIf);

C4CLIB_API C4HDL_ERROR C4Hdl_getInterfaceName(const C4_HANDLER c4hdl, int64_t ifNo, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Hdl_openInterface(const C4_HANDLER c4hdl, C4_INTERFACE* c4if, int64_t ifNo);


/*
 * C4Interface
 */
C4CLIB_API C4HDL_ERROR C4If_release(C4_INTERFACE c4if);

C4CLIB_API C4HDL_ERROR C4If_getInterfaceName(const C4_INTERFACE c4if, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4If_getFeatureList(const C4_INTERFACE c4if, C4_FEATUREINFO** c4ftrList);

C4CLIB_API C4HDL_ERROR C4If_getFeatureType(const C4_INTERFACE c4if, const char* name, Type_e* type);

C4CLIB_API C4HDL_ERROR C4If_updateDeciveList(const C4_INTERFACE c4if, int64_t* nofDev);

C4CLIB_API C4HDL_ERROR C4If_getDeviceName(const C4_INTERFACE c4if, int64_t devNo, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4If_openDevice(const C4_INTERFACE c4if, C4_DEVICE* c4dev, int64_t devNo);


/*
 * C4Device
 */
C4CLIB_API C4HDL_ERROR C4Dev_release(C4_DEVICE c4dev);

C4CLIB_API C4HDL_ERROR C4Dev_getDeviceName(const C4_DEVICE c4dev, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Dev_getFeatureList(const C4_DEVICE c4dev, C4_FEATUREINFO** c4ftrList);

C4CLIB_API C4HDL_ERROR C4Dev_getFeatureType(const C4_DEVICE c4dev, const char* name, Type_e* type);

C4CLIB_API C4HDL_ERROR C4Dev_readInteger(const C4_DEVICE c4dev, const char* name, int64_t* value);

C4CLIB_API C4HDL_ERROR C4Dev_writeInteger(const C4_DEVICE c4dev, const char* name, int64_t value);

C4CLIB_API C4HDL_ERROR C4Dev_readFloat(const C4_DEVICE c4dev, const char* name, double* value);

C4CLIB_API C4HDL_ERROR C4Dev_writeFloat(const C4_DEVICE c4dev, const char* name, double value);

C4CLIB_API C4HDL_ERROR C4Dev_readString(const C4_DEVICE c4dev, const char* name, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Dev_writeString(const C4_DEVICE c4dev, const char* name, const char* value);

C4CLIB_API C4HDL_ERROR C4Dev_readEnumeration(const C4_DEVICE c4dev, const char* name, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Dev_writeEnumeration(const C4_DEVICE c4dev, const char* name, const char* value);

C4CLIB_API C4HDL_ERROR C4Dev_executeCommand(const C4_DEVICE c4dev, const char* name);

C4CLIB_API C4HDL_ERROR C4Dev_readFile(const C4_DEVICE c4dev, const char* fileSelector, const char* localFile);

C4CLIB_API C4HDL_ERROR C4Dev_writeFile(const C4_DEVICE c4dev, const char* fileSelector, const char* localFile);

C4CLIB_API C4HDL_ERROR C4Dev_startAcquisition(const C4_DEVICE c4dev, int64_t nofBuf);

C4CLIB_API C4HDL_ERROR C4Dev_stopAcquisition(const C4_DEVICE c4dev);

C4CLIB_API C4HDL_ERROR C4Dev_getBuffer(const C4_DEVICE c4dev, C4_BUFFER* c4buf, int64_t timeout_ms);

C4CLIB_API C4HDL_ERROR C4Dev_registerEvent(const C4_DEVICE c4dev, const char* name);

C4CLIB_API C4HDL_ERROR C4Dev_unregisterEvent(const C4_DEVICE c4dev, const char* name);
// semicolon ';' separated string
C4CLIB_API C4HDL_ERROR C4Dev_waitForEvents(const C4_DEVICE c4dev, char* buffer, size_t* bufferSize, int64_t timeout_ms);

/*
 * C4Buffer
 */
C4CLIB_API C4HDL_ERROR C4Buf_release(C4_BUFFER c4buf);

C4CLIB_API C4HDL_ERROR C4Buf_getFeatureList(const C4_BUFFER c4buf, C4_FEATUREINFO** c4ftrList);

C4CLIB_API C4HDL_ERROR C4Buf_getFeatureType(const C4_BUFFER c4buf, const char* name, Type_e* type);

C4CLIB_API C4HDL_ERROR C4Buf_readInteger(const C4_BUFFER c4buf, const char* name, int64_t* value);

C4CLIB_API C4HDL_ERROR C4Buf_writeInteger(const C4_BUFFER c4buf, const char* name, int64_t value);

C4CLIB_API C4HDL_ERROR C4Buf_readFloat(const C4_BUFFER c4buf, const char* name, double* value);

C4CLIB_API C4HDL_ERROR C4Buf_writeFloat(const C4_BUFFER c4buf, const char* name, double value);

C4CLIB_API C4HDL_ERROR C4Buf_readString(const C4_BUFFER c4buf, const char* name, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Buf_writeString(const C4_BUFFER c4buf, const char* name, const char* value);

C4CLIB_API C4HDL_ERROR C4Buf_readEnumeration(const C4_BUFFER c4buf, const char* name, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Buf_writeEnumeration(const C4_BUFFER c4buf, const char* name, const char* value);

C4CLIB_API C4HDL_ERROR C4Buf_getNumParts(const C4_BUFFER c4buf, int64_t* numParts);

C4CLIB_API C4HDL_ERROR C4Buf_getPartPixelformat(const C4_BUFFER c4buf, int64_t partIdx, int64_t* pixelformat);

C4CLIB_API C4HDL_ERROR C4Buf_getPixelformatName(const C4_BUFFER c4buf, int64_t pixelformat, char* buffer, size_t* bufferSize);

/*
 * 
 */
C4CLIB_API C4HDL_ERROR C4Buf_getDataPartUint16(const C4_BUFFER c4buf, int64_t partIdx, uint16_t* buffer, uint32_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Buf_getDataPartFloat(const C4_BUFFER c4buf, int64_t partIdx, double* buffer, uint32_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Buf_getPartDimension(const C4_BUFFER c4buf, int64_t partIdx, int64_t* buffer, uint32_t* bufferSize);


/*
 * C4FeatureInfo
 */
C4CLIB_API C4HDL_ERROR C4Ftr_release(C4_FEATUREINFO* c4ftrList);

C4CLIB_API C4HDL_ERROR C4Ftr_getType(const C4_FEATUREINFO c4ftr, Type_e* type);

C4CLIB_API C4HDL_ERROR C4Ftr_getName(const C4_FEATUREINFO c4ftr, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Ftr_getCategory(const C4_FEATUREINFO c4ftr, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Ftr_getDescription(const C4_FEATUREINFO c4ftr, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Ftr_getVisibility(const C4_FEATUREINFO c4ftr, Visibility_e* visibility);

C4CLIB_API C4HDL_ERROR C4Ftr_getAccessMode(const C4_FEATUREINFO c4ftr, AccessMode_e* accessMode);

C4CLIB_API C4HDL_ERROR C4Ftr_getIntMin(const C4_FEATUREINFO c4ftr, int64_t* value);

C4CLIB_API C4HDL_ERROR C4Ftr_getIntMax(const C4_FEATUREINFO c4ftr, int64_t* value);

C4CLIB_API C4HDL_ERROR C4Ftr_getIntInc(const C4_FEATUREINFO c4ftr, int64_t* value);

C4CLIB_API C4HDL_ERROR C4Ftr_getFloatMin(const C4_FEATUREINFO c4ftr, double* value);

C4CLIB_API C4HDL_ERROR C4Ftr_getFloatMax(const C4_FEATUREINFO c4ftr, double* value);

C4CLIB_API C4HDL_ERROR C4Ftr_getFloatInc(const C4_FEATUREINFO c4ftr, double* value);

// semicolon ';' separated string
C4CLIB_API C4HDL_ERROR C4Ftr_getEnumEntryList(const C4_FEATUREINFO c4ftr, char* buffer, size_t* bufferSize);
// semicolon ';' separated string
C4CLIB_API C4HDL_ERROR C4Ftr_getInvalidatorList(const C4_FEATUREINFO c4ftr, char* buffer, size_t* bufferSize);
// semicolon ';' separated string
C4CLIB_API C4HDL_ERROR C4Ftr_getSelectedList(const C4_FEATUREINFO c4ftr, char* buffer, size_t* bufferSize);

C4CLIB_API C4HDL_ERROR C4Ftr_readInteger(const C4_FEATUREINFO c4ftr, int64_t* value);
C4CLIB_API C4HDL_ERROR C4Ftr_writeInteger(const C4_FEATUREINFO c4ftr, int64_t value);
C4CLIB_API C4HDL_ERROR C4Ftr_readFloat(const C4_FEATUREINFO c4ftr, double* value);
C4CLIB_API C4HDL_ERROR C4Ftr_writeFloat(const C4_FEATUREINFO c4ftr, double value);
C4CLIB_API C4HDL_ERROR C4Ftr_readString(const C4_FEATUREINFO c4ftr, char* buffer, size_t* bufferSize);
C4CLIB_API C4HDL_ERROR C4Ftr_writeString(const C4_FEATUREINFO c4ftr, const char* value);
C4CLIB_API C4HDL_ERROR C4Ftr_executeCommand(const C4_FEATUREINFO c4ftr);

#ifdef __cplusplus
}
#endif

#endif /* header quard */
 
