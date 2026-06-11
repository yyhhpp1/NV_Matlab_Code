function SignalGeneratorFunctionPool3(varargin)

switch varargin{1}
    case 'Init'                            
        Init(); 
    case 'InitGUI'
        InitGUI(varargin{2},varargin{3});
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
end

function InitGUI(port, handles)
    Init(port);
    StrL{1}='External';
    StrL{numel(StrL)+1}='Triangle';
    StrL{numel(StrL)+1}='Ramp';
    StrL{numel(StrL)+1}='Sine';
    StrL{numel(StrL)+1}='Noise';
    set(handles.puModSrc,'String',StrL);
    clear StrL
    StrL{1}='None';
    StrL{numel(StrL)+1}='IQ';
    StrL{numel(StrL)+1}='Sweep';
    set(handles.puMod,'String',StrL);
    clear StrL

function Init()
% This function initializes the SRS SG384 to the serial object gSG (a
% global serial). You specify PORT with a string such as 'com4'. It sets
% the baud rate and fcloses the device to prevent the possibility of
% fopening twice.
global gSG3;  
% Find a serial port object.
gSG3.device = tcpclient(PortMap('SG3 ip'), 5025);

% Check the connection
IDN();

function IDN()
global gSG3
writeline(gSG3.device, '*IDN?')
disp(readline(gSG3.device)) % Successful connection to the AWG

function Query() % To be upgraded
global gSG3
% To be upgraded
% 	writeline(gSG.device,'AMPR?'); gSG.qPow = str2double(fscanf(gSG.device));
% 	writeline(gSG.device,'FREQ?'); gSG.qFreq = str2double(fscanf(gSG.device));
% 	writeline(gSG.device,'ENBR?'); gSG.qbOn = str2double(fscanf(gSG.device));
%     writeline(gSG.device,'MODL?');
%     if str2double(fscanf(gSG.device))
%         writeline(gSG.device,'TYPE?');
%         switch str2double(fscanf(gSG.device))
%             case 0
%                 gSG.qbMod='AM';
%             case 1
%                 gSG.qbMod='FM';
%             case 2
%                 gSG.qbMod='Phase';
%             case 3
%                 gSG.qbMod='Sweep';
%                 writeline(gSG.device,'SRAT?'); gSG.qSweepRate = str2double(fscanf(gSG.device));
%                 writeline(gSG.device,'SDEV?'); gSG.qSweepDev = str2double(fscanf(gSG.device));
%                 writeline(gSG.device,'SFNC?'); 
%                 switch str2double(fscanf(gSG.device))
%                     case 0
%                         gSG.qModSrc = 'Sine';
%                     case 1
%                         gSG.qModSrc = 'Ramp';
%                     case 2
%                         gSG.qModSrc = 'Triangle';
%                     case 5
%                         gSG.qModSrc = 'External';
%                 end
%             case 4
%                 gSG.qbMod='Pulse';
%             case 5
%                 gSG.qbMod='Blank';
%             case 6
%                 gSG.qbMod='IQ';
%                 writeline(gSG.device,'QFNC?'); 
%                 switch str2double(fscanf(gSG.device))
%                     case 4
%                         gSG.qModSrc = 'Noise';
%                     case 5
%                         gSG.qModSrc = 'External';
%                 end
%         end
%     else
%         gSG.qbMod='None';
%     end
% 	writeline(gSG.device,'*ESR?'); gSG.qErr(1) = str2double(fscanf(gSG.device));
% 	writeline(gSG.device,'INSR?'); gSG.qErr(2) = str2double(fscanf(gSG.device));
% 	writeline(gSG.device,'*CLS');


function WritePow()
global gSG3
if gSG3.Pow>16
    error('Microwave amplitude is probably too large')
end  
writeline(gSG3.device, strcat('AMPR ', num2str(gSG3.Pow)));


function WriteFreq()
global gSG3

if or(gSG3.Freq<950000,gSG3.Freq>6050000000) % hardware limit of the N-type output
    error('Microwave frequency is out of bounds');
end
writeline(gSG3.device, strcat('FREQ ',num2str(gSG3.Freq)));


function SetMod()
global gSG3
try
    switch gSG3.bMod
        case 'IQ'
            writeline(gSG3.device,'MODL 1');
            writeline(gSG3.device,'TYPE 6');
            switch gSG3.bModSrc
                case 'External'
                    writeline(gSG3.device,'QFNC 5');
                    writeline(gSG3.device,'COUP 1');
                case 'Noise'
                    writeline(gSG3.device,'QFNC 4');
                otherwise
                    error('Modulation source is not supported by IQ.')
            end
        case 'Sweep'
            if ~SweepCheck()
                error('The frequency range is not correct!');
            end
            writeline(gSG3.device,'TYPE 3');
            writeline(gSG3.device,'MODL 1');
            
            switch gSG3.bModSrc
                case 'External'
                    writeline(gSG3.device,'SFNC 5');
                    writeline(gSG3.device,'COUP 1');
                case 'Sine'
                    writeline(gSG3.device,'SFNC 0');
                case 'Ramp'
                    writeline(gSG3.device,'SFNC 1');
                case 'Triangle'
                    writeline(gSG3.device,'SFNC 2');
                otherwise
                    error('Modulation source is not supported by Sweep.')
            end
            writeline(gSG3.device,strcat('SDEV ',num2str(gSG3.sweepDev)));
            writeline(gSG3.device,strcat('SRAT ',num2str(gSG3.sweepRate)));
        otherwise
            writeline(gSG3.device,'MODL 0');
    end
catch ME
	rethrow(ME);
end

function bValid = SweepCheck() % Check whether the sweeping range is legal
% The following criteria is only for SRS386. The scaling range of SRS384 is
% different!
global gSG3
from = gSG3.Freq - gSG3.sweepDev;
to = gSG3.Freq + gSG3.sweepDev; 
bValid = false;
if from >= 0.7e9 && to <= 0.759375e9
    bValid = true;
elseif from >= 0.759375e9 && to <= 1.51875e9
    bValid = true;
elseif from >= 1.51875e9 && to <= 3.0375e9
    bValid = true;
elseif from >= 3.0375e9 && to <= 6e9
    bValid = true;
end


function RFOnOff()
global gSG3

if (gSG3.Pow>16 && ~strcmp(gSG3.bMod,'IQ')) % || (strcmp(gSG3.bMod,'IQ') && strcmp(gSG3.bModSrc,'Noise'))
    fclose(gSG3.device);
    error('NO ONE MAN SHOULD HAVE ALL THAT POWER')
end
try
	writeline(gSG3.device,strcat('ENBR ',num2str(gSG3.bOn)));
catch ME
	rethrow(ME);
end
