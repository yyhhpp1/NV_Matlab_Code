#include <iostream>
#include <string>
#include <vector>

#include <cvb/device_factory.hpp>
#include <cvb/global.hpp>
#include <cvb/driver/composite_stream.hpp>
//#include <cvb/driver/point_cloud_stream.hpp>
#include <cvb/genapi/node_map_enumerator.hpp>


/**
 * \brief helper to print the composite purpose
 * \param[in] composite a composite pointer
 */
void PrintOutCompositePurpose(Cvb::CompositePtr composite)
{
  auto purpose = composite->Purpose();
  std::cout << "Composite purpose: ";
  switch (purpose)
  {
  case Cvb::CompositePurpose::Custom: std::cout << "Custom\n"; break;
  case Cvb::CompositePurpose::Image: std::cout << "Image\n"; break;
  case Cvb::CompositePurpose::ImageList: std::cout << "Image List\n"; break;
  case Cvb::CompositePurpose::MultiAoi: std::cout << "MultiAoi\n"; break;
  case Cvb::CompositePurpose::RangeMap: std::cout << "RangeMap\n"; break;
  case Cvb::CompositePurpose::PointCloud: std::cout << "PointCloud\n"; break;
  case Cvb::CompositePurpose::ImageCube: std::cout << "ImageCube\n"; break;
  default: std::cout << "Unknown\n"; break;
  }
}


/**
 * \brief Scan for available devices and print the device list.
 *        let the user select one and open the connection to the device
 * \return GenICamDevicePtr object
 */
Cvb::GenICamDevicePtr selectDevice() {
  // discover transport layers
  auto infoList = Cvb::DeviceFactory::Discover( Cvb::DiscoverFlags::IgnoreVins | Cvb::DiscoverFlags::IgnoreGevFD | Cvb::DiscoverFlags::IgnoreGevSD );

  // can't continue the demo if there's no available device
  if (infoList.empty())
    throw std::runtime_error("There is no available device for this demonstration.");

  size_t nofDev = infoList.size();
  std::cout << std::to_string(nofDev) << " GenTL devices detected on this PC" << std::endl;
  for (size_t i = 0; i < nofDev; i++) {
    std::string deviceIdStr;
    infoList[i].TryGetProperty(Cvb::DiscoveryProperties::DeviceId, deviceIdStr);
    std::cout << std::to_string(i) << ") " << deviceIdStr << std::endl;
  }

  std::cout << "Select a device (exit with any other value)" << std::endl;
  /* wait for user input */
  char str[10];
  fgets(str, sizeof(str), stdin);
  int selection = atoi(str);

  if (selection < 0 || selection >= nofDev) {
    throw std::runtime_error("User selection is out ouf range...");
  }

  // instantiate the selected device
  return Cvb::DeviceFactory::Open<Cvb::GenICamDevice>(infoList[selection].AccessToken(), Cvb::AcquisitionStack::GenTL);
}


/**
 * \brief simple configuration example of heliInspect H8 using internal motion control
 *
 * \param[in]  nm       nodemap handle
 */
void initializeDevice(Cvb::NodeMapPtr nodeMap) {
    // Motion parameters in [mm] or [mm/s]
    float scanPosition = -16.6;
    float scanRange = 0.5;

  // enable required components
  nodeMap->Node<Cvb::EnumerationNode>("ComponentSelector")->SetValue("Intensity");
  nodeMap->Node<Cvb::BooleanNode>("ComponentEnable")->SetValue(false);
  nodeMap->Node<Cvb::EnumerationNode>("ComponentSelector")->SetValue("Range");
  nodeMap->Node<Cvb::BooleanNode>("ComponentEnable")->SetValue(true);
  nodeMap->Node<Cvb::EnumerationNode>("ComponentSelector")->SetValue("Reflectance");
  nodeMap->Node<Cvb::BooleanNode>("ComponentEnable")->SetValue(true);
  nodeMap->Node<Cvb::EnumerationNode>("ComponentSelector")->SetValue("Phase");
  nodeMap->Node<Cvb::BooleanNode>("ComponentEnable")->SetValue(false);

  // enable required chunk data (optional)
  nodeMap->Node<Cvb::BooleanNode>("ChunkModeActive")->SetValue(true);
  nodeMap->Node<Cvb::EnumerationNode>("ChunkSelector")->SetValue("PartCount");
  nodeMap->Node<Cvb::BooleanNode>("ChunkEnable")->SetValue(true);
  nodeMap->Node<Cvb::EnumerationNode>("ChunkSelector")->SetValue("PartType");
  nodeMap->Node<Cvb::BooleanNode>("ChunkEnable")->SetValue(true);

  // trigger configuration
  nodeMap->Node<Cvb::EnumerationNode>("TriggerSelector")->SetValue("RecordingStart");
  nodeMap->Node<Cvb::EnumerationNode>("TriggerMode")->SetValue("On");
  nodeMap->Node<Cvb::EnumerationNode>("TriggerSource")->SetValue("Stage");
  nodeMap->Node<Cvb::EnumerationNode>("TriggerSelector")->SetValue("AcquisitionStart");
  nodeMap->Node<Cvb::EnumerationNode>("TriggerMode")->SetValue("Off");
  nodeMap->Node<Cvb::EnumerationNode>("TriggerSelector")->SetValue("FrameStart");
  nodeMap->Node<Cvb::EnumerationNode>("TriggerMode")->SetValue("On");
  nodeMap->Node<Cvb::EnumerationNode>("TriggerSource")->SetValue("Software");
  // Hint: The TriggerSource also controls the TriggerSoftware feature.

  // encoder configuration
  nodeMap->Node<Cvb::EnumerationNode>("EncoderSelector")->SetValue("Camera");
  nodeMap->Node<Cvb::BooleanNode>("EncoderInverter")->SetValue(true);

  // motion and position configuration
  nodeMap->Node<Cvb::FloatNode>("ScanPosition")->SetValue(scanPosition);
  nodeMap->Node<Cvb::FloatNode>("ScanRange")->SetValue(scanRange);
  nodeMap->Node<Cvb::FloatNode>("ScanSpeed")->SetValue(5.0);
  nodeMap->Node<Cvb::FloatNode>("GeneralSpeed")->SetValue(10.0);

  nodeMap->Node<Cvb::EnumerationNode>("ScanMode")->SetValue("Down");
  nodeMap->Node<Cvb::CommandNode>("StageInit")->Execute();

  // additional camera and processing configuration
  nodeMap->Node<Cvb::EnumerationNode>("Scan3dExtractionMethod")->SetValue("AcceleratedCenterOfMassIQCorrection");
  nodeMap->Node<Cvb::EnumerationNode>("Scan3dScalingMethod")->SetValue("zTags");
  nodeMap->Node<Cvb::EnumerationNode>("Scan3dDistanceUnit")->SetValue("um");

  nodeMap->Node<Cvb::FloatNode>("TargetVerticalSpacing")->SetValue(4.0);
  nodeMap->Node<Cvb::FloatNode>("ExposureRatio")->SetValue(1.0);

  nodeMap->Node<Cvb::EnumerationNode>("FPNCorrection")->SetValue("AverageLastFrames");
  nodeMap->Node<Cvb::IntegerNode>("FPNCorrectionNFrames")->SetValue(8);
  nodeMap->Node<Cvb::IntegerNode>("ExtSimpMaxHWin")->SetValue(7);

  // illumination control (D3)
  nodeMap->Node<Cvb::EnumerationNode>("LightControllerSelector")->SetValue("LightController0");
  nodeMap->Node<Cvb::EnumerationNode>("LightControllerSource")->SetValue("UserOutput0");
  nodeMap->Node<Cvb::FloatNode>("LightBrightness")->SetValue(100.0);
  // illumination control (D2)
  // LineSelector = Line2
  // LineSource = UserOutput0
  // LineInverter = true
  // switch on the illumination (D2/D3)
  nodeMap->Node<Cvb::EnumerationNode>("UserOutputSelector")->SetValue("UserOutput0");
  nodeMap->Node<Cvb::BooleanNode>("UserOutputValue")->SetValue(true);
}


int main()
{
  try
  {
    // instantiate the first device in the discovered list
    auto device = selectDevice();
    auto nodeMap = device->NodeMap("Device");

    initializeDevice(nodeMap);
    
    auto dataStream = device->Stream<Cvb::CompositeStream>();
    dataStream->Start();

    // measurement loop (10 iterations)
    for (auto i = 0; i < 10; i++)
    {
      Cvb::CompositePtr composite;
      Cvb::WaitStatus waitStatus;
      Cvb::NodeMapEnumerator enumerator;

      // trigger a single measurement
      nodeMap->Node<Cvb::EnumerationNode>("TriggerSelector")->SetValue("FrameStart");
      nodeMap->Node<Cvb::CommandNode>("TriggerSoftware")->Execute();

      // acquire data
      std::tie(composite, waitStatus, enumerator) = dataStream->WaitFor(std::chrono::milliseconds(10000));

      if (waitStatus != Cvb::WaitStatus::Ok) {
          std::cout << "Failed to acqire data!" << std::endl;
          continue;
      }

      // Print a view meta informations:
      PrintOutCompositePurpose(composite);
      int nofElements = composite->ItemCount();
      std::cout << "The number of elements in composite is " << nofElements << std::endl;

      for (int j = 0; j < nofElements; j++)
      {
        auto element = composite->ItemAt(j);

        if (Cvb::holds_alternative<Cvb::ImagePtr>(element)) {
          std::cout << "Element " << j << " is an image" << std::endl;

          const auto imagePtr = Cvb::get<Cvb::ImagePtr>(element);
          imagePtr->Save("image" + std::to_string(j) + ".tiff");
        }

        if (Cvb::holds_alternative<Cvb::PlaneEnumeratorPtr>(element)) {
            std::cout << "Element " << j << " is a plane enumerator" << std::endl;

            const auto planeEnumeratorPtr = Cvb::get<Cvb::PlaneEnumeratorPtr>(element);
            // usally the heliInspect H8 returns one plane containing the 'z' (height) information
            if (planeEnumeratorPtr->PlaneCount() == 1) {
                // convert the plane to an image and export them as tiff
                Cvb::Image image(planeEnumeratorPtr->Plane(0)->Length(0), 
                                  planeEnumeratorPtr->Plane(0)->Length(1), 
                                  1, 
                                  planeEnumeratorPtr->Plane(0)->DataType()
                                );
                auto imageRawPtr = image.Plane(0).LinearAccess().BasePtr();
                auto planeRawPtr = planeEnumeratorPtr->Plane(0)->BasePtr();
                size_t dataSize = planeEnumeratorPtr->Plane(0)->Length(0) * planeEnumeratorPtr->Plane(0)->Length(1) * planeEnumeratorPtr->Plane(0)->DataType().BytesPerPixel();
                std::memcpy(imageRawPtr, planeRawPtr, dataSize);
                image.Save("plain" + std::to_string(j) + ".tiff");
            }
        }

        if (Cvb::holds_alternative<Cvb::PlanePtr>(element)) {
          std::cout << " is a plane\n";
        }

        if (Cvb::holds_alternative<Cvb::BufferPtr>(element)) {
          std::cout << " is a buffer\n";
        }

        if (Cvb::holds_alternative<Cvb::PFNCBufferPtr>(element)) {
          std::cout << " is a pfnc buffer\n";
        }

      }

    }

    // stop the data acquisition, ignore errors
    dataStream->Stop();
  }
  catch (const std::exception& e)
  {
    std::cout << e.what() << std::endl;
  }
  return 0;
}
