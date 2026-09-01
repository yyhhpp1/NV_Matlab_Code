function Q = hc_QuarterBin(cfg)
% Q = hc_QuarterBin(cfg)  Quarter period Q (ns) for the hc_* sequences.
%
% Sourced from the GUI QP field, which LoadUserInputs reads into
% gmSEQ.quarterBinNs. This is the spacing PB puts between CamRef edges in
% hc_Image / hc_ZScan / hc_Rabi / hc_ODMR, i.e. one quarter of the lock-in
% period. Falls back to cfg.quarterBinNs when the box is empty, non-numeric or
% non-positive, so a blank field cannot silently program a zero-length period.
%
% Single source of truth on purpose: the sequence files and the slack /
% frame-rate checks in RunSequence_HeliCam must agree on the quarter period,
% and the previous arrangement (each site deciding for itself) is what let the
% exposure checks drift onto a field the sequences were not actually using.
%
% Q used to come from the GUI 'interval' box, and hc_Image took it from
% 'readout' instead. Both are gone: 'interval' is no longer read by any hc_*
% sequence, and 'readout' is now only ever the init/readout LASER duration --
% the same meaning it carries in the confocal sequences (cf. Sequences/Rabi.m).
%
% hc_T1 is NOT covered here: it builds a composite bin out of its own pulse
% timings so the swept dark wait can stretch the period.

global gmSEQ

if nargin < 1 || isempty(cfg); cfg = WidefieldConfig(); end

Q = [];
if isfield(gmSEQ, 'quarterBinNs'); Q = gmSEQ.quarterBinNs; end
if isempty(Q) || ~isfinite(Q) || Q <= 0
    Q = cfg.quarterBinNs;
end
end
