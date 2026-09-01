function pbn = PBDictionary(type)
switch type
    case 'ctr0'
        pbn=4;
    case 'dummy1'
        pbn=8;
    case 'GreenAOM'
        pbn=0;
    case 'MWSwitch'
        pbn=1;
    case 'MWSwitch2'
        pbn=2;
    case 'SRS1_I'
        pbn=5;
    case 'SRS2_I'
        pbn=6;
    case 'MWSwitchHP'
        pbn=3;
    case 'CamRef'   % HeliCam FI2: quarter-period reference train (DivideBy4)
        pbn=7;
end