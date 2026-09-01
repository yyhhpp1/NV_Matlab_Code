#pragma once

#ifndef __GENTL_H__
#define __GENTL_H__

#include <mil.h>
#include <vector>
#include <map>

#define NOF_MIL_DISPLAY (2)
#define NOF_MIL_CONTAINERS (1)

/* Define a container class to hold MIL resources associated to a Device. */
class GenTLDevice
{
public:
	GenTLDevice()
	{
		MilSystem = M_NULL;
    for (int i=0; i < NOF_MIL_DISPLAY; i++) 
    {
      MilDisplay[i] = M_NULL;
      MilImageDisp[i] = M_NULL;
    }
    for (int i = 0; i < NOF_MIL_CONTAINERS; i++)
    {
      MilContainers[i] = M_NULL;
    }
		MilDigitizer = M_NULL;
		MilImage = M_NULL;
		Number = 0;
	}

	milstring Vendor;
	milstring Model;
	milstring TLType;
  milstring SerialNo;
  milstring DeviceID;
	MIL_INT Number;
	MIL_ID MilSystem;
	MIL_ID MilDisplay[NOF_MIL_DISPLAY];
  MIL_ID MilImageDisp[NOF_MIL_DISPLAY];
  MIL_ID MilContainers[NOF_MIL_CONTAINERS];
	MIL_ID MilDigitizer;
	MIL_ID MilImage;
};

/**/
#define MAX_SYSTEMS    16



#endif