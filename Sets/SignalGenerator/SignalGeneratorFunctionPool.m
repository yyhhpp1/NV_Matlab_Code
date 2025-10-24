function SignalGeneratorFunctionPool(varargin)
% This code is an organized version of the 
% SignalGeneratorFunctionPool_tcpip
% Written by ChatGPT 5

% Dispatcher (unchanged entry points)
switch varargin{1}
    case 'Init'
        if numel(varargin) >= 2
            Init(varargin{2});
        else
            Init();
        end
    case 'InitGUI'
        InitGUI(varargin{2}, varargin{3});
    case 'IDN'
        IDN();
    case 'Query'
        Query();
    case 'WritePow'
        WritePow();
    case 'WriteFreq'
        WriteFreq();
    case 'SetMod'
        SetMod();
    case 'RFOnOff'
        RFOnOff();
    case 'CloseConnection'
        closeDeviceIfAny();
end

%% ======================== UI / WRAPPERS ================================
function InitGUI(port, handles)
    Init(port);

    StrL{1} = 'External';
    StrL{end+1} = 'Triangle';
    StrL{end+1} = 'Ramp';
    StrL{end+1} = 'Sine';
    StrL{end+1} = 'Noise';
    set(handles.puModSrc, 'String', StrL);
    clear StrL

    StrL{1} = 'None';
    StrL{end+1} = 'IQ';
    StrL{end+1} = 'Sweep';
    set(handles.puMod, 'String', StrL);
    clear StrL

%% ======================== CORE SETUP ===================================
function Init(varargin)
% Init([ipOrHost])
% Initializes the SRS SG384 connection into global gSG.device using tcpclient.
% If ip/host not provided, it falls back to PortMap('SG ip').
    global gSG

    if nargin>=1 && ~isempty(varargin{1})
        ipOrHost = varargin{1};
    else
        ipOrHost = PortMap('SG ip'); 
    end
    tcpPort = 5025;

    % Store endpoint for future auto-reconnects
    gSG.ip   = ipOrHost;
    gSG.port = tcpPort;

    % Close any prior connection
    closeDeviceIfAny();

    % Create new connection
    gSG.device = tcpclient(gSG.ip, gSG.port);

    % Quick smoke test
    IDN();

%% ======================== BASIC QUERIES ================================
function IDN()
    global gSG
    ensureConnected(); % will reconnect if needed
    safeWrite('*IDN?');
    idn = safeReadline();
    disp(strtrim(idn));

function Query()
% Placeholder for future upgrades (kept as-is stylistically)
    global gSG 
    % Example template for later:
    % safeWrite('AMPR?'); gSG.qPow  = str2double(safeReadline());
    % safeWrite('FREQ?'); gSG.qFreq = str2double(safeReadline());
    % safeWrite('ENBR?'); gSG.qbOn  = str2double(safeReadline());

%% ======================== WRITE COMMANDS ===============================
function WritePow()
    global gSG
    ensureConnected();
    validatePow();
    safeWrite(strcat('AMPR ', num2str(gSG.Pow)));

function WriteFreq()
    global gSG
    ensureConnected();
    validateFreq();
    safeWrite(strcat('FREQ ', num2str(gSG.Freq)));

function SetMod()
    global gSG
    ensureConnected();
    try
        switch gSG.bMod
            case 'IQ'
                safeWrite('MODL 1');
                safeWrite('TYPE 6');
                switch gSG.bModSrc
                    case 'External'
                        safeWrite('QFNC 5');
                        safeWrite('COUP 1');
                    case 'Noise'
                        safeWrite('QFNC 4');
                    otherwise
                        error('Modulation source is not supported by IQ.');
                end

            case 'Sweep'
                if ~SweepCheck()
                    error('The frequency range is not correct!');
                end
                safeWrite('TYPE 3');
                safeWrite('MODL 1');

                switch gSG.bModSrc
                    case 'External'
                        safeWrite('SFNC 5');
                        safeWrite('COUP 1');
                    case 'Sine'
                        safeWrite('SFNC 0');
                    case 'Ramp'
                        safeWrite('SFNC 1');
                    case 'Triangle'
                        safeWrite('SFNC 2');
                    otherwise
                        error('Modulation source is not supported by Sweep.');
                end
                safeWrite(strcat('SDEV ', num2str(gSG.sweepDev)));
                safeWrite(strcat('SRAT ', num2str(gSG.sweepRate)));

            otherwise
                safeWrite('MODL 0');
        end
    catch ME
        rethrow(ME);
    end

function bValid = SweepCheck()
% Validate sweep span vs band (values retained from your original)
    global gSG
    from = gSG.Freq - gSG.sweepDev;
    to   = gSG.Freq + gSG.sweepDev;
    bValid = false;

    if from >= 0.7e9     && to <= 0.759375e9, bValid = true; return; end
    if from >= 0.759375e9 && to <= 1.51875e9, bValid = true; return; end
    if from >= 1.51875e9  && to <= 3.0375e9,  bValid = true; return; end
    if from >= 3.0375e9   && to <= 6e9,       bValid = true; return; end

function RFOnOff()
    global gSG
    ensureConnected();

    % Safety interlock logic preserved; properly close tcpclient if tripped
    if (gSG.Pow > 0 && ~strcmp(gSG.bMod, 'IQ')) || isnan(gSG.Pow)
        closeDeviceIfAny();
        error('NO ONE MAN SHOULD HAVE ALL THAT POWER');
    end

    try
        safeWrite(strcat('ENBR ', num2str(gSG.bOn)));
    catch ME
        rethrow(ME);
    end

%% ======================== AUTO-RECONNECT HELPERS =======================
function ensureConnected()
% Ensures gSG.device exists and is usable. Reconnects if not.
    global gSG
    if ~isfield(gSG, 'device') || isempty(gSG.device)
        reconnect();
        return
    end

    % Lightweight ping: try *OPC?; if fails, reconnect
    try
        writeline(gSG.device, '*OPC?');
        readline(gSG.device);
    catch
        reconnect();
    end

function safeWrite(cmd)
% Write with automatic reconnect on failure.
    global gSG
    attempts = 0; maxAttempts = 3;
    while true
        try
            writeline(gSG.device, cmd);
            return
        catch
            attempts = attempts + 1;
            if attempts >= maxAttempts
                % Final attempt: reconnect then one last write
                reconnect();
                try
                    writeline(gSG.device, cmd);
                    return
                catch ee
                    error('Write failed after reconnect: %s', ee.message);
                end
            else
                reconnect();
            end
        end
    end

function resp = safeReadline()
% Read with automatic reconnect on failure.
    global gSG
    attempts = 0; maxAttempts = 3;
    while true
        try
            resp = readline(gSG.device);
            return
        catch
            attempts = attempts + 1;
            if attempts >= maxAttempts
                reconnect();
                try
                    resp = readline(gSG.device);
                    return
                catch ee
                    error('Read failed after reconnect: %s', ee.message);
                end
            else
                reconnect();
            end
        end
    end

function reconnect()
% Close and reopen using stored gSG.ip / gSG.port
    global gSG
    ip = '0.0.0.0'; prt = 5025;
    if isfield(gSG, 'ip') && ~isempty(gSG.ip),   ip  = gSG.ip;  end
    if isfield(gSG, 'port') && ~isempty(gSG.port), prt = gSG.port; end

    closeDeviceIfAny();

    backoffs = [0.25 0.5 1.0 2.0]; % seconds
    lastErr  = '';
    for k = 1:numel(backoffs)
        try
            gSG.device = tcpclient(ip, prt, "Timeout", 5);
            % sanity ping
            writeline(gSG.device, '*OPC?');
            readline(gSG.device);
            return
        catch ME
            lastErr = ME.message; %#ok<NASGU>
            pause(backoffs(k));
        end
    end
    % one final attempt
    try
        gSG.device = tcpclient(ip, prt, "Timeout", 5);
        writeline(gSG.device, '*OPC?');
        readline(gSG.device);
    catch ME
        error('Reconnect failed: %s', ME.message);
    end

function closeDeviceIfAny()
% Proper cleanup for tcpclient
    global gSG
    if isfield(gSG, 'device') && ~isempty(gSG.device)
        try
            delete(gSG.device);
        catch
            % ignore cleanup errors
        end
    end

%% ======================== VALIDATION HELPERS ===========================
function validateFreq()
    global gSG
    if or(gSG.Freq < 950000, gSG.Freq > 6050000000)
        error('Microwave frequency is out of bounds');
    end

function validatePow()
    global gSG
    if gSG.Pow > 0
        error('Microwave amplitude is probably too large');
    end
