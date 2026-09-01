function [tmoMs, info] = hc_AcqTimeoutMs(cfg, CHN, nPeriodsTotal)
% hc_AcqTimeoutMs(cfg, CHN, nPeriodsTotal)  getBuffer timeout sized to the burst.
%
%   [tmoMs, info] = hc_AcqTimeoutMs(cfg, CHN, nPeriodsTotal)
%     cfg           : WidefieldConfig struct
%     CHN           : gmSEQ.CHN with T/DT already in SECONDS (see the unit note)
%     nPeriodsTotal : gmSEQ.nPBPeriods -- how many times PB runs the program
%     tmoMs         : timeout to hand readIQ, in ms
%     info          : .progSeconds .burstSeconds .floorMs .capped .reason
%
% WHY THIS EXISTS
%
% The timeout used to be a fixed 20 s from WidefieldConfig. That is a statement
% about how long a burst takes -- and it is only true for short ones. A burst
% lasts nPBPeriods x one PB program, so it grows with the quarter bin, with
% nPeriods and with nFrames, and a long T1 wait or a large frame count sails past
% 20 s. readIQ then times out with "no data available!" while the camera is still
% happily integrating: a perfectly healthy measurement reported as a hardware
% fault, which is the single most misleading failure this path can produce.
%
% So the timeout is derived from the burst instead of asserted: predicted burst
% duration, times a safety factor, plus a fixed margin for camera readout and
% GigE transfer, and never below the configured floor so short runs keep the
% generous behaviour they already had.
%
% THE PROGRAM LENGTH COMES FROM THE PB PROGRAM ITSELF
%
% Deliberately measured from CHN rather than computed as 4 x quarter bin. Those
% agree for hc_Image / hc_Rabi / hc_ODMR, but hc_T1 builds a COMPOSITE bin out of
% its own swept pulse timings, so 4 x QP badly underestimates its period -- and
% hc_T1 is exactly the sequence whose bursts get long. Reading the real program
% span makes this correct for every sequence, including ones not written yet.
%
% UNITS. CHN.T/DT must already be in seconds. Both call sites in
% RunSequence_HeliCam convert ns -> s before the acquisition, so that is what
% they hold at the point this is called. A ns array would read as ~1e5 seconds
% per period, so an absurd span is caught below rather than silently producing a
% multi-year timeout.
%
% CONSEQUENCE WORTH KNOWING: readIQ blocks for the whole wait and gmSEQ.bGo is
% only polled between sweep points, so Stop cannot interrupt an acquisition. A
% longer timeout therefore means a longer worst-case delay before Stop takes
% effect. That is a straight trade against not aborting good measurements;
% timeoutMaxMs bounds it.

persistent lastNote
if isempty(lastNote); lastNote = ''; end

floorMs  = getf(cfg, 'timeoutMs',       20000);
factor   = getf(cfg, 'timeoutFactor',   2);
marginMs = getf(cfg, 'timeoutMarginMs', 10000);
capMs    = getf(cfg, 'timeoutMaxMs',    1800000);

info          = struct();
info.floorMs  = floorMs;
info.capped   = false;
info.reason   = 'floor';

% --- One PB program (one lock-in period) span, in seconds -------------------
progS = 0;
for k = 1:numel(CHN)
    T = CHN(k).T; DT = CHN(k).DT;
    if isempty(T); continue; end
    if isempty(DT); DT = zeros(size(T)); end
    n = min(numel(T), numel(DT));
    progS = max(progS, max(T(1:n) + DT(1:n)));
end
if ~isfinite(progS) || progS < 0; progS = 0; end

% Units guard: no real lock-in period is an hour long. This fires if CHN was
% still in nanoseconds, which would otherwise yield a timeout of centuries.
if progS > 3600
    fprintf(2, ['[Widefield] hc_AcqTimeoutMs: PB program span came out %g s, which ', ...
                'is not a plausible lock-in period -- CHN is probably still in ', ...
                'nanoseconds. Falling back to the fixed timeout of %g ms.\n'], ...
            progS, floorMs);
    tmoMs         = floorMs;
    info.progSeconds  = NaN;
    info.burstSeconds = NaN;
    info.reason   = 'bad-units';
    return;
end

if ~isfinite(nPeriodsTotal) || nPeriodsTotal < 1; nPeriodsTotal = 1; end

burstS = nPeriodsTotal * progS;
info.progSeconds  = progS;
info.burstSeconds = burstS;

wantMs = ceil(1000 * burstS * factor + marginMs);
tmoMs  = max(floorMs, wantMs);
if tmoMs > floorMs; info.reason = 'burst'; end

if isfinite(capMs) && capMs > 0 && tmoMs > capMs
    tmoMs        = capMs;
    info.capped  = true;
    info.reason  = 'capped';
    fprintf(2, ['[Widefield] Predicted burst %.4g s needs a %.4g s timeout, but ', ...
                'timeoutMaxMs caps it at %.4g s. If the burst really is this long, ', ...
                'raise cfg.timeoutMaxMs -- otherwise readIQ will time out on a ', ...
                'measurement that was still running.\n'], ...
            burstS, wantMs/1000, capMs/1000);
end

% One line per distinct situation, so a 40-point sweep does not repeat it.
note = sprintf('%g|%g|%d', burstS, tmoMs, nPeriodsTotal);
if ~strcmp(note, lastNote)
    fprintf(['[Widefield] Burst %.4g s (%d periods x %.4g s); readIQ timeout %.4g s ', ...
             '(%s).\n'], burstS, nPeriodsTotal, progS, tmoMs/1000, info.reason);
    lastNote = note;
end
end

% --------------------------------------------------------------------------- %
function v = getf(s, name, dflt)
v = dflt;
if isstruct(s) && isfield(s, name) && ~isempty(s.(name)) && isfinite(s.(name))
    v = s.(name);
end
end
