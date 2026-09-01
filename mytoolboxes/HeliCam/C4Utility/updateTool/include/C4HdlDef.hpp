/*  \file     C4HdlDef.hpp
 *  \brief    Defines of macros used by C4Hdl library
 *  \version  1.0.0
 *  \author   Silvan Murer, heliotis
 *  \date     2020
 */

#ifndef INC_C4HDLDEF
#define INC_C4HDLDEF

#if defined(SWIG) || defined(MAKESTATICLIB) // SWIG
#  define C4LIB_API 
#elif defined(_WIN32) // Windows
#if defined(MAKESHAREDLIB)
#  define C4LIB_API __declspec(dllexport)
#else
#  define C4LIB_API __declspec(dllimport)
#endif
#else // Linux
#  define C4LIB_API __attribute__ ((visibility("default"))) 
#endif

#endif