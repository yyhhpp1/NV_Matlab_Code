function verdict = hc_TimeoutProbe(shortMs, longMs)
% hc_TimeoutProbe  Is a timed-out getBuffer recoverable, or does it lose the burst?
%
%   verdict = hc_TimeoutProbe            % defaults: 200 ms short, 30 s long
%   verdict = hc_TimeoutProbe(shortMs, longMs)
%
% Settles the ONE question that decides whether an acquisition can be aborted
% mid-burst.
%
% THE PROBLEM
%
% readIQ blocks inside c4dev.getBuffer for the whole wait. MATLAB is
% single-threaded, so while it is blocked the GUI event queue is not serviced:
% the Stop button callback does not merely get ignored, it never RUNS, so
% gmSEQ.bGo is never cleared. Ctrl+C does not interrupt a blocking .NET call
% either, and a MATLAB timer cannot preempt one. Stop is therefore only honoured
% between sweep points, and the worst-case latency is one whole burst -- which,
% now that the timeout scales with the burst, can be minutes.
%
% The fix would be to wait in short chunks: getBuffer(200 ms) in a loop, drawnow
% between chunks so the Stop callback can run, and treat a chunk timeout as fatal
% only once the whole budget is spent. That gives both a long total wait and a
% responsive Stop.
%
% It is only safe if a timed-out getBuffer is NON-DESTRUCTIVE -- if the pending
% burst survives and a later getBuffer still returns it. If instead the timeout
% tears the acquisition down, the first chunk boundary would silently throw away
% a good measurement, which is far worse than a slow Stop. Nothing in the SDK
% wrapper or in this codebase establishes which it is, and it is not the sort of
% thing to guess at.
%
% WHAT THIS DOES
%
%   Control: startAcq -> run PB -> getBuffer(long)                 expect data
%   Probe:   startAcq -> getBuffer(short) [expect timeout]
%                     -> run PB -> getBuffer(long)                 data or not?
%
% Control passing and probe failing means the premature timeout destroyed the
% acquisition. Both passing means chunked waiting is safe and an interruptible
% acquisition can be built on it. The control exists so that a probe failure
% cannot be blamed on the camera simply not working today.
%
% Touches no hardware settings beyond what a normal run does: same
% configLockInMode, same PB program. Safe to run whenever a sequence is loaded
% and the camera is alive.

global gmSEQ gCam

if nargin < 1 || isempty(shortMs); shortMs = 200;   end
if nargin < 2 || isempty(longMs);  longMs  = 30000; end

verdict = struct('control', false, 'probe', false, 'safeToChunk', false, ...
                 'shortMs', shortMs, 'longMs', longMs, 'message', '');

if isempty(gCam) || ~isvalid(gCam)
    error('hc_TimeoutProbe: no live gCam. Open Experiment_PB_DAQ and Initialize first.');
end
if isempty(gmSEQ) || ~isfield(gmSEQ, 'name') || isempty(gmSEQ.name)
    error('hc_TimeoutProbe: no sequence selected. Pick an hc_* sequence first.');
end
if ~InstrumentEnabled('pulseblaster')
    error(['hc_TimeoutProbe: needs the PulseBlaster (it supplies the CamRef edges ', ...
           'the camera waits for).']);
end

cfg = WidefieldConfig();

% --- Camera configured exactly as a run would ------------------------------
ccfg = cfg;
flds = {'exposureSeconds','nPeriods','nFrames','sensitivity','coupling', ...
        'referenceTimeShiftUs'};
for k = 1:numel(flds)
    if isfield(gmSEQ, flds{k}) && ~isempty(gmSEQ.(flds{k}))
        ccfg.(flds{k}) = gmSEQ.(flds{k});
    end
end
gCam.configLockInMode(ccfg);

% --- Edge budget, and PB programmed to deliver it --------------------------
nBlank = 0;
if isfield(cfg,'blankPeriods') && ~isempty(cfg.blankPeriods)
    nBlank = cfg.blankPeriods;
end
nAC = 0;
if isfield(ccfg,'coupling') && strcmpi(ccfg.coupling,'AC'); nAC = 1; end
nPB = (ccfg.nPeriods + nBlank + nAC) * ccfg.nFrames;
gmSEQ.nPBPeriods = nPB;
gmSEQ.Repeat     = nPB;
gmSEQ.Samples    = nPB;

SequencePool(string(gmSEQ.name));
for k = 1:numel(gmSEQ.CHN)
    gmSEQ.CHN(k).T      = gmSEQ.CHN(k).T      / 1e9;
    gmSEQ.CHN(k).DT     = gmSEQ.CHN(k).DT     / 1e9;
    gmSEQ.CHN(k).Delays = gmSEQ.CHN(k).Delays / 1e9;
end
PBFunctionPool('PreprocessPBSequence', gmSEQ);

fprintf('\n[Probe] %s: %d periods x %d frames -> %d CamRef edges per burst.\n', ...
        char(string(gmSEQ.name)), ccfg.nPeriods, ccfg.nFrames, 4*nPB);

% --- Control ---------------------------------------------------------------
fprintf('[Probe] CONTROL: acquire normally (no premature getBuffer) ...\n');
try
    gCam.startAcq();
    Run_PB_Probe();
    [Ic, ~] = gCam.readIQ(longMs);
    verdict.control = ~isempty(Ic);
    fprintf('[Probe] CONTROL: data received (%d frames). Camera is working.\n', ...
            size(Ic,3));
catch ME
    fprintf(2, '[Probe] CONTROL FAILED: %s\n', ME.message);
    verdict.message = ['control failed: ' ME.message];
end
try; gCam.stopAcq(); catch; end

if ~verdict.control
    fprintf(2, ['\n[Probe] VERDICT: inconclusive -- a normal acquisition did not ', ...
                'work, so nothing\n         can be concluded about timeout ', ...
                'behaviour. Fix the acquisition first.\n\n']);
    return;
end

% --- Probe -----------------------------------------------------------------
fprintf('[Probe] PROBE: getBuffer(%g ms) BEFORE any edges (expect a timeout) ...\n', ...
        shortMs);
timedOut = false;
try
    gCam.startAcq();
    gCam.readIQ(shortMs);
    fprintf(2, ['[Probe] Unexpected: data arrived before PB ran. Raise nFrames or ', ...
                'lower shortMs so the premature read really does time out.\n']);
catch ME
    timedOut = true;
    fprintf('[Probe] PROBE: timed out as intended (%s).\n', strtrim(ME.message));
end

if ~timedOut
    try; gCam.stopAcq(); catch; end
    verdict.message = 'premature read did not time out; probe inconclusive';
    fprintf(2, '\n[Probe] VERDICT: inconclusive. %s\n\n', verdict.message);
    return;
end

fprintf('[Probe] PROBE: now supplying the edges and reading again ...\n');
try
    Run_PB_Probe();
    [Ip, ~] = gCam.readIQ(longMs);
    verdict.probe = ~isempty(Ip);
    fprintf('[Probe] PROBE: data received after the timeout (%d frames).\n', size(Ip,3));
catch ME
    fprintf('[Probe] PROBE: no data after the timeout (%s).\n', strtrim(ME.message));
end
try; gCam.stopAcq(); catch; end

% --- Verdict ---------------------------------------------------------------
verdict.safeToChunk = verdict.control && verdict.probe;
fprintf('\n');
if verdict.safeToChunk
    verdict.message = 'getBuffer timeout is NON-destructive; chunked waiting is safe';
    fprintf(['[Probe] VERDICT: SAFE TO CHUNK. A timed-out getBuffer left the burst ', ...
             'intact.\n         An interruptible acquisition can be built: wait in ', ...
             '%g ms chunks\n         with drawnow between them, so Stop is honoured ', ...
             'within ~%g ms\n         instead of one whole burst.\n'], shortMs, shortMs);
else
    verdict.message = 'getBuffer timeout DESTROYS the pending burst; chunking unsafe';
    fprintf(2, ...
        ['[Probe] VERDICT: NOT SAFE TO CHUNK. The premature timeout destroyed the\n', ...
         '         acquisition -- a normal read worked, but a read after a timeout\n', ...
         '         did not. Chunked waiting would silently discard good data at the\n', ...
         '         first chunk boundary. Keep one long timeout and get a fast Stop\n', ...
         '         by making each BURST short instead (fewer nFrames, more Average).\n']);
end
fprintf('\n');
end

% --------------------------------------------------------------------------- %
function Run_PB_Probe
% The same four calls RunSequence's Run_PB_Sequence makes. That one is a local
% function there, so it is not reachable from here.
PBesrInit();
PBesrSetClock(500);
PBesrStart();
PBesrClose();
end
