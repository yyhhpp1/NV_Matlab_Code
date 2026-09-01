/*  \file     C4Handler.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4HANDLER
#define INC_C4HANDLER

#include "C4HdlDef.hpp"
#include "C4Interface.hpp"

#include <stdint.h>
#include <string>

namespace heliotis {

/**
* Core class to the C4 camera
*
* This class is the starting point for the access of a C4 camera.
* It scans for interfaces and create C4Interface objects.
*/
class C4LIB_API C4Handler {
private:
  void* c4SystemComponent; /**< pointer to internal data */

public:
  /**
   * \brief default constructor used to create C4Handler object
   */
  C4Handler();
  /**
   * \brief destructor used to destroy/release the C4Handler object
   */
  ~C4Handler();

  /**
   * \brief function to reset the whole system
   *
   * A call to this function release all allocated memory and release all open connections.
   */
  void reset();


  /**
   * \brief read the version of the C4Hdl library
   *
   * \return a string value including the version information
   */
  std::string getC4HdlVersion();
  /**
   * \brief read the version of the used GenTL producer (diaphus)
   *
   * \return a string value including the version information
   */
  std::string getDiaphusVersion();
  /**
   * \brief read the file location of the used GenTL producer (diaphus)
   *
   * \return string value including the path of the used diaphus
   */
  std::string getDiaphusLocation();


  /**
   * \brief scan for available interfaces
   *
   * The C4 cameras are connected through ethernet interfaces.
   * This function scan for available ethernet interfaces.
   *
   * \return the number of available interfaces
   */
  int64_t updateInterfaceList();

  /**
   * \brief get the name of an interface
   *
   * The interface meta information are availabe after a updateInterfaceList call.
   *
   * \param[in]     ifNo    zero based index to the interface
   *
   * \return a string containing the interface name
   */
  std::string getInterfaceName(int64_t ifNo);

  /**
   * \brief open an interface
   *
   * Open a interface connection. Interface configuration and device instantiation are done through the returned C4Interface object.
   *
   * \param[in]     ifNo    zero based index to the interface
   *
   * \return C4Interface object
   */
  C4Interface openInterface(int64_t ifNo);
};

} /* namespace heliotis */

#endif
