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
    case 'Select Sequence'
        return
        
end

function StrL = PopulateSeq

StrL{1} = 'Select Sequence';
StrL{numel(StrL)+1}='--------------SRS---------------';
StrL{numel(StrL)+1}='ESR';
StrL{numel(StrL)+1}='Rabi';
StrL{numel(StrL)+1}='Ramsey';
StrL{numel(StrL)+1}='Echo';
StrL{numel(StrL)+1}='--------------FPGA--------------';
StrL{numel(StrL)+1}='f_Rabi';
StrL{numel(StrL)+1}='f_Ramsey';
StrL{numel(StrL)+1}='f_Echo';
StrL{numel(StrL)+1}='----------Calibrations----------';
StrL{numel(StrL)+1}='CtrDur';
StrL{numel(StrL)+1}='AOMDelay';
StrL{numel(StrL)+1}='CtrDelay';









