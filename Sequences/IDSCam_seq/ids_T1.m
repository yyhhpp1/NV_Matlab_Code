function ids_T1
% ids_T1  Widefield T1 on the IDS camera.
%
% Sweep parameter gmSEQ.m = dark wait tau (ns) between the pi pulse and the next
% shot's readout laser.
%
%   SIGNAL block     green | wait | pi | ---- tau dark ---- | (next shot reads out)
%   REFERENCE block  green | wait |    | ---- tau dark ---- | (next shot reads out)
%
%   Q ./ I  =  (population after pi, decayed for tau) / (ms=0 after tau)
%
% HOW TAU IS SWEPT WITHOUT MOVING THE SHOT LENGTH
%
% The shot is FIXED (see IDSConfig.shotNs). Rather than appending tau, the pi
% pulse slides BACKWARDS inside the shot: it is placed so that exactly tau
% remains between its end and the next shot's laser. Longer tau means an earlier
% pi, not a longer shot.
%
% So block length, exposure, frame rate and dark pedestal are identical at every
% point of the curve, and one dark reference is valid across the whole sweep. On
% a T1 that is worth more than elsewhere: a pedestal that drifted along the sweep
% axis would decay just like the signal does, and the fit would absorb it.
%
% cfg.shotNs therefore has to be sized for the LONGEST tau. ids_BuildBlocks
% refuses the program rather than overrunning if it is not.
%
% KNOWN SYSTEMATIC
%
% The reference block carries no microwaves, so the two blocks do not have equal
% MW duty. Anything MW-power-dependent that is not spin population -- sample
% heating in particular -- appears in Q but not in I and does not divide out.
% For an ensemble at fixed power this is usually small and roughly constant along
% the sweep, but it is a real floor on accuracy. The matched-reference fix is a
% spectator pulse in the reference block, far off resonance, which needs a second
% signal generator; ids_T1_matched_ref does not exist yet.

global gmSEQ gSG
gSG.bfixedPow  = 1;
gSG.bfixedFreq = 1;
gSG.bMod       = 'IQ';
gSG.bModSrc    = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

gmSEQ.WFcontrastExpr = 'Q./I';

cfg = IDSConfig();
S   = ids_ShotNs(cfg);

d   = gmSEQ.post_init_wait;   % laser end -> earliest legal MW start (ns)
tp  = gmSEQ.CtrGateDur;       % pi pulse duration (ns)
tau = gmSEQ.m;                % swept dark wait (ns)

if ~isfinite(tp) || tp <= 0
    error('ids_T1:NoPiTime', ...
          ['ids_T1 takes its pi pulse duration from the CtrGateDur box, which ', ...
           'currently reads %g. Put a calibrated pi time there.'], tp);
end

% Slide the pi pulse so that exactly tau of darkness follows it.
tPi = S - tau - tp;

tauMax = S - tp - cfg.laserNs - d;
if tPi < cfg.laserNs + d
    error('ids_T1:TauTooLong', ...
          ['tau = %g ns does not fit: with a %g ns shot, a %g ns laser pulse, a ', ...
           '%g ns post-init wait and a %g ns pi pulse, the longest reachable dark ', ...
           'wait is %g ns. The shot length is deliberately held fixed across the ', ...
           'sweep, so raise cfg.shotNs (or the GUI shotNs box) to at least %g ns ', ...
           'for this range -- and note that doing so lengthens every shot, so it ', ...
           'costs duty cycle at the short-tau end too.'], ...
          tau, S, cfg.laserNs, d, tp, tauMax, tau + tp + cfg.laserNs + d);
end

% Pi in the signal block; reference block dark for the same tau.
ids_BuildBlocks(cfg, [tPi, tp], []);

ApplyDelays();
end
