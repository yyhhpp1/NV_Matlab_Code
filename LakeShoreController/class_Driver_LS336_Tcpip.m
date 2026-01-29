%% MATLAB Driver for Lake Shore 336 Heater Controller (TCP/IP version)
% Provide a class that includes all the basic controls and error handling
% of Lake Shore 336 heater controller using TCP/IP (Ethernet) connection,
% for instance: create and terminate connection, set heater level, get
% temperature readings.
%
% * Original script developed and tested by *Yuanqi Lyu*
% (yuanqilyu@berkeley.edu) at *University of California, Berkeley*. All
% rights reserved.
% * This version is modified to use TCP/IP sockets (tested with MATLAB 2021b).
% * The manual of the heater controller can be downloaded from
%   Lake Shore support website.
%
% Code modified by ChatGPT 5.1 to use TCP/IP only (no serial support).

classdef class_Driver_LS336_Tcpip < handle
    %% CONSTANT PROPERTIES
    properties (Constant)
        % Default TCP socket port for Lake Shore 336
        DefaultTcpPort = 7777;
        
        % Communication timeout (s) for queries
        Timeout = 5;
        
        % Extra pause between consecutive commands/queries (s)
        Time_Wait = 0.1;
    end
    
    %% PUBLIC PROPERTIES
    properties (Access = public)
        % Error codes (last 20)
        ErrCode = zeros(1, 20);
        %   1 / -1 : connection error / instability
        %   2 / -2 : communication error (settings mismatch)
        %   3 / -3 : too many heaters / sensors in command
        
        % Number of heaters and temperature sensors
        N_Heater = 1;
        N_TempSensor = 1;
        
        % TCP/IP connection info
        Host          % hostname or IP
        Port         % TCP port
        TcpClient    % tcpclient object
        
        % Device serial number
        SerialNumber
        
        % Heater-related properties
        Heater_Percentage
        Heater_Level = 0;
        Heater_Level_Targ = 0;
        Heater_Conf = struct( ...
            'Connected', 1, ...
            'Type', 0, ...
            'Resistance', 2, ...
            'MaxCurrent', 0, ...
            'MaxUserCurrent', 0.000, ...
            'Display', 1);
        
        % Temperature-related properties
        Temp
        Temp_Targ
        TempSensor_Conf = struct( ...
            'Connected', 'A', ...
            'Type', 2, ...
            'AutoRange', 0, ...
            'Range', 0, ...
            'Compensation', 0, ...
            'Units', 1);
    end
    
    %% METHODS
    methods
        %% Constructor
        function [obj, Out_ErrCode] = class_Driver_LS336_Tcpip( ...
                In_Host, In_N_Heater, In_N_TempSensor, varargin)
            
            % Parse host (and optional port "host:port")
            hostStr = char(In_Host);
            portVal = obj.DefaultTcpPort;
            if contains(hostStr, ":")
                parts = strsplit(hostStr, ":");
                hostStr = strtrim(parts{1});
                tmpPort = str2double(strtrim(parts{2}));
                if ~isnan(tmpPort) && tmpPort > 0
                    portVal = tmpPort;
                end
            end
            
            obj.Host = hostStr;
            obj.Port = portVal;
            
            % Create TCP connection
            obj.create_TcpClient();
            
            obj.N_Heater = In_N_Heater;
            obj.N_TempSensor = In_N_TempSensor;
            
            % Optional configuration structs via name-value pairs
            if ~isempty(varargin)
                In_Conf = struct(varargin{:});
                if isfield(In_Conf, 'HeaterConf')
                     obj.set_HeaterConf(In_Conf.HeaterConf);
                end
                if isfield(In_Conf, 'TempSensorConf')
                    obj.set_TempSensorConf(In_Conf.TempSensorConf);
                end
            end
            
            % Update all readable properties from the controller
            obj.update_AllProperties();
            
            Out_ErrCode = obj.ErrCode(end);
        end
        
        %% Destructor
        function delete(obj)
            if ~isempty(obj.TcpClient)
                obj.terminate_TcpClient();
            end
        end
        
        %% Error handling (GUI msgbox style)
        function error_Handling(obj)
            msgboxStyle.Interpreter = 'tex';
            msgboxStyle.WindowStyle = 'modal';
            if any(obj.ErrCode == 1)
                % Connection instability
                msgbox({['\fontsize{10}{\bfUnable to establish stable ' ...
                    'connection to Lake Shore 336!}'], ...
                    ['The TCP/IP endpoint requested may be currently in ' ...
                    'use or unreachable!'], ...
                    'Check WARNING!'}, ...
                    'ERROR - Lake Shore 336', 'error', msgboxStyle);
                obj.ErrCode(obj.ErrCode == 1) = -1;
            elseif any(obj.ErrCode == 2)
                % Communication mismatch
                msgbox({['\fontsize{10}{\bfUnable to complete ' ...
                    'required setting!}'], ...
                    ['Current parameters of the heater may not be ' ...
                    'desired values!'], ...
                    'Check WARNING!'}, ...
                    'ERROR - Lake Shore 336', 'warn', msgboxStyle);
                obj.ErrCode(obj.ErrCode == 2) = -2;
            elseif any(obj.ErrCode == 3)
                % Too many heaters/sensors in command
                msgbox({['\fontsize{10}{\bfToo many heater / ', ...
                    'temperature sensor in command!}'], ...
                    sprintf(['There is / are %.0f heater(s) and %.0f ', ...
                    'temperature sensor(s) connected!'], ...
                    obj.N_Heater, obj.N_TempSensor)}, ...
                    'ERROR - Lake Shore 336', 'warn', msgboxStyle);
                obj.ErrCode(obj.ErrCode == 3) = -3;
            end
            
            if sum(obj.ErrCode ~= 0) > 3
                % Too many errors → halt
                msgbox({['\fontsize{10}{\bfToo many errors! ', ... 
                    'Program halted!}'], ...
                    'Check WARNING!'}, ...
                    'ERROR - Lake Shore 336', 'error', msgboxStyle);
                return
            end
        end
        
        %% TCP client creation
        function [Out_ErrCode, Out_Client] = create_TcpClient(obj)
            try
                Out_Client = tcpclient(obj.Host, obj.Port, ...
                    "Timeout", obj.Timeout);
                Out_ErrCode = 0;
            catch err
                Out_Client = [];
                Out_ErrCode = 1;
                warning(err.message)
            end
            
            obj.TcpClient = Out_Client;
            obj.ErrCode = circshift(obj.ErrCode, -1);
            obj.ErrCode(end) = Out_ErrCode;
            
            obj.error_Handling();
        end
        
        %% TCP client termination
        function Out_ErrCode = terminate_TcpClient(obj)
            try
                if ~isempty(obj.TcpClient)
                    try
                        flush(obj.TcpClient);
                    catch
                        % ignore flush errors
                    end
                end
            catch
                % ignore
            end
            obj.TcpClient = [];
            obj.ErrCode = circshift(obj.ErrCode, -1);
            obj.ErrCode(end) = 0;
            Out_ErrCode = obj.ErrCode(end);
        end
        
        %% TCP client recreation
        function [Out_ErrCode, Out_Client] = recreate_TcpClient(obj)
            obj.terminate_TcpClient();
            [Out_ErrCode, Out_Client] = obj.create_TcpClient();
        end
        
        %% Low-level: send command (no response expected)
        function Out_ErrCode = send_Command(obj, In_Command)
            try
                cmd = char(sprintf('%s\n', In_Command));  % ensure LF
                write(obj.TcpClient, uint8(cmd));
                
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 0;
            catch err
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 1;
                
                obj.recreate_TcpClient();
                % try once more
                cmd = char(sprintf('%s\n', In_Command));
                write(obj.TcpClient, uint8(cmd));
                warning(err.message)
            end
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
        end
        
        %% Helper: read one line (up to LF) from TCP
        function line = readLine(obj)
            tStart = tic;
            buf = uint8([]);
            lfIdx = [];
            
            while toc(tStart) < obj.Timeout
                nAvail = obj.TcpClient.NumBytesAvailable;
                if nAvail > 0
                    newData = read(obj.TcpClient, nAvail, "uint8");
                    buf = [buf, newData]; %#ok<AGROW>
                    lfIdx = find(buf == 10, 1, 'first');  % LF = 10
                    if ~isempty(lfIdx)
                        break;
                    end
                else
                    pause(0.001);
                end
            end
            
            if isempty(lfIdx)
                error('Timeout waiting for response from Lake Shore 336.');
            end
            
            lineBytes = buf(1:lfIdx-1);       % up to (but not including) LF
            if ~isempty(lineBytes) && lineBytes(end) == 13  % CR
                lineBytes(end) = [];
            end
            line = strtrim(char(lineBytes));
        end
        
        %% Low-level: send query (write then read a line)
        function [Out_ErrCode, Out_Response] = send_Query(obj, In_Query)
            try
                cmd = char(sprintf('%s\n', In_Query));
                write(obj.TcpClient, uint8(cmd));
                
                Out_Response = obj.readLine();
                
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 0;
            catch err
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 1;
                
                warning(err.message)
                obj.recreate_TcpClient();
                Out_Response = "";
            end
            
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
            pause(obj.Time_Wait);
        end
        
        %% HIGHER-LEVEL FUNCTIONS (unchanged logic)
        
        % Get Serial Number
        function [Out_ErrCode, Out_SerialNumber] = get_SerialNumber(obj)
            [~, response] = obj.send_Query("*IDN?");
            pause(0.1);
            [~, response] = obj.send_Query("*IDN?");
            
            Out_SerialNumber = extractBetween(response, 15, 21);
            
            obj.ErrCode = circshift(obj.ErrCode, -1);
            obj.ErrCode(end) = 2 * isempty(Out_SerialNumber);
            
            obj.SerialNumber = Out_SerialNumber;
            
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
        end
        
        % Get Heater Configuration
        function [Out_ErrCode, Out_Heater_Conf] = get_HeaterConf(obj)
            for n = 1 : obj.N_Heater
                [~, response] = obj.send_Query( ...
                    sprintf("HTRSET?%.0f", n));
                Out_Heater_Conf.Connected(n) = n;
                response = str2num(response); %#ok<ST2NM>
                
                % Out_Heater_Conf.Type(n) = response(1);
                Out_Heater_Conf.Resistance(n)    = response(1);
                Out_Heater_Conf.MaxCurrent(n)    = response(2);
                Out_Heater_Conf.MaxUserCurrent(n)= response(3);
                Out_Heater_Conf.Display(n)       = response(4);
            end
            Out_ErrCode = obj.ErrCode(end);
            obj.Heater_Conf = Out_Heater_Conf;
            obj.error_Handling();
        end
        
        % Set Heater Configuration
        function Out_ErrCode = set_HeaterConf(obj, In_Heater_Conf)
            for n = 1 : length(In_Heater_Conf.Connected)
                command = sprintf("HTRSET%.0f,%.0f,%.0f,%.0f,+%.3f,%.0f", ...
                    In_Heater_Conf.Connected(n), ...
                    In_Heater_Conf.Type(n), ...
                    In_Heater_Conf.Resistance(n), ...
                    In_Heater_Conf.MaxCurrent(n), ...
                    In_Heater_Conf.MaxUserCurrent(n), ...
                    In_Heater_Conf.Display(n));
                obj.send_Command(command);
                pause(obj.Time_Wait)
                
                [~, response] = obj.send_Query(sprintf("HTRSET?%.0f", n));
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 2 * ~isequal( ...
                    str2num(extractBetween(command, 9, 22)), ... %#ok<ST2NM>
                    str2num(response));                  %#ok<ST2NM>
            end
            obj.get_HeaterConf();
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
        end
        
        % Set Target Heater Level
        function Out_ErrCode = set_HeaterLevelTarg(obj, In_Heater_Level_Targ)
            if length(In_Heater_Level_Targ) > obj.N_Heater
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 3;
                obj.error_Handling();
                In_Heater_Level_Targ = In_Heater_Level_Targ(1 : obj.N_Heater);
            end
            obj.Heater_Level_Targ = In_Heater_Level_Targ;
            Out_ErrCode = obj.ErrCode(end);
        end
        
        % Get Current Heater Levels
        function [Out_ErrCode, Out_Heater_Level] = get_HeaterLevel(obj)
            Out_Heater_Level = zeros(1, obj.N_Heater);
            for n = 1 : obj.N_Heater
                [~, response] = obj.send_Query(sprintf('RANGE?%.0f', n));
                Out_Heater_Level(n) = str2double(response);
            end
            obj.Heater_Level = Out_Heater_Level;
            Out_ErrCode = obj.ErrCode(end);
        end
        
        % Get Heater Percentages
        function [Out_ErrCode, Out_Heater_Percentage] = ...
                get_HeaterPercentage(obj)
            Out_Heater_Percentage = zeros(1, obj.N_Heater);
            for n = 1 : obj.N_Heater
                [~, response] = obj.send_Query(sprintf('HTR?%.0f', n));
                Out_Heater_Percentage(n) = str2double(response);
            end
            obj.Heater_Percentage = Out_Heater_Percentage;
            Out_ErrCode = obj.ErrCode(end);
        end
        
        % Turn Heaters ON/OFF
        function [Out_ErrCode, Out_Heater_Level] = set_HeaterONOFF(obj, ...
                In_Heater_ONOFF)
            if length(In_Heater_ONOFF) > obj.N_Heater
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 3;
                obj.error_Handling();
                In_Heater_ONOFF = In_Heater_ONOFF(1 : obj.N_Heater);
            end
            for n = 1 : length(In_Heater_ONOFF)
                obj.send_Command( ...
                    sprintf('RANGE%.0f,%.0f', ...
                    n, In_Heater_ONOFF * obj.Heater_Level_Targ(n)));
            end
            pause(obj.Time_Wait)
            [~, Out_Heater_Level] = obj.get_HeaterLevel();
            Out_Heater_Level = Out_Heater_Level(1 : length(In_Heater_ONOFF));
            
            obj.ErrCode = circshift(obj.ErrCode, -1);
            obj.ErrCode(end) = 2 * ~isequal( ...
                In_Heater_ONOFF * obj.Heater_Level_Targ( ...
                    1 : length(In_Heater_ONOFF)), ...
                Out_Heater_Level);
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
        end
        
        % Set Maximum User Current
        function Out_ErrCode = set_MaxUserCurrent(obj, In_MaxUserCurrent)
            obj.get_HeaterConf();
            if length(In_MaxUserCurrent) > obj.N_Heater
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 3;
                obj.error_Handling();
                In_MaxUserCurrent = In_MaxUserCurrent(1 : obj.N_Heater);
            end
            for n = 1 : length(In_MaxUserCurrent)
                obj.Heater_Conf.MaxCurrent(n) = 0;
                obj.Heater_Conf.MaxUserCurrent(n) = In_MaxUserCurrent(n);
            end
            obj.set_HeaterConf(obj.Heater_Conf);
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
        end
        
        % Get Temperature Sensor Configuration
        function [Out_ErrCode, Out_TempSensor_Conf] = ...
                get_TempSensorConf(obj)
            for n = 1 : obj.N_TempSensor
                [~, response] = obj.send_Query( ...
                    sprintf("INTYPE?%s", char(64 + n)));
                
                Out_TempSensor_Conf.Connected(n)    = char(64 + n);
                Out_TempSensor_Conf.Type(n)         = str2double( ...
                    extractBetween(response, 1, 1));
                Out_TempSensor_Conf.AutoRange(n)    = str2double( ...
                    extractBetween(response, 3, 3));
                Out_TempSensor_Conf.Range(n)        = str2double( ...
                    extractBetween(response, 5, 5));
                Out_TempSensor_Conf.Compensation(n) = str2double( ...
                    extractBetween(response, 7, 7));
                Out_TempSensor_Conf.Units(n)        = str2double( ...
                    extractBetween(response, 9, 9));
            end
            Out_ErrCode = obj.ErrCode(end);
            obj.TempSensor_Conf = Out_TempSensor_Conf;
        end
        
        % Set Temperature Sensor Configuration
        function Out_ErrCode = set_TempSensorConf(obj, In_TempSensor_Conf)
            if length(In_TempSensor_Conf.Connected) > obj.N_TempSensor
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 3;
                obj.error_Handling();
                In_TempSensor_Conf.Connected = ...
                    In_TempSensor_Conf.Connected(1 : obj.N_TempSensor);
            end
            for n = 1 : length(In_TempSensor_Conf.Connected)
                command = sprintf("INTYPE%s,%.0f,%.0f,%.0f,%.0f,%.0f", ...
                    In_TempSensor_Conf.Connected(n), ...
                    In_TempSensor_Conf.Type(n), ...
                    In_TempSensor_Conf.AutoRange(n), ...
                    In_TempSensor_Conf.Range(n), ...
                    In_TempSensor_Conf.Compensation(n), ...
                    In_TempSensor_Conf.Units(n));
                obj.send_Command(command);
                pause(obj.Time_Wait)
                [~, response] = obj.send_Query( ...
                    sprintf("INTYPE?%s", In_TempSensor_Conf.Connected(n)));
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 2 * ~isequal( ...
                    str2num(extractBetween(command, 9, 17)), ... %#ok<ST2NM>
                    str2num(response));                   %#ok<ST2NM>
            end
            obj.get_TempSensorConf();
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
        end
        
        % Get Target Temperature
        function [Out_ErrCode, Out_Temp_Targ] = get_TempTarg(obj)
            Out_Temp_Targ = zeros(1, obj.N_TempSensor);
            for n = 1 : obj.N_TempSensor
                [~, response] = obj.send_Query(sprintf("SETP?%.0f", n));
                Out_Temp_Targ(n) = str2double(response);
            end
            obj.Temp_Targ = Out_Temp_Targ;
            Out_ErrCode = obj.ErrCode(end);
        end
        
        % Set Target Temperature
        function Out_ErrCode = set_TempTarg(obj, In_Temp_Targ)
            if length(In_Temp_Targ) > obj.N_TempSensor
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 3;
                obj.error_Handling();
                In_Temp_Targ = In_Temp_Targ(1 : obj.N_TempSensor);
            end
            for n = 1 : length(In_Temp_Targ)
                obj.send_Command(sprintf("SETP%.0f,%.1f", n, In_Temp_Targ(n)));
            end
            pause(obj.Time_Wait)
            [~, temp_Targ] = obj.get_TempTarg();
            obj.ErrCode = circshift(obj.ErrCode, -1);
            obj.ErrCode(end) = 2 * ~isequal( ...
                temp_Targ(1 : length(In_Temp_Targ)), In_Temp_Targ);
            Out_ErrCode = obj.ErrCode(end);
            obj.error_Handling();
        end
        
        % Get Current Temperature Readings
        function [Out_ErrCode, Out_Temp] = get_Temp(obj, varargin)
            if isempty(varargin)
                In_Sensor_Select = char(64 + (1 : obj.N_TempSensor));
            else
                In_Sensor_Select = varargin{:};
            end
            if length(In_Sensor_Select) > obj.N_TempSensor
                obj.ErrCode = circshift(obj.ErrCode, -1);
                obj.ErrCode(end) = 3;
                obj.error_Handling();
                In_Sensor_Select = In_Sensor_Select(1 : obj.N_TempSensor);
            end
            [~, response] = obj.send_Query("KRDG?");
            
            obj.Temp = str2num(response); %#ok<ST2NM>
            Out_Temp = obj.Temp(double(In_Sensor_Select) - 64);
            
            Out_ErrCode = obj.ErrCode(end);
        end
        
        % Update all properties from instrument
        function Out_ErrCode = update_AllProperties(obj)
            obj.get_SerialNumber();
            obj.get_HeaterConf();
            obj.get_HeaterLevel();
            obj.get_HeaterPercentage();
            obj.get_TempSensorConf();
            obj.get_TempTarg();
            obj.get_Temp();
            Out_ErrCode = obj.ErrCode(end);
        end
    end
end
