/*  \file     C4DeviceCLR.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4DEVICECLR
#define INC_C4DEVICECLR

#pragma unmanaged
#include "C4Device.hpp"
#pragma managed
#include "C4BufferCLR.hpp"
#include "C4FeatureInfoCLR.hpp"

namespace heliotis {

public ref class C4DeviceCLR {
private:
  C4Device* c4device;

public:
  // ctor
  C4DeviceCLR(C4Device* c4dev);
  // dtor
  ~C4DeviceCLR();

  void release();
  System::String^ getDeviceName();

  array<C4FeatureInfoCLR^>^ getFeatureList();
  heliotis::Type_e getFeatureType(System::String^ name);

  /* device feature access */
  int64_t readInteger(System::String^ name);
  void writeInteger(System::String^ name, int64_t value);
  
  double readFloat(System::String^ name);
  void writeFloat(System::String^ name, double value);

  System::String^ readString(System::String^ name);
  void writeString(System::String^ name, System::String^ value);

  System::String^ readEnumeration(System::String^ name);
  void writeEnumeration(System::String^ name, System::String^ value);

  void executeCommand(System::String^ name);

  void readFile(System::String^ fileSelector, System::String^ localFile);
  void writeFile(System::String^ fileSelector, System::String^ localFile);

  /* device state configuration */
  void startAcquisition(int64_t nofBuf);
  void stopAcquisition();

  C4BufferCLR^ getBuffer(int64_t timeout_ms);

  /* event handling */
  void registerEvent(System::String^ name);
  void unregisterEvent(System::String^ name);
  array<System::String^>^ waitForEvents(int64_t timeout_ms);
};

} /* namespace heliotis */

#endif
