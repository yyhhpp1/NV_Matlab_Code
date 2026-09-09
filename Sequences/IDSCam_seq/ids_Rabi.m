function ids_Rabi
% ids_Rabi  Widefield Rabi on the IDS camera.
%
% Sweep parameter gmSEQ.m = MW on-time (ns), applied in every shot of the SIGNAL
% block. The REFERENCE block is identical but with the microwaves off, so
%
%   Q ./ I  =  (MW on) / (MW off)
%
% dips wherever the pulse rotates population out of ms=0 -- a Rabi oscillation
% per pixel, normalised shot-for-shot against laser drift because the two blocks
% are adjacent in time and see the same illumination.
%
% THE SHOT LENGTH DOES NOT MOVE WITH THE SWEEP
%
% m is absorbed into the shot's trailing idle, not added to the shot. So the
% block, the exposure, the frame rate and the dark pedestal are identical at
% every sweep point, and one dark reference is correct for the whole curve. If
% the shot stretched with m, the camera would need reconfiguring at every point
% and the pedestal subtraction would be right at exactly one of them.
%
% The consequence is that cfg.shotNs must be sized for the LONGEST m in the
% sweep; ids_BuildBlocks errors rather than overrunning if it is not.

global gmSEQ gSG
gSG.bfixedPow  = 1;
gSG.bfixedFreq = 1;
gSG.bMod       = 'IQ';
gSG.bModSrc    = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Normalised contrast: signal frame over reference frame. Both are positive raw
% ADU on this detector -- there is no polarity inversion anywhere on the IDS
% path -- so this is a ratio near 1, not a difference near 0.
gmSEQ.WFcontrastExpr = 'Q./I';

cfg = IDSConfig();

d = gmSEQ.post_init_wait;    % laser end -> MW start, within a shot (ns)
m = gmSEQ.m;                 % swept MW duration (ns)

% MW in the signal block only; reference block dark.
ids_BuildBlocks(cfg, [cfg.laserNs + d, m], []);

ApplyDelays();
end
