/*  \file     C4HandlerCLR.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4HANDLERCLR
#define INC_C4HANDLERCLR

#pragma unmanaged
#include "C4Handler.hpp"
#pragma managed
#include "C4InterfaceCLR.hpp"

namespace heliotis {

public ref class C4HandlerCLR {
private:
  C4Handler* c4Handler;

public:
  // ctor, dtor
  C4HandlerCLR();
  ~C4HandlerCLR();

  void reset();

  System::String^ getC4HdlVersion();
  System::String^ getDiaphusVersion();
  System::String^ getDiaphusLocation();

  int64_t updateInterfaceList();

  System::String^ getInterfaceName(int64_t ifNo);

  C4InterfaceCLR^ openInterface(int64_t ifNo);
};

} /* namespace heliotis */

#endif
