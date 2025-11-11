function pbn = PBDictionary(type)
switch type
    case 'ctr0'
        pbn=1;
    case 'AWGTrig2'
        pbn=6;
    case 'FPGATrig'
        pbn=3;
    case 'dummy1'
        pbn=5;
    case 'AOM'
        pbn=2;
    case 'AWGTrig3' 
        pbn=8;
    case 'MWSwitch'
        pbn=4;
    case 'MWSwitch2'
        pbn=0;
    case 'MWSwitch3'
        pbn=7;
end
end