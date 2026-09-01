/*  \file     C4FeatureInfoCLR.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4FEATUREINFOCLR
#define INC_C4FEATUREINFOCLR

#pragma unmanaged
#include "C4FeatureInfo.hpp"
#pragma managed

namespace heliotis {

public enum class Type_e : int64_t { 
  UNKNOWN = 0, 
  INTEGER = 1, 
  FLOAT = 2, 
  STRING = 3, 
  ENUMERATION = 4, 
  COMMAND = 5, 
  BOOLEAN = 6
};
public enum class Visibility_e : int64_t {
  UNKNOWN = 0,
  BEGINNER = 1,
  EXPERT = 2,
  GURU = 3,
  INVISIBLE = 4
};
public enum class AccessMode_e : int64_t {
  UNKNOWN = 0,
  NI = 1,
  NA = 2, 
  RO = 3, 
  WO = 4, 
  RW = 5
};

public ref class C4FeatureInfoCLR {
private:
  C4FeatureInfo* c4featureInfo;
public:
  // enum
  //enum class Type_e { UNKNOWN, INTEGER, FLOAT, STRING, ENUMERATION, COMMAND, BOOLEAN };

  // ctor
  C4FeatureInfoCLR(C4FeatureInfo* c4fi);
  // dtor
  ~C4FeatureInfoCLR();

  heliotis::Type_e getType();
  System::String^ getName();
  System::String^ getCategory();

  System::String^ getDescription();

  heliotis::Visibility_e getVisibility();
  heliotis::AccessMode_e getAccessMode();

  int64_t getIntMin();
  int64_t getIntMax();
  int64_t getIntInc();

  double getFloatMin();
  double getFloatMax();
  double getFloatInc();

  array<System::String^>^ getEnumEntryList();
  array<System::String^>^ getInvalidatorList();
  array<System::String^>^ getSelectedList();

  int64_t readInteger();
  void writeInteger(int64_t value);
  double readFloat();
  void writeFloat(double value);
  System::String^ readString();
  void writeString(System::String^ value);
  void executeCommand();
};

} /* namespace heliotis */

#endif
