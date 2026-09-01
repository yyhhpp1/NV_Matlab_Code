/*  \file     C4FeatureInfo.hpp
 *  \brief    C++ Library for access to heliotis GenICam based camera C4
 *  \version  0.0.1
 *  \author   Silvan Murer, heliotis
 *  \date     2019
 */

#ifndef INC_C4FEATUREINFO
#define INC_C4FEATUREINFO

#include "C4HdlDef.hpp"

#include <stdint.h>
#include <string>
#include <vector>

namespace heliotis {

class FeatureInfoData;

/**
 * Class containing meta information of a feature
 */
class C4LIB_API C4FeatureInfo {
public:
  /**
   * \enum Type_e
   * \brief enumeration of feature types 
   */
  enum class Type_e : int64_t { 
    UNKNOWN = 0,      /**< unknown feature type */
    INTEGER = 1,      /**< integer feature type */
    FLOAT =2,         /**< float feature type */
    STRING = 3,       /**< string feature type */
    ENUMERATION = 4,  /**< enumeration feature type */
    COMMAND = 5,      /**< command feature type */
    BOOLEAN = 6       /**< boolean feature type */
  }; 
  /**
   * \enum Visibility_e
   * \brief enumeration of feature visibility information
   */
  enum class Visibility_e : int64_t { 
    UNKNOWN = 0,    /**< unknown feature visibility */
    BEGINNER = 1,   /**< beginner feature visibility - this features should shown shown to any users */
    EXPERT = 2,     /**< guru feature visibility - this features should shown only for expert users */
    GURU = 3,       /**< guru feature visibility - this features should shown only for guru users */
    INVISIBLE = 4   /**< invisible feature - this feature shouldn't shown to a user */
  };
  /**
   * \enum AccessMode_e
   * \brief enumeration of feature accessmode information
   */
  enum class AccessMode_e : int64_t { 
    UNKNOWN = 0,  /**< unknown feature accessmode */
    NI = 1,       /**< the feature is not implemented on the device */
    NA = 2,       /**< the feature is temporary not available on the device */
    RO = 3,       /**< the feature is in read only mode */
    WO = 4,       /**< the feature is in write only mode */
    RW = 5        /**< the feature is in read/write mode */
  };

private:
  FeatureInfoData* c4FeatureInfoData; /**< pointer to internal data */

public:
  /**
   * \brief constructor
   *
   * Don't create a C4FeatureInfo by self. Use the C4Interface::getFeatureList or C4Device::getFeatureList function!
   */
  C4FeatureInfo();
  /**
   * \brief constructor
   *
   * Don't create a C4FeatureInfo by self. Use the C4Interface::getFeatureList or C4Device::getFeatureList function!
   */
  C4FeatureInfo(void* cNodePtr);

  /**
   * \brief copy constructor
   */
  C4FeatureInfo(const C4FeatureInfo& other);
  /**
   * \brief copy assignment
   */
  C4FeatureInfo& operator=(const C4FeatureInfo& other);

  /**
   * \brief move constructor
   */
  C4FeatureInfo(C4FeatureInfo && other);
  /**
   * \brief move assignment
   */
  C4FeatureInfo& operator=(C4FeatureInfo && other); 

  /**
   * \brief destructor
   */
  ~C4FeatureInfo();

  /**
   * \brief get feature type
   *
   * \return the feature type as Type_e
   */
  Type_e getType();
  /**
   * \brief get feature name
   *
   * \return the feature name as string
   */
  std::string getName();
  /**
   * \brief get feature category
   *
   * \return the nex higher feature category as string
   */
  std::string getCategory();
  /**
   * \brief get feature description
   *
   * \return the feature description as string
   */
  std::string getDescription();
  /**
   * \brief get feature visibility
   *
   * \return the feature visibility as Visibility_e
   */
  Visibility_e getVisibility();
  /**
   * \brief get feature access mode
   *
   * \return the feature access mode as AccessMode_e
   */
  AccessMode_e getAccessMode();

  /**
   * \brief get features minimum value (only if INTEGER feature)
   *
   * \return the feature minimum value
   */
  int64_t getIntMin();
  /**
   * \brief get features maximum value (only if INTEGER feature)
   *
   * \return the feature maximum value
   */
  int64_t getIntMax();
  /**
   * \brief get features increment value (only if INTEGER feature)
   *
   * \return the feature increment value
   */
  int64_t getIntInc();

  /**
   * \brief get features minimum value (only if FLOAT feature)
   *
   * \return the feature minimum value
   */
  double getFloatMin();
  /**
   * \brief get features maximum value (only if FLOAT feature)
   *
   * \return the feature maximum value
   */
  double getFloatMax();
  /**
   * \brief get features increment value (only if FLOAT feature)
   *
   * \return the feature increment value
   */
  double getFloatInc();

  /**
   * \brief get features enumeration entries value (only if ENUMERATION feature)
   *
   * \return a list of features enumeration entries
   */
  std::vector<std::string> getEnumEntryList();

  /**
   * \brief get a list of feature names which invalidate this feature
   *
   * \return a list of feature names which invalidate this feature
   */
  std::vector<std::string> getInvalidatorList();
  /**
   * \brief get a list of feature names which are selected by this feature
   *
   * \return a list of feature names which are selected by this feature
   */
  std::vector<std::string> getSelectedList();

};

} /* namespace heliotis */

#endif
