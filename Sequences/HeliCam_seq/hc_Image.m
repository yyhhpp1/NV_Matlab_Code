function hc_Image
% hc_Image  Simplest HeliCam widefield acquisition: a plain intensity image.
%
% Laser on in Q1 only; Q2/Q3/Q4 dark. Then the lock-in differentials reduce to
%   I = Q1 - Q3 = Q1   -> a direct camera image
%   Q = Q2 - Q4 = 0
% so the reference channel (mean I) is simply the field-of-view image. Use this
% to focus / align / check exposure before running hc_Rabi / hc_T1 / hc_ODMR.
%
% The quarter-bin width is set to the GUI readout time, and the laser fills Q1.
% (Frame-rate constraint still applies: readout should exceed the per-bin
% exposure plus ~2 us sensor overhead, else the camera drops data.)

global gmSEQ gSG
gSG.bfixedPow  = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

cfg  = WidefieldConfig();
Q    = gmSEQ.readout;            % quarter bin = GUI readout time (ns)
wRef = hc_CamRefWidth(cfg, Q);   % CamRef TTL width (ns); auto = Q/2

% --- CamRef quarter-period train (one edge per quarter) ---------------------
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = wRef * ones(1, 4);

% --- Laser ON in Q1 only (init/reference); Q2/Q3/Q4 dark -------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 0;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = Q;     % laser fills Q1

% --- Period length marker (4 quarter bins) ----------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();
