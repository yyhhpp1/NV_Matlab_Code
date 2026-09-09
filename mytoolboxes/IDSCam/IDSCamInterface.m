classdef IDSCamInterface < handle
% IDSCamInterface  IDS uEye+ U3-3140CP-M widefield camera, protocol-compatible
% with HeliCamInterface.
%
% Implements the same four-method camera protocol the HeliCam path uses, so
% everything downstream of the camera -- gWide, DisplayWidefield, hc_WFExpr,
% AcquireDarkRef, SaveWidefield, the averaging loop -- is reused unchanged:
%
%   configure(cfg) / startAcq() / [I,Q] = readIQ(timeoutMs) / stopAcq()
%   f = readActualRefFrequency()          .Height  .Width
%
% WHAT I AND Q MEAN HERE  (different from the HeliCam -- read this)
%
% The C4 returns two lock-in QUADRATURES, already polarity-inverted by its own
% readIQ, each a difference of quarter bins. This camera has no demodulator at
% all, so the roles are filled by whole frames instead:
%
%   Q(:,:,k) = SIGNAL    frame of pair k   (MW on)     raw summed ADU, positive
%   I(:,:,k) = REFERENCE frame of pair k   (MW off)    raw summed ADU, positive
%
% Nothing is negated anywhere on this path. The natural contrast expression is
% therefore 'Q./I' -- near 1 with a dip -- and every ids_* sequence sets
% gmSEQ.WFcontrastExpr accordingly. Using the HeliCam's 'I' or '-I./Q' here
% would plot something meaningless.
%
% Frames arrive strictly alternating because PB emits the SIG block's trigger
% first: frames 1,3,5,... are signal and 2,4,6,... are reference. That ordering
% is the whole contract between the sequence file and this class.
%
% BACKEND
%
% Pixels come from ids_acquire.py over MATLAB's in-process py. bridge, which
% talks GenTL/harvesters to the IDS producer. The bridge carries only JSON
% strings; frame data goes via an HDF5 scratch file, which sidesteps numpy
% marshalling entirely and costs a few ms for a typical burst.
%
% MATLAB R2023b supports Python 3.9-3.11 ONLY. The machine default is 3.13 and
% will not load, so IDSConfig.pythonExe points at heli_cam_env (3.11.5). Once a
% Python is loaded into a MATLAB session it cannot be swapped -- if the wrong one
% is already loaded the constructor says so and asks for a restart, rather than
% failing obscurely several calls later.

    properties (Access = public)
        Height (1,1) double = 0
        Width  (1,1) double = 0
    end

    properties (Access = private)
        cfg            = struct()
        burstFile      = ''
        nFrames        = 0       % frames per burst = 2 * framePairs
        programSeconds = 0       % one PB program run = one SIG/REF pair
        armed          = false
        lastFetch      = struct()
        configured     = false
    end

    methods
        function obj = IDSCamInterface(cfg)
        % IDSCamInterface(cfg)  Connect. cfg optional; IDSConfig() otherwise.
            if nargin < 1 || isempty(cfg); cfg = IDSConfig(); end
            obj.cfg       = cfg;
            obj.burstFile = cfg.burstFile;

            IDSCamInterface.ensurePython(cfg);

            r = obj.call(@() py.ids_acquire.connect(cfg.ctiPath, ...
                                                    int32(cfg.deviceIndex)));
            if ~r.ok
                error('IDSCamInterface:ConnectFailed', ...
                      'Could not open the IDS camera: %s', r.error);
            end
            if isfield(r,'devices'); disp(r.devices); end

            fprintf(['[IDS] Connected: %s serial %s (firmware %s), sensor clock ', ...
                     '%g Hz.\n'], ...
                    char(string(r.model)), char(string(r.serial)), ...
                    char(string(r.firmware)), obj.num(r, 'clock_Hz', NaN));
            t = obj.num(r, 'temperature_C', NaN);
            if isfinite(t)
                fprintf('[IDS] Device temperature %.1f C.\n', t);
            end
        end

        function configure(obj, cfg)
        % configure(cfg)  Write ROI, exposure, trigger, sync out and telemetry.
        %
        % cfg must carry an exposureNs already snapped to the camera's 5.5556 us
        % grid -- ids_BlockPlan owns that arithmetic, so this class never invents
        % an exposure of its own. The camera's own ExposureTime.Minimum() is read
        % back and compared, because the minimum depends on ROI WIDTH and a
        % disagreement between the model and the hardware is worth seeing.
            obj.cfg = cfg;
            if isfield(cfg,'burstFile') && ~isempty(cfg.burstFile)
                obj.burstFile = cfg.burstFile;
            end

            payload = struct();
            payload.width              = double(cfg.width);
            payload.height             = double(cfg.height);
            payload.offsetX            = obj.orNull(cfg, 'offsetX');
            payload.offsetY            = obj.orNull(cfg, 'offsetY');
            payload.pixelFormat        = char(string(cfg.pixelFormat));
            payload.exposureNs         = double(cfg.exposureNs);
            payload.gain               = double(obj.getf(cfg, 'gain', 1.0));
            payload.triggerLine        = char(string(cfg.triggerLine));
            payload.triggerActivation  = char(string(obj.getf(cfg, ...
                                              'triggerActivation', 'RisingEdge')));
            payload.triggerDivider     = double(obj.getf(cfg, 'triggerDivider', 1));
            payload.enableSyncOut      = logical(obj.getf(cfg, 'enableSyncOut', false));
            payload.syncOutLine        = char(string(obj.getf(cfg, 'syncOutLine', 'Line3')));
            payload.syncOutDelayUs     = double(obj.getf(cfg, 'syncOutDelayUs', 0));
            payload.syncOutWidthUs     = double(obj.getf(cfg, 'syncOutWidthUs', 10));
            payload.enableMissedCounter= logical(obj.getf(cfg, 'enableMissedCounter', false));
            payload.missedCounter      = char(string(obj.getf(cfg, 'missedCounter', 'Counter1')));

            r = obj.call(@() py.ids_acquire.configure(jsonencode(payload)));
            if ~r.ok
                error('IDSCamInterface:ConfigureFailed', ...
                      'Camera configuration failed: %s', obj.str(r, 'error'));
            end

            obj.Height = double(r.height);
            obj.Width  = double(r.width);

            nPairs = double(obj.getf(cfg, 'framePairs', 10));
            obj.nFrames        = 2 * nPairs;
            obj.programSeconds = double(obj.getf(cfg, 'programNs', 0)) * 1e-9;
            obj.configured     = true;

            expoGot = obj.num(r, 'exposureNs', NaN);
            expoMin = obj.num(r, 'exposureMinNs', NaN);
            fprintf(['[IDS] Configured: ROI %dx%d at (%g,%g) %s, exposure %g ns, ', ...
                     'trigger %s %s, divider %g.\n'], ...
                    obj.Width, obj.Height, obj.num(r,'offsetX',NaN), ...
                    obj.num(r,'offsetY',NaN), char(string(r.pixelFormat)), ...
                    expoGot, char(string(r.triggerSource)), ...
                    char(string(payload.triggerActivation)), ...
                    obj.num(r,'triggerDivider',NaN));
            fprintf('[IDS] Burst: %d frames = %d SIG/REF pairs.\n', obj.nFrames, nPairs);

            % The exposure MATLAB planned and the exposure the sensor holds must
            % agree -- if they do not, every margin computed by ids_BlockPlan is
            % describing a different camera than the one about to run.
            if isfinite(expoGot) && abs(expoGot - payload.exposureNs) > 1
                fprintf(2, ['[IDS] WARNING: asked for a %g ns exposure, camera holds ', ...
                            '%g ns (%g ns adrift). The block margin was computed from ', ...
                            'the requested value.\n'], ...
                        payload.exposureNs, expoGot, expoGot - payload.exposureNs);
            end
            if isfinite(expoMin) && payload.exposureNs < expoMin
                fprintf(2, ['[IDS] WARNING: %g ns is below this camera''s own reported ', ...
                            'minimum of %g ns at width %d; it will have clamped.\n'], ...
                        payload.exposureNs, expoMin, obj.Width);
            end

            obj.reportNotes(r);
        end

        function configLockInMode(obj, cfg)
        % Protocol alias. The HeliCam path calls the camera's configuration step
        % by this name; keeping it means code written against that protocol
        % (present or future) works with either detector. "LockIn" is a misnomer
        % here -- there is no demodulator -- so ids_* code should call configure.
            obj.configure(cfg);
        end

        function startAcq(obj)
        % Arm and start streaming. Returns immediately, with the camera waiting
        % on CamTrig -- MATLAB must start the PB program after this, not before.
            if ~obj.configured
                error('IDSCamInterface:NotConfigured', ...
                      'startAcq before configure: the camera has no ROI or exposure yet.');
            end
            r = obj.call(@() py.ids_acquire.arm(int32(obj.nFrames)));
            if ~r.ok
                error('IDSCamInterface:ArmFailed', 'Could not arm: %s', obj.str(r,'error'));
            end
            obj.armed = true;
        end

        function [I, Q] = readIQ(obj, timeoutMs)
        % [I,Q] = readIQ(timeoutMs)  Fetch one burst and split it into pairs.
        %
        %   Q = signal frames (odd)   H x W x framePairs, double
        %   I = reference frames (even)
        %
        % Errors on a short burst rather than returning what arrived. A burst
        % that is short by one frame is exactly the signature of a missed
        % trigger, and from the miss onward every remaining frame has its
        % SIG/REF role inverted -- so the data is not merely incomplete, it is
        % wrong in a way no downstream check would catch.
            if nargin < 2 || isempty(timeoutMs); timeoutMs = 20000; end
            if ~obj.armed
                error('IDSCamInterface:NotArmed', 'readIQ before startAcq.');
            end

            r = obj.call(@() py.ids_acquire.fetch_n(int32(obj.nFrames), ...
                                                    double(timeoutMs), ...
                                                    obj.burstFile));
            obj.lastFetch = r;

            nGot = obj.num(r, 'n_got', 0);
            if ~r.ok
                error('IDSCamInterface:FetchFailed', '%s', obj.diagnose(r, timeoutMs));
            end
            if nGot ~= obj.nFrames
                error('IDSCamInterface:ShortBurst', '%s', obj.diagnose(r, timeoutMs));
            end

            % h5py writes (n,H,W) row-major; MATLAB's h5read hands back the
            % dimensions reversed, so this arrives W x H x n.
            raw    = h5read(obj.burstFile, '/frames');
            frames = double(permute(raw, [2 1 3]));

            if size(frames,1) ~= obj.Height || size(frames,2) ~= obj.Width
                error('IDSCamInterface:BadShape', ...
                      ['Burst file holds %dx%d frames but the camera is configured ', ...
                       '%dx%d.'], size(frames,1), size(frames,2), obj.Height, obj.Width);
            end

            % PB emits the SIG block's trigger first, so odd frames are signal.
            Q = frames(:,:,1:2:end);
            I = frames(:,:,2:2:end);

            % Non-fatal telemetry. Incomplete buffers and FrameID gaps are
            % DELIVERY faults (USB), distinct from a missed trigger, and they
            % do not shift the SIG/REF pairing -- so they warn rather than stop.
            nInc = obj.num(r, 'incomplete_buffers', 0);
            nGap = obj.num(r, 'frame_id_gaps', 0);
            if nInc > 0
                fprintf(2, ['[IDS] WARNING: %d incomplete buffer(s) in this burst. ', ...
                            'Those frames carry partial data.\n'], nInc);
            end
            if nGap > 0
                fprintf(2, ['[IDS] WARNING: %d FrameID gap(s) -- frames were dropped ', ...
                            'in USB delivery, not by the trigger.\n'], nGap);
            end
            nMiss = obj.num(r, 'missed_triggers', 0);
            if nMiss > 0
                fprintf(2, ['[IDS] WARNING: ExposureTriggerMissed counter reads %d on ', ...
                            'a burst that nonetheless completed. You are close to the ', ...
                            'rate ceiling -- lengthen cfg.guardNs.\n'], nMiss);
            end
        end

        function stopAcq(obj)
            obj.call(@() py.ids_acquire.stop());
            obj.armed = false;
        end

        function f = readActualRefFrequency(obj)
        % Frame-pair rate (Hz). Protocol compatibility: the HeliCam reports the
        % lock-in reference frequency here. The analogous quantity on this
        % camera is how often a complete SIG/REF pair is produced.
            if obj.programSeconds > 0
                f = 1 / obj.programSeconds;
            else
                f = NaN;
            end
        end

        function s = lastStatus(obj)
        % Decoded result of the most recent fetch -- frame counts, missed
        % triggers, FrameID gaps. For diagnostics after a run.
            s = obj.lastFetch;
        end

        function delete(obj)
            try; obj.call(@() py.ids_acquire.disconnect()); catch; end
        end
    end

    methods (Access = private)
        function r = call(~, fn)
        % Run a py. call and decode its JSON reply into a struct.
            out = fn();
            r   = jsondecode(char(out));
            if ~isfield(r,'ok'); r.ok = false; end
        end

        function msg = diagnose(obj, r, timeoutMs)
        % Turn a failed fetch into the sentence that names the actual fault.
        %
        % Three faults present identically as "no data": PB never ran, the
        % camera never saw the line, or a trigger was missed. The
        % ExposureTriggerMissed counter is what separates the third from the
        % first two -- which is its whole job, since the frame-count mismatch is
        % what already detected that something went wrong.
            nGot  = obj.num(r, 'n_got', 0);
            nMiss = obj.num(r, 'missed_triggers', NaN);

            msg = sprintf('IDS burst incomplete: %d of %d frames after %.1f s.\n', ...
                          nGot, obj.nFrames, timeoutMs/1000);
            e = obj.str(r, 'error');
            if ~isempty(e); msg = [msg sprintf('  backend: %s\n', e)]; end

            if isfinite(nMiss) && nMiss > 0
                msg = [msg sprintf(['  ExposureTriggerMissed = %d: the camera SAW the ', ...
                    'triggers but was still busy. The block is too short for this ROI ', ...
                    'and exposure -- raise cfg.guardNs or crop the ROI.\n'], nMiss)];
            elseif isfinite(nMiss) && nMiss == 0 && nGot == 0
                msg = [msg sprintf(['  ExposureTriggerMissed = 0 and nothing arrived, so ', ...
                    'no trigger ever reached the camera. Either PB did not run, or ', ...
                    'CamTrig (PB pin %d) is not reaching %s. Run ids_TriggerTest.\n'], ...
                    SequencePool('PBDictionary','CamTrig'), ...
                    char(string(obj.getf(obj.cfg,'triggerLine','Line2'))))];
            elseif ~isfinite(nMiss)
                msg = [msg sprintf(['  The missed-trigger counter is not available, so ', ...
                    '"camera never saw the line" and "camera was busy" cannot be told ', ...
                    'apart from here. Run ids_TriggerTest.\n'])];
            end
            msg = [msg '  Nothing was recorded for this sweep point.'];
        end

        function reportNotes(~, r)
        % Print any optional node that did not take. These are _try_set results
        % from the backend: the sync output and the missed-trigger counter are
        % allowed to fail, but silently skipping them would leave the run
        % without the telemetry it is supposed to have.
            if ~isfield(r,'notes') || isempty(r.notes); return; end
            notes = r.notes;
            if ~iscell(notes); notes = num2cell(notes); end
            for k = 1:numel(notes)
                n = notes{k};
                if isstruct(n) && isfield(n,'ok') && ~n.ok
                    if isfield(n,'error')
                        fprintf(2, '[IDS] node %s not set: %s\n', ...
                                char(string(n.node)), char(string(n.error)));
                    else
                        fprintf(2, '[IDS] node %s: asked %s, got %s\n', ...
                                char(string(n.node)), ...
                                char(string(jsonencode(n.wanted))), ...
                                char(string(jsonencode(n.got))));
                    end
                end
            end
        end

        function v = getf(~, s, name, dflt)
            v = dflt;
            if isstruct(s) && isfield(s, name) && ~isempty(s.(name)); v = s.(name); end
        end

        function v = orNull(obj, s, name)
        % [] in MATLAB -> null in JSON -> None in Python, meaning "you choose".
            v = obj.getf(s, name, []);
            if isempty(v); v = []; end
        end

        function v = num(~, r, name, dflt)
            v = dflt;
            if isstruct(r) && isfield(r, name) && ~isempty(r.(name)) && isnumeric(r.(name))
                v = double(r.(name));
            end
        end

        function v = str(~, r, name)
            v = '';
            if isstruct(r) && isfield(r, name) && ~isempty(r.(name))
                try; v = char(string(r.(name))); catch; v = ''; end
            end
        end
    end

    methods (Static)
        function ensurePython(cfg)
        % Load the right interpreter, or explain precisely what to do instead.
        %
        % A MATLAB session loads Python once and cannot swap it. So if 3.13 (the
        % machine default) is already loaded, no amount of pyenv() will help and
        % the only fix is a restart -- which is worth saying plainly here rather
        % than letting an import fail three calls later.
            pe = pyenv;
            if strcmp(pe.Status, 'NotLoaded')
                if exist(cfg.pythonExe, 'file') ~= 2
                    error('IDSCamInterface:NoPython', ...
                          ['IDSConfig.pythonExe points at %s, which does not exist. ', ...
                           'That interpreter must be Python 3.9-3.11 (R2023b will not ', ...
                           'load 3.12+) and must have harvesters, genicam and h5py.'], ...
                          cfg.pythonExe);
                end
                pyenv('Version', cfg.pythonExe);
                pe = pyenv;
            end

            % Compare major and minor as INTEGERS. Parsing "3.11" with str2double
            % gives 3.11, and 3.11 >= 3.9 is false -- the version-string-as-float
            % trap. That test rejected 3.10 and 3.11 (the versions actually
            % wanted) and accepted only 3.9.
            tok = regexp(char(pe.Version), '^(\d+)\.(\d+)', 'tokens', 'once');
            if numel(tok) ~= 2
                error('IDSCamInterface:BadPythonVersion', ...
                      'Could not parse the loaded Python version "%s".', ...
                      char(pe.Version));
            end
            major = str2double(tok{1});
            minor = str2double(tok{2});
            if ~(major == 3 && minor >= 9 && minor <= 11)
                error('IDSCamInterface:BadPythonVersion', ...
                      ['MATLAB has Python %s loaded, but R2023b only supports ', ...
                       '3.9-3.11. Restart MATLAB and run\n', ...
                       '    pyenv(''Version'', ''%s'')\n', ...
                       'BEFORE anything else touches py. (the first py. call of a ', ...
                       'session locks the interpreter in).'], ...
                      char(pe.Version), cfg.pythonExe);
            end

            % Put this folder on the Python path so ids_acquire is importable.
            here = fileparts(mfilename('fullpath'));
            if count(py.sys.path, here) == 0
                insert(py.sys.path, int32(0), here);
            end

            try
                py.importlib.import_module('ids_acquire');
            catch ME
                error('IDSCamInterface:ImportFailed', ...
                      ['Could not import ids_acquire from %s using %s.\n%s\n', ...
                       'Check that harvesters, genicam and h5py are installed in ', ...
                       'that interpreter.'], here, char(pe.Version), ME.message);
            end
        end

        function reload()
        % Re-import ids_acquire after editing it. MATLAB caches Python modules
        % for the life of the session, so an edit is otherwise invisible until
        % restart.
            py.importlib.reload(py.importlib.import_module('ids_acquire'));
            fprintf('[IDS] ids_acquire reloaded.\n');
        end
    end
end
