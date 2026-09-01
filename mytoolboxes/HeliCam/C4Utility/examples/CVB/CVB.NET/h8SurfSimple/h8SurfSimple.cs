using System;
using System.Threading;

using Stemmer.Cvb;
using Stemmer.Cvb.Driver; // for IndexedStream
using Stemmer.Cvb.Utilities; // for SystemInfo
using Stemmer.Cvb.GenApi;

namespace CVB_Test
{
    class Program
    {
        /* simple configuration example of heliInspect H8 using internal motion control */
        static void initializeDevice(NodeMap deviceNodeMap)
        {
            // Motion parameters in [mm] or [mm/s]
            Double scanPosition = -16.6;
            Double scanRange = 0.5;
            Double scanSpeed = 5.0;
            Double generalSpeed = 10.0;

            // enable required components
            ((EnumerationNode)deviceNodeMap["ComponentSelector"]).Value = "Intensity";
            ((BooleanNode)deviceNodeMap["ComponentEnable"]).Value = false;
            ((EnumerationNode)deviceNodeMap["ComponentSelector"]).Value = "Range";
            ((BooleanNode)deviceNodeMap["ComponentEnable"]).Value = true;
            ((EnumerationNode)deviceNodeMap["ComponentSelector"]).Value = "Reflectance";
            ((BooleanNode)deviceNodeMap["ComponentEnable"]).Value = true;
            ((EnumerationNode)deviceNodeMap["ComponentSelector"]).Value = "Phase";
            ((BooleanNode)deviceNodeMap["ComponentEnable"]).Value = false;

            // enable required chunk data (optional)
            ((BooleanNode)deviceNodeMap["ChunkModeActive"]).Value = true;
            ((EnumerationNode)deviceNodeMap["ChunkSelector"]).Value = "PartCount";
            ((BooleanNode)deviceNodeMap["ChunkEnable"]).Value = true;
            ((EnumerationNode)deviceNodeMap["ChunkSelector"]).Value = "PartType";
            ((BooleanNode)deviceNodeMap["ChunkEnable"]).Value = true;

            // trigger configuration
            ((EnumerationNode)deviceNodeMap["TriggerSelector"]).Value = "RecordingStart";
            ((EnumerationNode)deviceNodeMap["TriggerMode"]).Value = "On";
            ((EnumerationNode)deviceNodeMap["TriggerSource"]).Value = "Stage";
            ((EnumerationNode)deviceNodeMap["TriggerSelector"]).Value = "AcquisitionStart";
            ((EnumerationNode)deviceNodeMap["TriggerMode"]).Value = "Off";
            ((EnumerationNode)deviceNodeMap["TriggerSelector"]).Value = "FrameStart";
            ((EnumerationNode)deviceNodeMap["TriggerMode"]).Value = "On";
            ((EnumerationNode)deviceNodeMap["TriggerSource"]).Value = "Software";
            // Hint: The TriggerSource also controls the TriggerSoftware feature.

            // encoder configuration
            ((EnumerationNode)deviceNodeMap["EncoderSelector"]).Value = "Camera";
            ((BooleanNode)deviceNodeMap["EncoderInverter"]).Value = true;

            // motion and position configuration
            ((FloatNode)deviceNodeMap["ScanPosition"]).Value = scanPosition;
            ((FloatNode)deviceNodeMap["ScanRange"]).Value = scanRange;
            ((FloatNode)deviceNodeMap["ScanSpeed"]).Value = scanSpeed;
            ((FloatNode)deviceNodeMap["GeneralSpeed"]).Value = generalSpeed;

            ((EnumerationNode)deviceNodeMap["ScanMode"]).Value = "Down";
            ((CommandNode)deviceNodeMap["StageInit"]).Execute();

            // additional camera and processing configuration
            ((EnumerationNode)deviceNodeMap["Scan3dExtractionMethod"]).Value = "AcceleratedCenterOfMassIQCorrection";
            ((EnumerationNode)deviceNodeMap["Scan3dScalingMethod"]).Value = "zTags";
            ((EnumerationNode)deviceNodeMap["Scan3dDistanceUnit"]).Value = "um";

            ((FloatNode)deviceNodeMap["TargetVerticalSpacing"]).Value = 4.0;
            ((FloatNode)deviceNodeMap["ExposureRatio"]).Value = 1.0;

            ((EnumerationNode)deviceNodeMap["FPNCorrection"]).Value = "AverageLastFrames";
            ((IntegerNode)deviceNodeMap["FPNCorrectionNFrames"]).Value = 8;
            ((IntegerNode)deviceNodeMap["ExtSimpMaxHWin"]).Value = 7;

            // illumination control (D3)
            ((EnumerationNode)deviceNodeMap["LightControllerSelector"]).Value = "LightController0";
            ((EnumerationNode)deviceNodeMap["LightControllerSource"]).Value = "UserOutput0";
            ((FloatNode)deviceNodeMap["LightBrightness"]).Value = 100.0;
            // illumination control (D2)
            // LineSelector=Line2
            // LineSource=UserOutput0
            // LineInverter=1
            // switch on the illumination (D2/D3)
            ((EnumerationNode)deviceNodeMap["UserOutputSelector"]).Value = "UserOutput0";
            ((BooleanNode)deviceNodeMap["UserOutputValue"]).Value = true;

            ((IntegerNode)deviceNodeMap["Rotation"]).Value = 0;
            ((FloatNode)deviceNodeMap["Position"]).Value = -13.15;
            Thread.Sleep(5000);
            ((EnumerationNode)deviceNodeMap["EncoderSelector"]).Value = "Camera";
            ((CommandNode)deviceNodeMap["EncoderReset"]).Execute();
        }

        static GenICamDevice selectDevice()
        {
            // discover devices
            DiscoveryInformationList deviceList = DeviceFactory.Discover(DiscoverFlags.IgnoreVins);

            // can't continue the demo if there's no available device
            if (deviceList.Count == 0)
            {
                throw new System.ArgumentException("There is no available device for this demonstration.");
            }

            Console.WriteLine(deviceList.Count + " GenTL devices detected on this PC");
            for (int i = 0; i < deviceList.Count; i++)
            {
                Console.WriteLine(i + ") " + deviceList[i][DiscoveryProperties.DeviceId]);
            }

            Console.WriteLine("Select a device (exit with any other value) ");
            string consoleInput;
            consoleInput = Console.ReadLine();
            int selection = Convert.ToInt32(consoleInput);
            if (selection < 0 || selection >= deviceList.Count)
            {
                throw new System.ArgumentException("Invalid device selection");
            }
            var device = DeviceFactory.Open(deviceList[selection], AcquisitionStack.GenTL) as GenICamDevice;
            return device;
        }

        static void Main(string[] args)
        {
            Console.WriteLine("Simple CVB .NET example");

            GenICamDevice device = selectDevice();
            NodeMap deviceNodeMap = device.NodeMaps[NodeMapNames.Device];

            initializeDevice(deviceNodeMap);

            var stream = device.GetStream<CompositeStream>(0); 
            stream.Start();

            try
            {
                // measurement loop (10 iterations)
                for (int i = 0; i < 10; i++)
                {
                    ((EnumerationNode)deviceNodeMap["TriggerSelector"]).Value = "FrameStart";
                    ((CommandNode)deviceNodeMap["TriggerSoftware"]).Execute();

                    using (Composite composite = stream.WaitFor( UsTimeSpan.FromMilliseconds(10000) ))
                    {
                        int nofElements = composite.Count;
                        Console.WriteLine("The number of elements in composite is " + nofElements);

                        if (nofElements < 1)
                        {
                            Console.WriteLine("Failed to acquire data!");
                            continue;
                        }

                        for (int j = 0; j < nofElements; j++)
                        {
                            var element = composite[j];

                            if (element is PlaneEnumerator) 
                            {
                                // Range component
                                var plane = element as PlaneEnumerator;
                                if(plane.Count == 1)
                                {
                                    long dataSize = plane[0].GetLength(0) * plane[0].GetLength(1) * plane[0].DataType.BytesPerPixel;
                                    var img = WrappedImage.FromGreyPixels(plane[0].BasePtr, (int)dataSize, (int)plane[0].GetLength(0), (int)plane[0].GetLength(1), PixelDataType.Float, plane[0].DataType.BitsPerPixel, plane[0].DataType.BytesPerPixel, (int)plane[0].GetLength(0) * plane[0].DataType.BytesPerPixel);
                                    img.Save("plane_" + i + ".tif");
                                }
                            } else if (element is Image)
                            {
                                // Amplitude component
                                var image = element as Image;
                                image.Save("image_" + i + ".tif");
                            } else
                            {
                                var type = element.GetType();
                                Console.WriteLine("Case not implemented for element type: " + type);
                            }
                        }
                    }
                }
            }
            finally
            {
                stream.Stop();
            }

            Console.WriteLine("Example End");
        }
    }
}
