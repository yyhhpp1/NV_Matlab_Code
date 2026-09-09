function nFail = ids_SelfTest()
% ids_SelfTest  Hardware-free check of the IDS widefield integration.
%
%   ids_SelfTest          % prints a report
%   n = ids_SelfTest      % ... and returns the failure count
%
% Runs with no camera, no PulseBlaster and no Python. Three parts:
%
%   1. The frame-time model against every measured ROI in CAMERA_FINDINGS.md
%      sec.4.1, so a change that drifts away from the hardware is caught here
%      rather than in the field as intermittent dropped triggers.
%   2. Every ids_* sequence built with a mock gmSEQ -- trigger count and
%      spacing, laser count, MW confined to the SIGNAL block, length marker,
%      nothing overrunning the program -- plus proof that impossible sweep
%      points are REFUSED rather than silently truncated.
%   3. The FakeIDSCamera protocol, including the sign convention (both
%      quadratures positive) that separates this path from the HeliCam's.
%
% Run it after touching anything in mytoolboxes/IDSCam or Sequences/IDSCam_seq.

% gSG is set by mockSEQ, which declares its own global; only gmSEQ is read here.
global gmSEQ %#ok<GVMIS>

here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(here));
addpath(here);
addpath(fullfile(root, 'Sequences', 'IDSCam_seq'));
addpath(fullfile(root, 'Sequences', 'GeneralFunctions'));
addpath(root);

fail = 0;

% ===== 1. frame-time model vs measured ==================================== %
fprintf('===== frame-time model vs findings sec.4.1 =====\n');
cases = {1280,1024,'Mono10',6685; 1280,512,'Mono10',3344; 1280,256,'Mono10',1674; ...
         1280,64,'Mono10',472;   640,256,'Mono10',970;   512,256,'Mono10',855; ...
         256,256,'Mono10',656; ...
         1280,256,'Mono8',1540;  1280,64,'Mono8',470};
% 4% rather than 1%: 256x256 is a known -3.5% outlier and the tolerance has to
% admit the model as it actually is. See the accuracy table in ids_FrameTimeNs.
tolPct = 4;
for k = 1:size(cases,1)
    [t, fi] = ids_FrameTimeNs(cases{k,1}, cases{k,2}, cases{k,3}, 0);
    pred = t/1000; meas = cases{k,4};
    err  = 100*(pred-meas)/meas;
    bad  = abs(err) > tolPct;
    fprintf('  %4dx%-4d %-7s pred %8.1f us  meas %8.1f us  %+6.1f%%  (%s)%s\n', ...
            cases{k,1}, cases{k,2}, cases{k,3}, pred, meas, err, fi.bound, ...
            ternStr(bad, '   <-- OFF', ''));
    fail = fail + bad;
end

% ===== 2. exposure grid =================================================== %
fprintf('\n===== exposure grid =====\n');
[~, ~, gi] = ids_ExposureGrid(0, 1280);
fprintf('  quantum %.4f ns (expect 5555.5556)\n', gi.quantumNs);
fail = fail + (abs(gi.quantumNs - 400/72e6*1e9) > 1e-6);

for W = [256 512 640 1280]
    [~, ~, g] = ids_ExposureGrid(0, W);
    onGrid = abs(mod(g.minNs, gi.quantumNs)) < 1e-6;
    fprintf('  min @ W=%-5d %7.1f ns  on-grid %s\n', W, g.minNs, tern(onGrid));
    fail = fail + ~onGrid;
end

% 'floor' must never round up -- every caller is fitting inside a fixed block.
e = ids_ExposureGrid(100000, 256, 'floor');
fprintf('  floor(100000) = %.1f ns, never rounds up %s\n', e, tern(e <= 100000));
fail = fail + (e > 100000);

% ===== 3. block plan ====================================================== %
fprintf('\n===== block plan (IDSConfig defaults) =====\n');
cfg  = IDSConfig();
plan = ids_BlockPlan(cfg, ids_ShotNs(cfg), true);
N    = cfg.shotsPerBlock;

fprintf('\n  invariants:\n');
inv = { 'every shot inside the exposure window', plan.shotTrainNs <= plan.expoNs; ...
        'camera free before the next trigger',   plan.expoNs + plan.deadNs + ...
                                                 plan.quantumNs <= plan.blockNs; ...
        'margin >= one quantisation quantum',    plan.marginNs >= plan.quantumNs; ...
        'inside the rate ceiling',               plan.rateFraction <= cfg.maxRateFraction; ...
        'program = 2 blocks',                    plan.programNs == 2*plan.blockNs; ...
        'exposure is on the grid',               abs(mod(plan.expoNs, plan.quantumNs)) < 1e-6 };
for k = 1:size(inv,1)
    fprintf('    %-42s %s\n', inv{k,1}, tern(inv{k,2}));
    fail = fail + ~inv{k,2};
end

fprintf('\n  impossible plans must be refused:\n');
bad = { 'guard below dead + quantum',  setf(cfg,'guardNs',20000),     ids_ShotNs(cfg); ...
        'block shorter than readout',  setf(cfg,'shotsPerBlock',10),  ids_ShotNs(cfg); ...
        'zero shot length',            cfg,                           0 };
for k = 1:size(bad,1)
    try
        ids_BlockPlan(bad{k,2}, bad{k,3}, false);
        fprintf(2, '    %-32s NOT REFUSED\n', bad{k,1});
        fail = fail + 1;
    catch ME
        fprintf('    %-32s refused (%s)\n', bad{k,1}, ME.identifier);
    end
end

% ===== 4. PB pin map ====================================================== %
fprintf('\n===== PB pin map =====\n');
okPins = (PBDictionary('CamTrig') == 8) && (PBDictionary('dummy1') == 9);
fprintf('  CamTrig -> %d, dummy1 -> %d (expect 8, 9) %s\n', ...
        PBDictionary('CamTrig'), PBDictionary('dummy1'), tern(okPins));
fail = fail + ~okPins;

names = {'GreenAOM','MWSwitch','MWSwitch2','MWSwitchHP','ctr0','SRS1_I', ...
         'SRS2_I','CamRef','CamTrig','dummy1'};
pins = cellfun(@(n) PBDictionary(n), names);
uniq = numel(unique(pins)) == numel(pins);
fprintf('  all %d mapped pins distinct %s  %s\n', numel(pins), tern(uniq), mat2str(sort(pins)));
fail = fail + ~uniq;

% ===== 5. sequences ======================================================= %
fprintf('\n===== sequences =====\n');
seqs = { 'ids_Image', 0,      0; ...
         'ids_Rabi',  100,    N; ...
         'ids_Rabi',  0,      0; ...   % m = 0 -> the pulse is dropped entirely
         'ids_ODMR',  2.87e9, N; ...
         'ids_T1',    5000,   N };
for k = 1:size(seqs,1)
    mockSEQ(seqs{k,1}, seqs{k,2});
    try
        SequencePool(seqs{k,1});
    catch ME
        fprintf(2, '  %-10s (m=%-8g) BUILD FAILED: %s\n', seqs{k,1}, seqs{k,2}, ME.message);
        fail = fail + 1;
        continue
    end
    [ok, msg] = checkProgram(gmSEQ.CHN, plan, N, seqs{k,3});
    fprintf('  %-10s (m=%-8g) %-4s %s\n', seqs{k,1}, seqs{k,2}, tern(ok), msg);
    fail = fail + ~ok;
end

fprintf('\n  impossible sweep points must be refused:\n');
refuse = {'ids_T1', 1e6, 'tau far longer than the shot'; ...
          'ids_Rabi', 1e5, 'MW longer than the shot'};
for k = 1:size(refuse,1)
    mockSEQ(refuse{k,1}, refuse{k,2});
    try
        SequencePool(refuse{k,1});
        fprintf(2, '    %-10s %-30s NOT REFUSED\n', refuse{k,1}, refuse{k,3});
        fail = fail + 1;
    catch ME
        fprintf('    %-10s %-30s refused (%s)\n', refuse{k,1}, refuse{k,3}, ME.identifier);
    end
end

% ===== 6. FakeIDSCamera =================================================== %
fprintf('\n===== FakeIDSCamera =====\n');
c = cfg;
c.exposureNs = plan.expoNs;
c.programNs  = plan.programNs;

rng(1);   % deterministic: the assertions below are on noise-bearing numbers
cam = FakeIDSCamera(c);
cam.configure(c);
cam.startAcq();
mockSEQ('ids_Rabi', 60);
[I, Q] = cam.readIQ(1000);
cam.stopAcq();

szOK = isequal(size(I), [c.height c.width c.framePairs]) && isequal(size(I), size(Q));
fprintf('  I,Q are %s (expect [%d %d %d]) %s\n', mat2str(size(I)), ...
        c.height, c.width, c.framePairs, tern(szOK));
fail = fail + ~szOK;

posOK = all(I(:) > 0) && all(Q(:) > 0);
fprintf('  both quadratures positive (no polarity inversion) %s\n', tern(posOK));
fail = fail + ~posOK;

% ROI means, not single pixels: one pixel of a shot-noise-limited ratio is a
% coin flip, and a test that asserts on one fails at random.
ctr  = sum(Q,3) ./ sum(I,3);
h = round(c.height/2); w = round(c.width/2);
mid  = mean(mean(ctr(h-10:h+10, w-10:w+10)));
edge = mean(mean(ctr(1:20, 1:20)));
dipOK = mid < edge && edge > 0.9 && edge < 1.1;
fprintf('  Q./I: centre %.4f, edge %.4f -> dips on the blob %s\n', mid, edge, tern(dipOK));
fail = fail + ~dipOK;

fprintf('\n==== %d failure(s) ====\n', fail);
if nargout > 0; nFail = fail; end
end

% --------------------------------------------------------------------------- %
function [ok, msg] = checkProgram(CHN, plan, N, nMWexp)
% Assert the shape of the PB program a sequence just built.
ok = true; parts = {};
pins = [CHN.PBN];

iT = find(pins == PBDictionary('CamTrig'), 1);
if isempty(iT)
    ok = false; parts{end+1} = 'NO CamTrig';
else
    if CHN(iT).NRise ~= 2 || numel(CHN(iT).T) ~= 2
        ok = false; parts{end+1} = sprintf('CamTrig NRise=%d', CHN(iT).NRise);
    elseif abs(diff(CHN(iT).T) - plan.blockNs) > 1e-6
        ok = false;
        parts{end+1} = sprintf('trig spacing %g != block %g', ...
                               diff(CHN(iT).T), plan.blockNs);
    else
        parts{end+1} = 'trig x2';
    end
end

iG = find(pins == PBDictionary('GreenAOM'), 1);
if isempty(iG)
    ok = false; parts{end+1} = 'NO laser';
elseif CHN(iG).NRise ~= 2*N
    ok = false; parts{end+1} = sprintf('laser NRise=%d != %d', CHN(iG).NRise, 2*N);
else
    parts{end+1} = sprintf('laser x%d', 2*N);
end

iM  = find(pins == PBDictionary('MWSwitch'), 1);
nMW = 0;
if ~isempty(iM); nMW = CHN(iM).NRise; end
if nMW ~= nMWexp
    ok = false; parts{end+1} = sprintf('MW %d != %d', nMW, nMWexp);
else
    parts{end+1} = sprintf('MW x%d', nMW);
    % The whole contrast mechanism is that microwaves are in ONE block only.
    if nMW > 0 && any(CHN(iM).T >= plan.blockNs)
        ok = false; parts{end+1} = 'MW LEAKED INTO REF BLOCK';
    end
end

iD = find(pins == PBDictionary('dummy1'), 1);
if isempty(iD)
    ok = false; parts{end+1} = 'NO length marker';
elseif abs(max(CHN(iD).T + CHN(iD).DT) - plan.programNs) > 1e-6
    ok = false; parts{end+1} = 'marker != program length';
end

for k = 1:numel(CHN)
    if max(CHN(k).T + CHN(k).DT) > plan.programNs + 1e-6
        ok = false; parts{end+1} = sprintf('pin %d overruns program', CHN(k).PBN); %#ok<AGROW>
    end
end

msg = strjoin(parts, ', ');
end

% --------------------------------------------------------------------------- %
function mockSEQ(name, m)
% Minimal gmSEQ/gSG for building a sequence with no GUI attached.
global gmSEQ gSG %#ok<GVMIS>
gmSEQ = struct();
gmSEQ.name  = name;
gmSEQ.meas  = 'IDSCam';
gmSEQ.meas2 = 'none';
gmSEQ.meas3 = 'none';
gmSEQ.To    = 1000;
gmSEQ.m     = m;
gmSEQ.post_init_wait = 1000;
gmSEQ.post_MW_wait   = 1000;
gmSEQ.CtrGateDur     = 100;      % pi time for ids_ODMR / ids_T1
gSG = struct('bfixedPow',1,'bfixedFreq',1,'bMod','IQ','bModSrc','External');
end

function s = setf(s, f, v)
s.(f) = v;
end

function t = tern(tf)
if tf; t = 'ok'; else; t = 'FAIL'; end
end

function s = ternStr(tf, a, b)
if tf; s = a; else; s = b; end
end
