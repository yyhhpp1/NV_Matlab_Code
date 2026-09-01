/*  \file     C4Interface.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4INTERFACE
#define INC_C4INTERFACE

#include "C4HdlDef.hpp"
#include "C4FeatureInfo.hpp"
#include "C4Device.hpp"

#include <stdint.h>
#include <string>
#include <vector>

namespace heliotis {

class InterfaceComponent;

/**
* Class to the C4Interface
*
* This class is used for interface access.
* It scans for devices and create C4Device objects.
*/
class C4LIB_API C4Interface {
private:
  InterfaceComponent* c4InterfaceComponent; /**< pointer to internal data */
  /**
   * \brief no default constructor is available for this class
   */
  C4Interface();

public:
  /**
   * \brief constructor
   *
   * Don't create a C4Interface by self. Use the C4Handler::openInterface function!
   */
  C4Interface(void* ifH, void* managerH);

  /**
   * \brief copy constructor
   */
  C4Interface(const C4Interface& other);
  /**
   * \brief copy assignment not supported by this class
   */
  C4Interface& operator=(const C4Interface& other) = delete; 

  /**
   * \brief move constructor
   */
  C4Interface(C4Interface && other);
  /**
   * \brief move assignment not supported by this class
   */
  C4Interface& operator=(C4Interface && other) = delete;

  /**
   * \brief destructor
   */
  ~C4Interface();

  /**
   * \brief function to release an interface.
   *
   * A call to this function release all allocated memory and release the interface including all open devices.
   */
  void release();
  /**
   * \brief read the interface name
   *
   * \return a string value including the interface name
   */
  std::string getInterfaceName();

  /**
   * \brief get a list with all available interface features 
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

  /* interface feature access */
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

  /**
   * \brief execute a command feature
   *
   * \param[in]     name    feature name
   */
  void executeCommand(std::string name);

  /**
   * \brief update the device list
   *
   * \return the number of available devices
   */
  int64_t updateDeviceList();
  /**
   * \brief get the name of a device
   *
   * The device meta information are availabe after a updateDeviceList call.
   *
   * \param[in]     devNo    zero based index to the device
   *
   * \return a string containing the device name
   */
  std::string getDeviceName(int64_t devNo);
  /**
   * \brief open a device
   *
   * Open a device connection. Device configuration and data acquisition are done through the returned C4Device object.
   *
   * \param[in]     devNo    zero based index to the device
   *
   * \return C4Device object
   */
  C4Device openDevice(int64_t devNo);
};

} /* namespace heliotis */

#endif
