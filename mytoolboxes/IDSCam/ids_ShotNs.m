function S = ids_ShotNs(cfg)
% S = ids_ShotNs(cfg)  Shot length (ns) for the ids_* sequences.
%
% Single source of truth, for the same reason hc_QuarterBin is one on the
% HeliCam side: the sequence file places the pulses and RunSequence_IDSCam
% computes the block, the exposure and the frame-rate margin. If those two
% disagreed about the shot length, the pulse diagram would show one program and
% the camera would be configured for another -- and the mismatch would surface
% only as intermittent missed triggers.
%
% Sourced from gmSEQ.shotNs when the GUI supplies it, falling back to
% IDSConfig.shotNs. A blank, non-numeric or non-positive box falls back rather
% than programming a zero-length shot.
%
% TO PUT THIS ON THE GUI (no .fig edits are made by this code):
%   add an edit box with Tag 'shotNs' to Experiment_PB_DAQ.fig, then one line in
%   getUserInputFromGUI / LoadUserInputs:
%       gmSEQ.shotNs = str2double(get(handles.shotNs,'String'));

global gmSEQ

if nargin < 1 || isempty(cfg); cfg = IDSConfig(); end

S = [];
if ~isempty(gmSEQ) && isfield(gmSEQ, 'shotNs'); S = gmSEQ.shotNs; end
if isempty(S) || ~isfinite(S) || S <= 0
    S = cfg.shotNs;
end
end
