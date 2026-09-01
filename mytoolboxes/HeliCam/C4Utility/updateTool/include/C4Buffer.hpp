/*  \file     C4Buffer.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4BUFFER
#define INC_C4BUFFER

#include "C4HdlDef.hpp"
#include "C4FeatureInfo.hpp"

#include <stdint.h>
#include <string>
#include <vector>

namespace heliotis {

class BufferComponent;

/**
* Class to the C4Buffer
*
* This class is returned by the C4Device and get access to the measurement data.
*/
class C4LIB_API C4Buffer {
private:
  BufferComponent* c4BufferComponent; /**< pointer to internal data */
  /**
   * \brief no default constructor is available for this class
   */
  C4Buffer();

public:
  /**
   * \brief constructor
   *
   * Don't create a C4Interface by self. Use the C4Handler::openInterface function!
   */
  C4Buffer(void* bufH, void* devH, void* c4ActiveBufH);

  /**
   * \brief copy constructor
   */
  C4Buffer(const C4Buffer& other);
  /**
   * \brief copy assignment not supported by this class
   */
  C4Buffer& operator=(const C4Buffer& other) = delete;

  /**
   * \brief move constructor
   */
  C4Buffer(C4Buffer && other);
  /**
   * \brief move assignment not supported by this class
   */
  C4Buffer& operator=(C4Buffer && other) = delete;

  /**
   * \brief destructor
   */
  ~C4Buffer();

  /**
   * \brief function to release a buffer.
   *
   * A call to this function release all allocated memory and return the buffer to the device for a next acquisition.
   */
  void release();

  /**
  * \brief get a list with all available buffer features
  *
  * \return a vector containing C4FeatureInfo objects
  */
  std::vector<C4FeatureInfo> getFeatureList();
  /**
   * \brief get the type of a specific feature
   *
   * \return the type of a specific feature
   */
  C4FeatureInfo::Type_e getFeatureType(std::string name);

  /* buffer feature access (chunk data) */
  /**
   * \brief get value of an integer feature
   *
   * \param[in]     name    feature name
   *
   * \return integer feature value
   */
  int64_t readInteger(std::string name);
  /**
   * \brief set value of an integer feature
   *
   * \param[in]     name    feature name
   * \param[in]     value   new feature value
   */
  void writeInteger(std::string name, int64_t value);

  /**
   * \brief get value of an float feature
   *
   * \param[in]     name    feature name
   *
   * \return float feature value
   */
  double readFloat(std::string name);
  /**
   * \brief set value of an float feature
   *
   * \param[in]     name    feature name
   * \param[in]     value   new feature value
   */
  void writeFloat(std::string name, double value);

  /**
   * \brief get value of an string feature
   *
   * \param[in]     name    feature name
   *
   * \return string feature value
   */
  std::string readString(std::string name);
  /**
   * \brief set value of an string feature
   *
   * \param[in]     name    feature name
   * \param[in]     value   new feature value
   */
  void writeString(std::string name, std::string value);

  /**
   * \brief get value of an enumeration feature
   *
   * \param[in]     name    feature name
   *
   * \return enumeration feature value as string
   */
  std::string readEnumeration(std::string name);
  /**
   * \brief set value of an enumeration feature
   *
   * \param[in]     name    feature name
   * \param[in]     value   new feature value
   */
  void writeEnumeration(std::string name, std::string value);

  /* buffer data access */
  /**
   * \brief get the number of data parts included in this buffer
   *
   * \return number of data parts
   */
  int64_t getNumParts();

  /**
   * \brief get the pixelformat of a buffer part
   *
   * \param[in]     partIdx    zero based part index
   *
   * \return buffer part pixelformat as defined in GenICam PFNC
   */
  int64_t getPartPixelformat(int64_t partIdx);
  /**
   * \brief translate the GenICam PFNC pixelformat value to a string
   *
   * \param[in]     pixelformat    GenICam PFNC pixelformat value (integer)
   *
   * \return string with the name of the given pixelformat value
   */
  std::string getPixelformatName(int64_t pixelformat);

  /**
   * \brief get a buffer part as uint16 type
   *
   * \attention This function is obsolete and not included in future releases. It would be replaced by a function "getSurface" which dosn't require a partIndex.
   *
   * \param[in]     partIdx    zero based part index
   *
   * \return uint16 vector containing the selected part
   */
  std::vector<uint16_t> getDataPartUint16(int64_t partIdx);
  /**
   * \brief get a buffer part as double type
   *
   * \attention This function is obsolete and not included in future releases. It would be replaced by a function "getAmplitude" which dosn't require a partIndex.
   *
   * \param[in]     partIdx    zero based part index
   *
   * \return double vector containing the selected part
   */
  std::vector<double> getDataPartFloat(int64_t partIdx);
  /**
   * \brief get the dimension of the data
   *
   * The returned vector contains the dimension/size of the data returned by C4Buffer::getDataPartUint16 or C4Buffer::getDataPartFloat 
   * The order of the returned dimesion is: [0]:Width (X), [1]:Height(Y)
   *
   * \param[in]     partIdx    zero based part index
   *
   * \return vector containing the dimesion of the selected part
   */
  std::vector<int64_t> getPartDimension(int64_t partIdx);

};

} /* namespace heliotis */

#endif
