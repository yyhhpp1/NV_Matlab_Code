function plan = ids_BuildBlocks(cfg, mwSig, mwRef)
% ids_BuildBlocks  Build the SIG/REF block pair into gmSEQ.CHN.
%
%   plan = ids_BuildBlocks(cfg, mwSig)          % REF block has no MW
%   plan = ids_BuildBlocks(cfg, mwSig, mwRef)
%
%   mwSig  [nPulse x 2] of [delayNs durationNs], relative to the START of each
%          shot, applied to every shot of the SIGNAL block
%   mwRef  same for the REFERENCE block; [] or omitted = no MW at all
%
%   plan   the validated ids_BlockPlan for this shot length -- returned so the
%          caller can print or assert on it, and so RunSequence_IDSCam gets the
%          identical numbers rather than recomputing them from scratch
%
% Every ids_* sequence goes through here. They differ ONLY in where they put
% microwaves, so the block skeleton -- triggers, laser train, length marker --
% is written once. Four near-identical sequence files is exactly how the
% quarter-bin drift on the HeliCam side started.
%
% WHAT GETS BUILT
%
%   CamTrig   2 rising edges: one at t=0 (opens the SIG frame), one at t=B
%             (opens the REF frame). This is the entire camera interface.
%   GreenAOM  2N pulses: one at the start of every shot in both blocks. Does
%             double duty -- reads out the previous shot, re-initialises for
%             this one.
%   MWSwitch  as requested per block.
%   dummy1    program-length marker spanning the full 2B, so the program length
%             is set by the marker and NOT by the laser. AcquireDarkRef strips
%             the GreenAOM channel to take a dark; without the marker that would
%             shorten the program and move the second CamTrig edge, and the dark
%             would be taken at a different frame rate than the data.
%
% MW pulses shorter than the PulseBlaster's 12.5 ns minimum instruction are
% DROPPED rather than programmed. A Rabi sweep legitimately starts at 0 ns, and
% a zero-length instruction is silently stretched by the PB validator -- which
% would put a real pulse at the point that is supposed to be the m=0 baseline.
%
% ONE INTERACTION WORTH KNOWING ABOUT
%
% ApplyDelays gives GreenAOM a 200 ns advance, and PBFunctionPool then shifts the
% whole program so its earliest event sits at t=0 (PBFunctionPool.m:86). The
% laser is that earliest event, so the CamTrig edges do not land at exactly 0 and
% B -- everything slides 200 ns later, and the program runs 200 ns longer than
% plan.programNs.
%
% Harmless, and deliberately not corrected. What the camera cares about is the
% GAP between consecutive triggers, and the shift preserves the within-run gap
% (B) exactly while making the run-to-run gap B + 200 ns. Both are >= B, so every
% margin ids_BlockPlan computed still holds -- the extra 200 ns is slack, not
% debt. The two frames of a pair are triggered 200 ns apart in phase but have
% identical exposure lengths, so nothing about the SIG/REF comparison changes.

global gmSEQ

if nargin < 3; mwRef = []; end
if nargin < 2; mwSig = []; end
if nargin < 1 || isempty(cfg); cfg = IDSConfig(); end

S = ids_ShotNs(cfg);                 % shot length (ns), fixed across the sweep
N = double(cfg.shotsPerBlock);
L = double(cfg.laserNs);
w = double(cfg.camTrigWidthNs);

plan = ids_BlockPlan(cfg, S, false); % validates; errors on an impossible plan
B    = plan.blockNs;

if L >= S
    error('ids_BuildBlocks:LaserLongerThanShot', ...
          ['The green pulse is %g ns but the shot is only %g ns, so the laser ', ...
           'would never turn off. Shorten cfg.laserNs or lengthen cfg.shotNs ', ...
           '(or the GUI shotNs box).'], L, S);
end
if w >= plan.guardNs
    error('ids_BuildBlocks:TrigWidthVsGuard', ...
          ['CamTrig is %g ns wide but the guard interval is only %g ns. The ', ...
           'trigger pulse has to fit comfortably inside the block.'], w, plan.guardNs);
end

% Shot start times: N shots in the SIG block from 0, N in the REF block from B.
sigStarts = (0:N-1) * S;
refStarts = B + (0:N-1) * S;

% --- CamTrig: one rising edge per frame ------------------------------------
gmSEQ.CHN(1).PBN   = PBDictionary('CamTrig');
gmSEQ.CHN(1).NRise = 2;
gmSEQ.CHN(1).T     = [0, B];
gmSEQ.CHN(1).DT    = [w, w];

% --- Green laser: one pulse per shot, both blocks ---------------------------
gmSEQ.CHN(end+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(end).NRise   = 2 * N;
gmSEQ.CHN(end).T       = [sigStarts, refStarts];
gmSEQ.CHN(end).DT      = L * ones(1, 2*N);

% --- Microwaves -------------------------------------------------------------
[tMW, dMW] = expandMW(mwSig, sigStarts, S, L, 'signal');
[tR,  dR ] = expandMW(mwRef, refStarts, S, L, 'reference');
tMW = [tMW, tR];
dMW = [dMW, dR];

if ~isempty(tMW)
    gmSEQ.CHN(end+1).PBN = PBDictionary('MWSwitch');
    gmSEQ.CHN(end).NRise = numel(tMW);
    gmSEQ.CHN(end).T     = tMW;
    gmSEQ.CHN(end).DT    = dMW;
end

% --- Program-length marker --------------------------------------------------
% Spans the whole program so the length survives AcquireDarkRef dropping the
% laser. See the header.
gmSEQ.CHN(end+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(end).NRise   = 2;
gmSEQ.CHN(end).T       = [0, plan.programNs - 1000];
gmSEQ.CHN(end).DT      = [1000, 1000];

end

% --------------------------------------------------------------------------- %
function [t, d] = expandMW(spec, starts, S, L, blockName)
% Replicate a per-shot MW pulse list across every shot of one block.
t = [];
d = [];
if isempty(spec); return; end
if size(spec, 2) ~= 2
    error('ids_BuildBlocks:BadMWSpec', ...
          'MW spec must be [nPulse x 2] of [delayNs durationNs], got %dx%d.', ...
          size(spec,1), size(spec,2));
end

PB_MIN_NS = 12.5;   % 5 clock cycles at 400 MHz (PBESR-PRO-400)

for k = 1:size(spec, 1)
    del = spec(k,1);
    dur = spec(k,2);

    if ~isfinite(del) || ~isfinite(dur); continue; end
    if dur < PB_MIN_NS
        % Deliberately silent: a Rabi sweep's first point is m = 0 and reporting
        % it at every point would bury the console. The DROP is what matters,
        % and it is the correct behaviour -- see the header.
        continue
    end
    if del < L
        error('ids_BuildBlocks:MWDuringLaser', ...
              ['%s block: an MW pulse starts %g ns into the shot but the green ', ...
               'pulse runs to %g ns, so the microwaves would be applied while the ', ...
               'NV is being repolarised. Raise the post-init wait.'], ...
              blockName, del, L);
    end
    if del + dur > S
        error('ids_BuildBlocks:MWOverrunsShot', ...
              ['%s block: an MW pulse ends %g ns into a %g ns shot, so it would ', ...
               'run into the next shot''s readout laser. Shorten the sweep range ', ...
               'or lengthen cfg.shotNs (GUI shotNs box) -- the shot length is held ', ...
               'FIXED across a sweep on purpose, so it must be sized for the ', ...
               'LONGEST point.'], blockName, del + dur, S);
    end

    t = [t, starts + del];        %#ok<AGROW>
    d = [d, dur * ones(1, numel(starts))]; %#ok<AGROW>
end

% PB wants the edges in time order once several pulse lists are merged.
[t, ix] = sort(t);
d = d(ix);
end
