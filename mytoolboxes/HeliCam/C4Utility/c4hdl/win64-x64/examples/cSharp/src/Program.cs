/**
* \file        Program.cs
* \author      Silvan Murer
* \date        7 April 2021
* \copyright   Heliotis, 2021
*
* \brief Simple C# example based on C4HdlCLR for heliInspect H8
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;


namespace h8SurfSimple
{
    class Program
    {
        /**
         * \brief  Scan for available interfaces and print interface list
         *         let the user select one and open the interface
         *
         * \param[in]  c4sys  system object of C4Hdl library
         * \return index of selected interface
         */
        static int selectInterface(heliotis.C4HandlerCLR c4sys)
        {
            Console.WriteLine("Interfaces: ");
            long nofIf = c4sys.updateInterfaceList();
            if (nofIf == 0)
            {
                throw new System.Exception("No interface detected!");
            }
            for (long i = 0; i < nofIf; i++)
            {
                string curIfName = c4sys.getInterfaceName(i);
                Console.WriteLine(i + ": " + curIfName);
            }
            Console.WriteLine();
            Console.WriteLine("Select a interfaces (exit with any other value)");
            /* wait for user input */
            string val = Console.ReadLine();
            int selection = Convert.ToInt32(val);
            if (selection < 0 || selection >= nofIf)
            {
                throw new System.Exception("Interface selection is out of range!");
            }
            return selection;
        }

        /**
         * \brief  Scan for available devices and print device list
         *         let the user select one and open the connection to the device
         *
         * \param[in]  c4if  interface object of C4Hdl library
         * \return index of selected device
         */
        static int selectDevice(heliotis.C4InterfaceCLR c4if)
        {
            Console.WriteLine("Devices: ");
            long nofDev = c4if.updateDeviceList();
            if (nofDev == 0)
            {
                throw new System.Exception("No device detected!");
            }
            for (long i = 0; i < nofDev; i++)
            {
                string curDevName = c4if.getDeviceName(i);
                Console.WriteLine(i + ": " + curDevName);
            }
            Console.WriteLine();
            Console.WriteLine("Select a device (exit with any other value)");
            /* wait for user input */
            string val = Console.ReadLine();
            int selection = Convert.ToInt32(val);
            if (selection < 0 || selection >= nofDev)
            {
                throw new System.Exception("Device selection is out of range!");
            }
            return selection;
        }

        /**
         * \brief  simple configuration example of heliInspect H8 using internal motion control
         *
         * \param[in]  c4dev  device object of C4Hdl library
         */
        static void initializeDevice(heliotis.C4DeviceCLR c4dev)
        {
            // Motion parameters in [mm] or [mm/s]
            double scanPosition = -1.4;
            double scanRange = 0.5;
            double scanSpeed = 5.0;
            double generalSpeed = 10.0;
            // exposure ration between 0.0 and 1.0 [1.0 = 100% exposure]
            double exposureRatio = 1.0;

            // enable required components
            c4dev.writeString("ComponentSelector", "Intensity");
            c4dev.writeInteger("ComponentEnable", 0);
            c4dev.writeString("ComponentSelector", "Range");
            c4dev.writeInteger("ComponentEnable", 1);
            c4dev.writeString("ComponentSelector", "Reflectance");
            c4dev.writeInteger("ComponentEnable", 1);
            c4dev.writeString("ComponentSelector", "Phase");
            c4dev.writeInteger("ComponentEnable", 0);

            // enable required chunk data (optional)
            c4dev.writeInteger("ChunkModeActive", 1);
            c4dev.writeString("ChunkSelector", "PartCount");
            c4dev.writeInteger("ChunkEnable", 1);
            c4dev.writeString("ChunkSelector", "PartType");
            c4dev.writeInteger("ChunkEnable", 1);

            // trigger configuration
            c4dev.writeString("TriggerSelector", "RecordingStart");
            c4dev.writeString("TriggerMode", "On");
            c4dev.writeString("TriggerSource", "Stage");
            c4dev.writeString("TriggerSelector", "AcquisitionStart");
            c4dev.writeString("TriggerMode", "Off");
            c4dev.writeString("TriggerSelector", "FrameStart");
            c4dev.writeString("TriggerMode", "On");
            c4dev.writeString("TriggerSource", "Software");
            // Hint: The TriggerSource also controls the TriggerSoftware feature.

            // encoder configuration
            c4dev.writeString("EncoderSelector", "Camera");
            c4dev.writeInteger("EncoderInverter", 1);

            // motion and position configuration
            c4dev.writeFloat("ScanPosition", scanPosition);
            c4dev.writeFloat("ScanRange", scanRange);
            c4dev.writeFloat("ScanSpeed", scanSpeed);
            c4dev.writeFloat("GeneralSpeed", generalSpeed);

            c4dev.writeString("ScanMode", "Down");
            c4dev.executeCommand("StageInit");

            // additional camera and processing configuration
            c4dev.writeString("Scan3dExtractionMethod", "AcceleratedCenterOfMassIQCorrection");
            c4dev.writeString("Scan3dScalingMethod", "zTags");
            c4dev.writeString("Scan3dDistanceUnit", "um");

            c4dev.writeFloat("TargetVerticalSpacing", 2.5);
            c4dev.writeFloat("ExposureRatio", exposureRatio);

            c4dev.writeString("FPNCorrection", "AverageLastFrames");
            c4dev.writeInteger("FPNCorrectionNFrames", 8);
            c4dev.writeInteger("ExtSimpMaxHWin", 7);

            // illumination control (D3)
            c4dev.writeString("LightControllerSelector", "LightController0");
            c4dev.writeString("LightControllerSource", "UserOutput0");
            c4dev.writeFloat("LightBrightness", 100.0);
            // illumination control (D2)
            // LineSelector = Line2
            // LineSource = UserOutput0
            // LineInverter = true
            // switch on the illumination (D2/D3)
            c4dev.writeString("UserOutputSelector", "UserOutput0");
            c4dev.writeInteger("UserOutputValue", 1);
        }

        /**
         * \brief  application main
         *
         * \param[in]  args  arguments (not used)
         */
        static void Main(string[] args)
        {
            Console.WriteLine("********************************************************");
            Console.WriteLine("* Configure and acquire data in '3D surface mode'");
            Console.WriteLine("********************************************************");

            heliotis.C4HandlerCLR c4sys = new heliotis.C4HandlerCLR();
            int ifNo = selectInterface(c4sys);
            heliotis.C4InterfaceCLR c4if = c4sys.openInterface(ifNo);
            int devNo = selectDevice(c4if);
            heliotis.C4DeviceCLR c4dev = c4if.openDevice(devNo);

            Console.WriteLine("initialize camera");
            initializeDevice(c4dev);

            c4dev.startAcquisition(4);

            // measurement loop (10 iterations)
            for (int i = 0; i < 10; i++)
            {
                // trigger single measurement
                c4dev.writeString("TriggerSelector", "FrameStart");
                c4dev.executeCommand("TriggerSoftware");
                
                // acquire data
                heliotis.C4BufferCLR c4buf = c4dev.getBuffer(10000);

                // look for float surface and amplitude component
                long surfPart = -1;
                long ampPart = -1;
                long nofParts = c4buf.readInteger("ChunkPartCount");
                for (long j = 0; j < nofParts; j ++)
                {
                    c4buf.writeInteger("ChunkPartSelector", j);
                    String partType = c4buf.readString("ChunkPartType");
                    if (partType == "Surface")
                    {
                        surfPart = j;
                    }
                    if (partType == "Amplitude")
                    {
                        ampPart = j;
                    }
                }

                double[] surfaceImage = c4buf.getDataPartFloat(surfPart);
                UInt16[] amplitudeImage = c4buf.getDataPartUint16(ampPart);
                // ToDo: reshape array and display images

                // release buffer
                c4buf.release();
                Console.WriteLine("iteration " + i + " done!");
            }

            c4dev.stopAcquisition();
            c4dev.release();
            c4if.release();

            Console.WriteLine("Press Key for exit...");
            Console.ReadKey();
        }
    }
}
