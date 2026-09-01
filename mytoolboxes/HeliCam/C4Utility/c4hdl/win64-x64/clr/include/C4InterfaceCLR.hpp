/*  \file     C4InterfaceCLR.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4INTERFACECLR
#define INC_C4INTERFACECLR

#pragma unmanaged
#include "C4Interface.hpp"
#pragma managed
#include "C4DeviceCLR.hpp"
#include "C4FeatureInfoCLR.hpp"

namespace heliotis {

public ref class C4InterfaceCLR {
private:
  C4Interface* c4interface;
  //C4InterfaceCLR(void* ifH, void* managerH);
  

public:
  C4InterfaceCLR(C4Interface* c4if);
  // dtor
  ~C4InterfaceCLR();

  void release();
  System::String^ getInterfaceName();

  array<C4FeatureInfoCLR^>^ getFeatureList();
  //C4FeatureInfo::Type_e getFeatureType(std::string name);

  int64_t updateDeviceList();
  System::String^ getDeviceName(int64_t devNo);
  C4DeviceCLR^ openDevice(int64_t devNo);
};

} /* namespace heliotis */

#endif
