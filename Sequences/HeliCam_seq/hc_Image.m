function hc_Image
% hc_Image  Simplest HeliCam widefield acquisition: a plain intensity image.
%
% Laser on in Q1 only; Q2/Q3/Q4 dark. Then the lock-in differentials reduce to
%   I = Q1 - Q3 = Q1   -> a direct camera image
%   Q = Q2 - Q4 = 0
% so the reference channel (mean I) is simply the field-of-view image. Use this
% to focus / align / check exposure before running hc_Rabi / hc_T1 / hc_ODMR.
%
% The quarter period comes from the GUI QP box (hc_QuarterBin) and the camera
% exposure from the GUI CtrGateDur box -- the same two sources every other hc_*
% sequence uses. QP sets how often the camera is triggered; CtrGateDur sets how
% long it integrates after each trigger.
%
% NOTE: this sequence no longer integrates the whole quarter automatically. It
% used to be special-cased so that exposure tracked QP, which made it the only
% sequence whose integration window could not be set independently. To recover
% the old whole-bin behaviour, set CtrGateDur equal to QP.
%
% (Frame-rate constraint still applies: QP should exceed the per-bin exposure
% plus ~2 us sensor overhead, else the camera drops data.)

global gmSEQ gSG
gSG.bfixedPow  = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Default axes2/axes3 quantity. Laser sits in Q1 (see below), so Q carries no
% signal here and the plain intensity image is the useful picture. Selecting this
% sequence seeds the 'WFcontrast' GUI box with this string; edit the box (even
% mid-run) to plot something else.
gmSEQ.WFcontrastExpr = 'I';

cfg  = WidefieldConfig();
Q    = hc_QuarterBin(cfg);       % quarter period (ns) = GUI QP field
wRef = hc_CamRefWidth(cfg, Q);   % CamRef TTL width (ns); auto = Q/2

% --- CamRef quarter-period train (one edge per quarter) ---------------------
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = wRef * ones(1, 4);

% --- Laser ON in Q1 only (init/reference); Q2/Q3/Q4 dark -------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [Q, 2*Q] - Q;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [Q, Q];     % laser fills Q1

% --- Period length marker (4 quarter bins) ----------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();
