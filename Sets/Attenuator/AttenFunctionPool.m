function varargout = AttenFunctionPool(varargin)
    % Created by Weijie 12/06/2022
    switch varargin{1}
        case 'Initialize'
            Initialize()
        case 'Stop'
            Stop()
        case 'SetAtten'
            SetAtten(varargin{2})
        case 'ReadAtten'
            [varargout{1}] = ReadAtten();
        otherwise
            disp('Request Unknown!');
    end
end

function Initialize()
    global gAtten
    NET.addAssembly("E:\Grad School\Berkeley\Research\Project\2D\RT4 MATLAB Code\mcl_RUDAT64_DLL\mcl_RUDAT_NET45.dll");
    gAtten.device = mcl_RUDAT_NET45.USB_RUDAT;
    status = gAtten.device.Connect;
    if ~status
        error("Connection failure.")
    end
end

function Stop()
    global gAtten
    gAtten.device.Disconnect
end

function SetAtten(atten)
    global gAtten
    status = gAtten.device.Send_SCPI(['::CHAN:1:SetATT:', num2str(atten)],'');
    if status ~= 1
       error("Attenuation setting failure.") 
    end
end

function atten = ReadAtten()
    global gAtten
    [status, atten] = gAtten.device.Send_SCPI('::CHAN:1:ATT?','');
    if ~status
        error("Readout failure.")
    end
    atten = str2double(string(atten));
end
