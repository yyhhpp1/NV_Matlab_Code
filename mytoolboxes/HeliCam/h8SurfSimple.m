clc; clear all; close all;

if ~NET.isNETSupported
    disp('Supported .NET Framework not found')
    return
end

NET.addAssembly('C4HdlCLR');
import C4HdlCLR.*

disp('*************************************************')
disp('* Matlab example h8SurfSimple based on C4HdlCLR *')
disp('*************************************************')

c4sys = heliotis.C4HandlerCLR();
c4sys.reset();
ifNo = selectInterface(c4sys);
c4if = c4sys.openInterface(ifNo);
devNo = selectDevice(c4if);
c4dev = c4if.openDevice(devNo);

disp('initialize camera: ')
initializeDevice(c4dev)


c4dev.startAcquisition(4)

% measurement loop (10 iterations)
for i = 0:10
    % trigger single measurement
    c4dev.writeString("TriggerSelector", "FrameStart");
    c4dev.executeCommand("TriggerSoftware");

    % acquire data
    c4buf = c4dev.getBuffer(10000);
    
    % look for float surface and amplitude component
    surfPart = -1;
    ampPart = -1;
    nofParts = c4buf.readInteger("ChunkPartCount");
    for j = 0:(nofParts-1)
        c4buf.writeInteger("ChunkPartSelector", j);
        partType = c4buf.readString("ChunkPartType");
        if partType == "Surface"
            surfPart = j;
        elseif partType == "Amplitude"
            ampPart = j;
        end
    end

    rawSurf = c4buf.getDataPartFloat(surfPart);
    rawSurfDim = c4buf.getPartDimension(surfPart);

    rawAmp = c4buf.getDataPartUint16(ampPart);
    rawAmpDim = c4buf.getPartDimension(ampPart);

    % Conversion of types .NET and Matlab :
    % https://ch.mathworks.com/help/compiler_sdk/dotnet/rules-for-data-conversion-between-net-and-matlab.html 
    % See types command : whos
    % rawAmp                  1x1                       8  System.UInt16[]                      
    % rawAmpDim               1x1                       8  System.Int64[]                       
    % rawSurf                 1x1                       8  System.Double[]                      
    % rawSurfDim              1x1                       8  System.Int64[]                       
    
    matSurfDim = int64(rawSurfDim);
    surfWidth = matSurfDim(1);
    surfHeight = matSurfDim(2);
    % transpose is required for correct plotting of the data
    matSurf = transpose(reshape(double(rawSurf) , surfWidth, surfHeight));
    
    matAmpDim = int64(rawAmpDim);
    ampWidth = matAmpDim(1);
    ampHeight = matAmpDim(2);
    % transpose is required for correct plotting of the data
    matAmp = transpose(reshape(uint16(rawAmp) , ampWidth, ampHeight));
    
    figure(1); imagesc(matSurf); title("Surface"); 
    figure(2); imagesc(matAmp); title("Amplitude");

    % release buffer
    c4buf.release();

    disp("Iteration " + num2str(i) + " done.");
end

c4dev.stopAcquisition()

% release resources
c4dev.release()
c4if.release()

function ifNo = selectInterface(c4sys)
    ifNo = -1;
    disp('Interfaces: ')
    nofIf = c4sys.updateInterfaceList();
    if (nofIf == 0)
        disp('No interface detected!');
        return
    end
    for i = 0:(nofIf-1)
        curIfName = c4sys.getInterfaceName(i);
        disp(num2str(i + 1) + ": " + string(curIfName));
    end
    val = input('select an interface (exit with any other value): ');
    if ((val <= 0) || (val > nofIf))
        disp('Interface selection is out of range!');
        return
    end
    ifNo = (val - 1);
end

function devNo = selectDevice(c4if)
    devNo = -1;
    disp('Device: ')
    nofDev = c4if.updateDeviceList();
    if (nofDev == 0)
        disp('No device detected!');
        return
    end
    for i = 0:(nofDev-1)
        curDevName = c4if.getDeviceName(i);
        disp(num2str(i + 1) + ": " + string(curDevName));
    end
    val = input('select a device (exit with any other value): ');
    if ((val <= 0) || (val > nofDev))
        disp('Device selection is out of range!');
        return
    end
    devNo = (val - 1);
end

function initializeDevice(c4dev)
    % simple configuration example of heliInspect H8 using internal motion control
    
    % Motion parameters in [mm] or [mm/s]
    scanPosition = -1.4;
    scanRange = 0.5;
    scanSpeed = 5.0;
    generalSpeed = 10.0;
    % exposure ration between 0.0 and 1.0 [1.0 = 100% exposure]
    exposureRatio = 1.0;
    
    % enable required components
    c4dev.writeString("ComponentSelector", "Intensity");
    c4dev.writeInteger("ComponentEnable", 0);
    c4dev.writeString("ComponentSelector", "Range");
    c4dev.writeInteger("ComponentEnable", 1);
    c4dev.writeString("ComponentSelector", "Reflectance");
    c4dev.writeInteger("ComponentEnable", 1);
    c4dev.writeString("ComponentSelector", "Phase");
    c4dev.writeInteger("ComponentEnable", 0);
    
    % enable required chunk data (optional)
    c4dev.writeInteger("ChunkModeActive", 1);
    c4dev.writeString("ChunkSelector", "PartCount");
    c4dev.writeInteger("ChunkEnable", 1);
    c4dev.writeString("ChunkSelector", "PartType");
    c4dev.writeInteger("ChunkEnable", 1);
    
    % trigger configuration
    c4dev.writeString("TriggerSelector", "RecordingStart");
    c4dev.writeString("TriggerMode", "On");
    c4dev.writeString("TriggerSource", "Stage");
    c4dev.writeString("TriggerSelector", "AcquisitionStart");
    c4dev.writeString("TriggerMode", "Off");
    c4dev.writeString("TriggerSelector", "FrameStart");
    c4dev.writeString("TriggerMode", "On");
    c4dev.writeString("TriggerSource", "Software");
    % Hint: The TriggerSource also controls the TriggerSoftware feature.
    
    % encoder configuration
    c4dev.writeString("EncoderSelector", "Camera");
    c4dev.writeInteger("EncoderInverter", 1);
    
    % motion and position configuration
    c4dev.writeFloat("ScanPosition", scanPosition);
    c4dev.writeFloat("ScanRange", scanRange);
    c4dev.writeFloat("ScanSpeed", scanSpeed);
    c4dev.writeFloat("GeneralSpeed", generalSpeed);
    
    c4dev.writeString("ScanMode", "Down");
    c4dev.executeCommand("StageInit");
    
    % additional camera and processing configuration
    c4dev.writeString("Scan3dExtractionMethod", "AcceleratedCenterOfMassIQCorrection");
    c4dev.writeString("Scan3dScalingMethod", "zTags");
    c4dev.writeString("Scan3dDistanceUnit", "um");
    
    c4dev.writeFloat("TargetVerticalSpacing", 2.5);
    c4dev.writeFloat("ExposureRatio", exposureRatio);
    
    c4dev.writeString("FPNCorrection", "AverageLastFrames");
    c4dev.writeInteger("FPNCorrectionNFrames", 8);
    c4dev.writeInteger("ExtSimpMaxHWin", 7);
    
    % illumination control (D3)
    c4dev.writeString("LightControllerSelector", "LightController0");
    c4dev.writeString("LightControllerSource", "UserOutput0");
    c4dev.writeFloat("LightBrightness", 100.0);
    % illumination control (D2)
    % LineSelector = Line2
    % LineSource = UserOutput0
    % LineInverter = true
    % switch on the illumination (D2/D3)
    c4dev.writeString("UserOutputSelector", "UserOutput0");
    c4dev.writeInteger("UserOutputValue", 1);
end

