function ids_TriggerTest(mode)
% ids_TriggerTest  Wiring and capability check for the IDS camera trigger path.
%
%   ids_TriggerTest            % 'report' -- capabilities + line state, no PB
%   ids_TriggerTest('toggle')  % drive CamTrig from PB, watch the line follow
%   ids_TriggerTest('caps')    % just the enum dumps
%
% Answers, in the order they can go wrong:
%
%   1. Is the GenTL producer there and does it enumerate the camera?
%   2. Is the configured trigger line an INPUT, and is it LVTTL?
%   3. Does PB pin 8 (CamTrig) actually move that line?
%   4. Is ExposureTriggerMissed available as a counter source, so scheme C1's
%      diagnosis will work when a run does fail?
%
% Cannot time out and does not acquire, so it is safe to run at any point. This
% is the first thing to run after cabling PB8 to GPIO1, and the first thing to
% run when a real acquisition times out.
%
% Uses gCamIDS if a camera is already open, and opens one otherwise. It does not
% close a camera it did not open.

global gCamIDS %#ok<GVMIS>

if nargin < 1 || isempty(mode); mode = 'report'; end
mode = lower(char(string(mode)));

cfg = IDSConfig();
if cfg.useFakeCamera
    error('ids_TriggerTest:FakeCamera', ...
          ['IDSConfig.useFakeCamera is true, so there is no hardware to test. ', ...
           'Set it false to check real wiring.']);
end

bOpenedHere = false;
if isempty(gCamIDS) || ~isvalid(gCamIDS)
    gCamIDS = IDSCamInterface(cfg);
    bOpenedHere = true;
end

% --- PB pin the dictionary resolves CamTrig to, and any clash ---------------
camTrigPin = SequencePool('PBDictionary', 'CamTrig');
fprintf('\n[PBDictionary] CamTrig -> PB pin %d (physical GPIO1 expected).\n', camTrigPin);
reportPinClash(camTrigPin);

caps = jsondecode(char(py.ids_acquire.line_status()));

if any(strcmp(mode, {'report','caps'}))
    reportCaps(caps, cfg);
end

if strcmp(mode, 'caps')
    if bOpenedHere; fprintf('\n(Camera left open as gCamIDS.)\n'); end
    return
end

if strcmp(mode, 'toggle')
    if ~InstrumentEnabled('pulseblaster')
        error('ids_TriggerTest:NoPB', ...
              ['The PulseBlaster is disabled in InstrumentEnabled.m, so nothing ', ...
               'can drive CamTrig. Enable it and rerun.']);
    end
    toggleTest(cfg, camTrigPin);
end

if bOpenedHere
    fprintf('\n(Camera left open as gCamIDS. IDSCamRelease to close it.)\n');
end
end

% --------------------------------------------------------------------------- %
function reportPinClash(pin)
% Warn if another logical channel maps to the same PB pin. A shared pin means an
% unrelated sequence channel drives the camera trigger -- the same hazard
% hc_TriggerTest guards against for CamRef, and the reason dummy1 was moved off
% pin 8 when CamTrig took it.
names = {'ctr0','dummy1','GreenAOM','RedAOM','MWSwitch','MWSwitch2','MWSwitch3', ...
         'MWSwitchHP','SRS1_I','SRS2_I','CamRef','+X','-X','+Y','-Y','PD'};
clash = {};
for i = 1:numel(names)
    try
        if SequencePool('PBDictionary', names{i}) == pin
            clash{end+1} = names{i}; %#ok<AGROW>
        end
    catch
    end
end
if ~isempty(clash)
    fprintf(2, ['[PBDictionary] WARNING: pin %d is also mapped to: %s.\n', ...
                '   That channel and CamTrig drive the same physical output, so an\n', ...
                '   unrelated sequence would trigger the camera. Give CamTrig its\n', ...
                '   own pin.\n'], pin, strjoin(clash, ', '));
end
end

% --------------------------------------------------------------------------- %
function reportCaps(caps, cfg)
fprintf('\n--- Lines ---\n');
wantLine = char(string(cfg.triggerLine));
for k = 1:numel(caps.lines)
    L = caps.lines(k);
    if iscell(L); L = L{1}; end
    if isfield(L,'error')
        fprintf('  %-6s  <unavailable: %s>\n', char(string(L.line)), ...
                char(string(L.error)));
        continue
    end
    marker = '  ';
    if strcmp(char(string(L.line)), wantLine); marker = '->'; end
    fprintf('%s %-6s mode=%-8s status=%-5s format=%-8s source=%s\n', ...
            marker, char(string(L.line)), showv(L,'mode'), showv(L,'status'), ...
            showv(L,'format'), showv(L,'source'));
end

fprintf('\n--- Trigger path ---\n');
okSrc = any(strcmp(caps.trigger_sources, wantLine));
fprintf('  TriggerSource offers %s ......... %s\n', wantLine, tick(okSrc));
if ~okSrc
    fprintf(2, '     Available: %s\n', strjoin(cellstr(caps.trigger_sources), ', '));
end

% ExposureMode is the one that killed scheme B2 outright. Worth re-checking on
% every camera, because a firmware update is exactly the thing that would
% change it and quietly open up a better design.
if isfield(caps,'exposure_modes') && ~isempty(caps.exposure_modes)
    modes = cellstr(caps.exposure_modes);
    fprintf('  ExposureMode entries: %s\n', strjoin(modes, ', '));
    if any(strcmpi(modes, 'TriggerWidth'))
        fprintf(2, ['     NOTE: TriggerWidth is available on this unit. The design ', ...
                    'assumes it is not\n     (scheme B2 was recorded as dead). PB ', ...
                    'could define the exposure directly.\n']);
    end
end

fprintf('\n--- Telemetry (scheme C1) ---\n');
okCtr = isfield(caps,'counter_event_sources') && ...
        any(strcmpi(cellstr(caps.counter_event_sources), 'ExposureTriggerMissed'));
fprintf('  ExposureTriggerMissed as counter source ... %s\n', tick(okCtr));
if ~okCtr
    fprintf(2, ['     Set cfg.enableMissedCounter = false. A failed run will then ', ...
                'report a\n     timeout without being able to say whether a trigger ', ...
                'was missed or never arrived.\n']);
end
okEvt = isfield(caps,'event_selectors') && ...
        any(strcmpi(cellstr(caps.event_selectors), 'ExposureTriggerMissed'));
fprintf('  ExposureTriggerMissed as GenICam event ... %s (not used; counter preferred)\n', ...
        tick(okEvt));

fprintf('\n--- Sync out (scheme A2) ---\n');
okTimer = isfield(caps,'line_sources') && ...
          any(strcmpi(cellstr(caps.line_sources), 'Timer0Active'));
fprintf('  Timer0Active routable to a line .......... %s\n', tick(okTimer));
end

% --------------------------------------------------------------------------- %
function toggleTest(cfg, pin)
% Hold CamTrig low, then high, sampling the camera's own view of the line.
%
% PBFunctionPool('PBON', mask) sets a static output pattern -- no program, no
% loop -- so this cannot run a sequence by accident and cannot leave PB looping.
fprintf('\n--- Toggle test: PB pin %d -> %s ---\n', pin, cfg.triggerLine);

mask = 2^pin;

% Restore the idle output pattern however this exits -- normal return, error, or
% Ctrl-C. Every run in this codebase leaves the laser channel on, so a
% diagnostic must not be the one thing that leaves PB dark.
restorePB = onCleanup(@() finally_pb());

PBFunctionPool('PBON', 0);
pause(0.2);
lo = jsondecode(char(py.ids_acquire.sample_line(cfg.triggerLine, int32(20), 0.005)));

PBFunctionPool('PBON', mask);
pause(0.2);
hi = jsondecode(char(py.ids_acquire.sample_line(cfg.triggerLine, int32(20), 0.005)));

fprintf('  PB low  : %d of %d samples read high\n', lo.high, lo.samples);
fprintf('  PB high : %d of %d samples read high\n', hi.high, hi.samples);

if hi.high > lo.high
    fprintf('\n*** SIGNAL SEEN. CamTrig reaches %s. ***\n', cfg.triggerLine);
elseif lo.high > hi.high
    fprintf(2, ['\n*** INVERTED: the line reads high when PB is low. Set ', ...
                'cfg.triggerActivation\n    to ''FallingEdge'', or check for an ', ...
                'inverting buffer in the cable. ***\n']);
else
    fprintf(2, ['\n*** NO CHANGE. The camera does not see PB pin %d. Check, in order:\n', ...
                '      - is there a 50 ohm terminator on the line? The PB drives 3.3 V,\n', ...
                '        which a 50 ohm load divides to 1.65 V -- below the 2.0 V LVTTL\n', ...
                '        threshold. Terminated, this input reads exactly like an\n', ...
                '        unplugged cable. Drive it unterminated.\n', ...
                '      - the cable actually lands on GPIO1 (not the opto Trigger input)\n', ...
                '      - LineMode on %s is Input (this test sets it, but a\n', ...
                '        conflicting LineSource can hold it as an output)\n', ...
                '      - PB pin %d is really the one wired (PBDictionary CamTrig)\n', ...
                '    ***\n'], pin, cfg.triggerLine, pin);
end
end

function finally_pb()
% Leave the laser channel on, matching how every run in this codebase exits.
try
    PBFunctionPool('PBON', 2^SequencePool('PBDictionary','GreenAOM'));
catch
end
end

% --------------------------------------------------------------------------- %
function s = showv(S, f)
s = '?';
if isfield(S, f) && ~isempty(S.(f))
    try; s = char(string(S.(f))); catch; s = '?'; end
end
end

function s = tick(tf)
if tf; s = 'yes'; else; s = 'NO'; end
end
