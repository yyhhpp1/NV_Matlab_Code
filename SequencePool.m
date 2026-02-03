function varargout = SequencePool(varargin)
global gmSEQ
if isfield(gmSEQ,'CHN')&& ~isequal(varargin{1},'PBDictionary')
    gmSEQ=rmfield(gmSEQ,'CHN');
end
if isfield(gmSEQ,'bLiO') && ~isequal(varargin{1},'PBDictionary')
    gmSEQ=rmfield(gmSEQ,'bLiO');
end
switch varargin{1}
    case 'PopulateSeq'
        varargout{1} = PopulateSeq();
    case 'Rabi'
        Rabi();
    case 'Ramsey'
        Ramsey();
    case 'AOM Delay'
        AOMDelay();
    case 'Echo'
        Echo();
    case 'ESR'
        ESR();
    case 'PulseESR'
        PulsedESR();
    case 'T1_S00_S01_S10'
        T1_S00_S01_S10();   
    case 'PBDictionary'
        varargout{1}=PBDictionary(varargin{2});
    case 'CtrDur'
        CtrDur();
    case 'CtrDelay'
        CtrDelay();
    case 'Pulsed ESR'
        PESR();
    case 'f_Rabi'
        f_Rabi();
    case 'f_PiCali'
        f_PiCali();
    case 'f_PiCali_for_decay'
        f_PiCali_for_decay();
    case 'f_PulsedESR'
        f_PulsedESR();
    case 'f_T1_S00_S01_S10'
        f_T1_S00_S01_S10();
    case 'f_Spin_Locking'
        f_Spin_Locking();
    case 'f_Spin_Locking_tomo'
        f_Spin_Locking_tomo();
    case 'f_InitDurCali'
        f_InitDurCali();
    case 'f_TimeCali'
        f_TimeCali();
    case 'f_FPGA_clock_test'
        f_FPGA_clock_test();
    case 'f_FPGA_delay'
        f_FPGA_delay();
    case 'Select Sequence'
        return
        
end

function StrL = PopulateSeq

StrL{1} = 'Select Sequence';
StrL{numel(StrL)+1}='--------------SRS---------------';
StrL{numel(StrL)+1}='ESR';
StrL{numel(StrL)+1}='PulseESR';
StrL{numel(StrL)+1}='Rabi';
StrL{numel(StrL)+1}='Ramsey';
StrL{numel(StrL)+1}='Echo';
StrL{numel(StrL)+1}='T1_S00_S01_S10';
StrL{numel(StrL)+1}='--------------FPGA--------------';
StrL{numel(StrL)+1}='f_Rabi';
StrL{numel(StrL)+1}='f_PiCali';
StrL{numel(StrL)+1}='f_PiCali_for_decay';
StrL{numel(StrL)+1}='f_PulsedESR';
StrL{numel(StrL)+1}='f_Ramsey';
StrL{numel(StrL)+1}='f_Echo';
StrL{numel(StrL)+1}='f_T1_S00_S01_S10';
StrL{numel(StrL)+1}='f_Spin_Locking';
StrL{numel(StrL)+1}='f_Spin_Locking_tomo';
StrL{numel(StrL)+1}='f_InitDurCali';
StrL{numel(StrL)+1}='f_TimeCali';
StrL{numel(StrL)+1}='f_FPGA_clock_test';
StrL{numel(StrL)+1}='f_FPGA_delay';
StrL{numel(StrL)+1}='----------Calibrations----------';
StrL{numel(StrL)+1}='CtrDur';
StrL{numel(StrL)+1}='AOMDelay';
StrL{numel(StrL)+1}='CtrDelay';









