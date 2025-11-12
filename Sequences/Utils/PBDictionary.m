function pbn = PBDictionary(type)
switch type
    case 'ctr0'
        pbn=1;
    case 'FPGATrig'
        pbn=3;
    case 'dummy1'
        pbn=8;
    case 'GreenAOM'
        pbn=2;
    case 'MWSwitch'
        pbn=4;
end
end