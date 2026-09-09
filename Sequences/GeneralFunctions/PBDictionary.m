function pbn = PBDictionary(type)
switch type
    case 'ctr0'
        pbn=4;
    case 'dummy1'
        % Program-length marker only -- never cabled to anything. Moved off pin 8
        % on 2026-09-04 to free that pin for CamTrig (below). Every hc_* and
        % confocal sequence uses this channel purely to hold the program open to a
        % fixed length (see AcquireDarkRef in RunSequence.m, which relies on the
        % marker rather than the laser defining the span), so the pin number is
        % arbitrary as long as nothing else drives it.
        pbn=9;
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
    case 'CamTrig'
        % IDS uEye+ U3-3140CP-M, physical GPIO1 (= GenICam Line2, LVTTL).
        % ONE rising edge per camera frame: an ids_* sequence emits two per PB
        % program run, opening the signal frame and then the reference frame.
        % Line2 (not the opto-coupled Line0) because opto turn-on/turn-off is
        % microsecond-scale, asymmetric and temperature-dependent.
        pbn=8;
end
