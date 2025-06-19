function SignalGeneratorFunctionPool(varargin)

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
global gSG2;  
% Find a serial port object.
gSG2.device = tcpclient(PortMap('SG2 ip'), 5025);

% Check the connection
IDN();

function IDN()
global gSG2
writeline(gSG2.device, '*IDN?')
disp(readline(gSG2.device)) % Successful connection to the AWG

function Query() % To be upgraded
global gSG2
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
global gSG2
if gSG2.Pow>0
    error('Microwave amplitude is probably too large')
end  
writeline(gSG2.device, strcat('AMPR ', num2str(gSG2.Pow)));


function WriteFreq()
global gSG2

if or(gSG2.Freq<950000,gSG2.Freq>6050000000) % hardware limit of the N-type output
    error('Microwave frequency is out of bounds');
end
writeline(gSG2.device, strcat('FREQ ',num2str(gSG2.Freq)));


function SetMod()
global gSG2
try
    switch gSG2.bMod
        case 'IQ'
            writeline(gSG2.device,'MODL 1');
            writeline(gSG2.device,'TYPE 6');
            switch gSG2.bModSrc
                case 'External'
                    writeline(gSG2.device,'QFNC 5');
                    writeline(gSG2.device,'COUP 1');
                case 'Noise'
                    writeline(gSG2.device,'QFNC 4');
                otherwise
                    error('Modulation source is not supported by IQ.')
            end
        case 'Sweep'
            if ~SweepCheck()
                error('The frequency range is not correct!');
            end
            writeline(gSG2.device,'TYPE 3');
            writeline(gSG2.device,'MODL 1');
            
            switch gSG2.bModSrc
                case 'External'
                    writeline(gSG2.device,'SFNC 5');
                    writeline(gSG2.device,'COUP 1');
                case 'Sine'
                    writeline(gSG2.device,'SFNC 0');
                case 'Ramp'
                    writeline(gSG2.device,'SFNC 1');
                case 'Triangle'
                    writeline(gSG2.device,'SFNC 2');
                otherwise
                    error('Modulation source is not supported by Sweep.')
            end
            writeline(gSG2.device,strcat('SDEV ',num2str(gSG2.sweepDev)));
            writeline(gSG2.device,strcat('SRAT ',num2str(gSG2.sweepRate)));
        otherwise
            writeline(gSG2.device,'MODL 0');
    end
catch ME
	rethrow(ME);
end

function bValid = SweepCheck() % Check whether the sweeping range is legal
% The following criteria is only for SRS386. The scaling range of SRS384 is
% different!
global gSG2
from = gSG2.Freq - gSG2.sweepDev;
to = gSG2.Freq + gSG2.sweepDev; 
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
global gSG2

if (gSG2.Pow>0 && ~strcmp(gSG2.bMod,'IQ')) % || (strcmp(gSG2.bMod,'IQ') && strcmp(gSG2.bModSrc,'Noise'))
    fclose(gSG2.device);
    error('NO ONE MAN SHOULD HAVE ALL THAT POWER')
end
try
	writeline(gSG2.device,strcat('ENBR ',num2str(gSG2.bOn)));
catch ME
	rethrow(ME);
end
