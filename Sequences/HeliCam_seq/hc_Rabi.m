function hc_Rabi
% hc_Rabi  Widefield lock-in Rabi for the HeliCam C4 (external DivideBy4).
%
% One lock-in period = 4 quarter bins of width Q (ns). PB emits a CamRef edge
% at every quarter boundary (-> HeliCam FI2). Quarter mapping:
%   Q1: init / reference laser (GreenAOM)
%   Q2: MW pulse of swept duration gmSEQ.m, dark otherwise
%   Q3: dark
%   Q4: readout / signal laser (GreenAOM)
% The whole period repeats gmSEQ.Repeat times (PB loop) per camera frame.
% Sweep parameter gmSEQ.m = MW on-time (ns); must fit inside one quarter bin.
%
% See docs/helicam_pulsed_measurement_notes.md (Example 1).

global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
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
wRef  = hc_CamRefWidth(cfg, Q);  % CamRef TTL width (ns); auto = Q/2
laser = gmSEQ.readout;           % init/readout laser duration (ns)
mwOff = gmSEQ.post_init_wait;    % delay of MW start into Q2 (ns)

assert(gmSEQ.m + mwOff < Q, ...
    'hc_Rabi: MW on-time (%g ns) + offset exceeds quarter bin (%g ns).', gmSEQ.m, Q);
assert(laser <= Q, ...
    'hc_Rabi: laser duration (%g ns) exceeds quarter bin (%g ns).', laser, Q);

% --- CamRef quarter-period train: one edge at the start of each quarter -----
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = wRef * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 3*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [laser, laser];

% --- MW pulse inside Q2 (swept duration) ------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = Q + mwOff;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = gmSEQ.m;

% --- Period length marker (4 quarter bins) ----------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();
