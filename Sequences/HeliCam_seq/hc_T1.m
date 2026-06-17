function hc_T1
% hc_T1  Widefield lock-in T1 for the HeliCam C4 (external DivideBy4).
%
% Exposure (Q1/Q4 quarter width) is fixed; the swept dark wait gmSEQ.m is
% carried by the Q2+Q3 gap, so the effective lock-in period grows with tau
% while the per-bin exposure stays constant. Quarter mapping:
%   Q1: init / reference laser (GreenAOM), optional pi pulse after init
%   Q2: dark (first half of the wait)
%   Q3: dark (second half of the wait)
%   Q4: readout / signal laser (GreenAOM)
% CamRef edges at [0, Q1, Q1+m/2, Q1+m]; period repeats gmSEQ.Repeat times.
% Sweep parameter gmSEQ.m = dark wait (ns).
%
% See docs/helicam_pulsed_measurement_notes.md (Example 2).

global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

cfg = WidefieldConfig();
% Init/readout quarter width: configurable here via gmSEQ.quarterBinNs (to be
% linked to a GUI edit field); falls back to the WidefieldConfig default if unset.
if isfield(gmSEQ,'quarterBinNs') && ~isempty(gmSEQ.quarterBinNs)
    Qbin = gmSEQ.quarterBinNs;
else
    Qbin = cfg.quarterBinNs;
end
wRef  = cfg.camRefWidthNs;       % CamRef TTL width (ns)
laser = gmSEQ.readout;           % init/readout laser duration (ns)
piDur = gmSEQ.pi;                % pi pulse duration (ns); 0 for plain S00 T1
tau   = gmSEQ.m;                 % swept dark wait (ns)

assert(laser <= Qbin, ...
    'hc_T1: laser duration (%g ns) exceeds init quarter bin (%g ns).', laser, Qbin);
assert(piDur <= Qbin - laser, ...
    'hc_T1: pi pulse (%g ns) does not fit after init in Q1 (%g ns).', piDur, Qbin - laser);

halfTau = tau / 2;
% Quarter boundaries: Q1 start=0, Q2 start=Qbin, Q3 start=Qbin+halfTau, Q4 start=Qbin+tau
tQ4 = Qbin + tau;
periodLen = tQ4 + Qbin;

% --- CamRef quarter-period train --------------------------------------------
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Qbin, Qbin + halfTau, tQ4];
gmSEQ.CHN(1).DT    = wRef * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, tQ4];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [laser, laser];

% --- Optional pi pulse in Q1, right after init ------------------------------
if piDur > 0
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN = PBDictionary('MWSwitch');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T     = laser;
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT    = piDur;
end

% --- Period length marker ---------------------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, periodLen];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();
