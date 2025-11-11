  function path=PortMap(what)

switch what
    case 'BackupFile'
        path='C:\MATLAB_Code\Data\TempDataBackup\Temp.mat';
    case 'BackupImageFile'
        path='C:\MATLAB_Code\Data\TempDataBackup\TempImage.mat';
    case 'Ctr Gate'
        path='/Dev3/PFI1';  
    case 'SG ext mod'
        path='Dev3/ao2';
    case 'Ctr Trig'
        path='/Dev3/PFI13'; 
    case 'SG com'
        path='com32'; 
    case 'SG com 2'
        path='com9';
    case 'SG com 3'
        path='com14';
    case 'meas'
        path='APD'; 
    case 'SPCM' 
        path='/Dev3/PFI0';
    case 'gConfocal path'
        path='C:\MATLAB_Code\Sets\';
    case 'APD in'
        path='Dev3/ai0';
    case 'Ctr in'
        path='Dev3/ctr3'; %ejd 1/4/2022 crt3 --> ctr2; 4/5/2023 WJ ctr3 --> ctr0 // --> ctr3
    case 'Ctr out'
        path='Dev3/ctr1'; %ejd 1/4/2022 crt1 --> ctr2 
    case 'Galvo x'
        path='Dev3/ao0';
    case 'Galvo y'
        path='Dev3/ao1';
    case 'Piezo' % added by Weijie 09/21/2021 single-NV
        path='0121026985'; % serial number
    case 'spinapi'
        path='C:\SpinCore\SpinAPI\include\spinapi.h';
    case 'pulseblaster'
        path='C:\SpinCore\SpinAPI\include\pulseblaster.h';
    case 'dds'
        path='C:\SpinCore\SpinAPI\include\dds.h';
    case 'Data'
        path='C:\Data\';
    case 'Ctr src'
        path='/Dev3/PFI0'; 
    case 'Ctr gate'
        path='/Dev3/PFI1'; 
    case 'LF save'
        path='C:\Users\rt2\Documents\LightField\';
    case 'Scope'
        path='USB0::0x0957::0x9005::MY51260103::0::INSTR';
    case 'keithleyX'
        path='USB0::0x05E6::0x2200::9210717::INSTR';
    case 'keithleyY'
        path='USB0::0x05E6::0x2200::9210730::INSTR';
    case 'keithleyZ'
        path='USB0::0x05E6::0x2200::9210599::INSTR';
end