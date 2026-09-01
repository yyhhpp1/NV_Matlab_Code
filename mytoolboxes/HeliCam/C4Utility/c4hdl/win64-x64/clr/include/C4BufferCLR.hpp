/*  \file     C4BufferCLR.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4BUFFERCLR
#define INC_C4BUFFERCLR

#pragma unmanaged
#include "C4Buffer.hpp"
#pragma managed
#include "C4FeatureInfoCLR.hpp"

namespace heliotis {

public ref class C4BufferCLR {
private:
  C4Buffer* c4buffer;

public:
  // ctor
  C4BufferCLR(C4Buffer* c4buf);
  // dtor
  ~C4BufferCLR();

  void release();

  array<C4FeatureInfoCLR^>^ getFeatureList();
  heliotis::Type_e getFeatureType(System::String^ name);

  /* buffer feature access (chunk data) */
  int64_t readInteger(System::String^ name);
  void writeInteger(System::String^ name, int64_t value);

  double readFloat(System::String^ name);
  void writeFloat(System::String^ name, double value);

  System::String^ readString(System::String^ name);
  void writeString(System::String^ name, System::String^ value);

  System::String^ readEnumeration(System::String^ name);
  void writeEnumeration(System::String^ name, System::String^ value);

  /* buffer data access */
  int64_t getNumParts();
  int64_t getPartPixelformat(int64_t partIdx);
  System::String^ getPixelformatName(int64_t pixelformat);

  array<uint16_t>^ getDataPartUint16(int64_t partIdx);
  array<double>^ getDataPartFloat(int64_t partIdx);
  array<int64_t>^ getPartDimension(int64_t partIdx);
};

} /* namespace heliotis */

#endif
