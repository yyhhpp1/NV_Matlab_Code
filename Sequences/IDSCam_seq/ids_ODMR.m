function ids_ODMR
% ids_ODMR  Widefield pulsed ODMR on the IDS camera.
%
% Sweep parameter is MW FREQUENCY (GHz on the GUI; RunSequence_IDSCam converts
% to Hz and writes the SRS inside the loop). The pulse pattern is identical at
% every point: a fixed-duration MW pulse -- nominally a pi pulse -- in every
% shot of the SIGNAL block, nothing in the REFERENCE block.
%
%   Q ./ I  dips at each resonance.
%
% Because the PB program does not change across the sweep, the block, exposure,
% frame rate and dark pedestal are constant by construction here -- more
% strongly than in ids_Rabi, where the sweep at least moves an edge inside the
% shot. Only the signal generator moves.
%
% MW duration comes from the GUI CtrGateDur box, which is where the pulsed
% confocal sequences already keep a calibrated pi time.

global gmSEQ gSG
gSG.bfixedPow  = 1;
gSG.bfixedFreq = 0;          % frequency IS the sweep
gSG.bMod       = 'IQ';
gSG.bModSrc    = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

gmSEQ.WFcontrastExpr = 'Q./I';

cfg = IDSConfig();

d  = gmSEQ.post_init_wait;   % laser end -> MW start, within a shot (ns)
tp = gmSEQ.CtrGateDur;       % MW pulse duration (ns), nominally a pi pulse

if ~isfinite(tp) || tp <= 0
    error('ids_ODMR:NoPiTime', ...
          ['ids_ODMR takes its MW pulse duration from the CtrGateDur box, which ', ...
           'currently reads %g. Put a calibrated pi time there.'], tp);
end

ids_BuildBlocks(cfg, [cfg.laserNs + d, tp], []);

ApplyDelays();
end
