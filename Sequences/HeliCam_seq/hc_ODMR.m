function hc_ODMR
% hc_ODMR  Widefield lock-in pulsed ODMR for the HeliCam C4 (external DivideBy4).
%
% Identical quarter-bin layout to hc_Rabi, but the MW duration is FIXED at the
% pi pulse length; the swept quantity gmSEQ.m is the MW FREQUENCY (GHz), which
% the HeliCam RunSequence branch applies to the signal generator per point.
% Quarter mapping:
%   Q1: init / reference laser (GreenAOM)
%   Q2: pi pulse (fixed), dark otherwise
%   Q3: dark
%   Q4: readout / signal laser (GreenAOM)
% The whole period repeats gmSEQ.Repeat times (PB loop) per camera frame.

global gmSEQ gSG
gSG.bfixedPow  = 1;
gSG.bfixedFreq = 0;      % frequency is swept (set on the SG per point)
gSG.bMod = 'LOL';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

cfg = WidefieldConfig();
% Quarter-bin spacing: configurable here via gmSEQ.quarterBinNs (to be linked to
% a GUI edit field); falls back to the WidefieldConfig default if unset.
if isfield(gmSEQ,'quarterBinNs') && ~isempty(gmSEQ.quarterBinNs)
    Q = gmSEQ.quarterBinNs;
else
    Q = cfg.quarterBinNs;
end
wRef  = cfg.camRefWidthNs;       % CamRef TTL width (ns)
laser = gmSEQ.readout;           % init/readout laser duration (ns)
mwOff = gmSEQ.post_init_wait;    % delay of MW start into Q2 (ns)
piDur = gmSEQ.pi;                % fixed pi pulse duration (ns)

assert(piDur + mwOff < Q, ...
    'hc_ODMR: pi pulse (%g ns) + offset exceeds quarter bin (%g ns).', piDur, Q);
assert(laser <= Q, ...
    'hc_ODMR: laser duration (%g ns) exceeds quarter bin (%g ns).', laser, Q);

% --- CamRef quarter-period train --------------------------------------------
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = wRef * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 3*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [laser, laser];

% --- Fixed pi pulse inside Q2 -----------------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = Q + mwOff;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = piDur;

% --- Period length marker ---------------------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();
