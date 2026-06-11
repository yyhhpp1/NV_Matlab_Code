function out = run_tb_queue_minimal(queueSteps, runtimeCtx)
%RUN_TB_QUEUE_MINIMAL Minimal (T -> B list) queue runner over v2.2 + spots.
%   out = v3_2.run_tb_queue_minimal(queueSteps, runtimeCtx)
%
% Inputs
%   queueSteps : struct array with fields:
%       .T_K        target temperature in K
%       .pidP       PID P for this T
%       .pidI       PID I for this T
%       .pidD       PID D for this T
%       .bListkG    numeric vector of B targets (kG) to run at this T
%
%   runtimeCtx : struct (optional)
%       .hFigAuto           handle to T1_SemiAuto_ParamInput_v2_1 (required)
%       .hFigMain           optional main GUI handle
%       .mode               final magnet mode for each B: 'driven'|'persistent'
%       .magnetCfg          cfg passed to set_z_magnet_mode
%       .bEstimateScale     B_estimate[G] = B[kG] * scale for v2.1 GUI
%       .tempBaseCfg        base cfg for set_temperature_safe (without PID fields)
%       .resetStopLatch     clear queue stop latch at start (default true)
%       .stopAppDataKey     stop latch key (default 'BT_CONTROL_STOP_B_QUEUE')
%       .writeStartLog      passed to inner run_b_field_queue_v2_1
%       .startLogPath       passed to inner run_b_field_queue_v2_1
%       .writeAnalysisSnippet passed to inner run_b_field_queue_v2_1
%       .analysisSnippetPath  passed to inner run_b_field_queue_v2_1
%       .notionParentPageKey optional notion page id/key for queued events
%       .testModeNoBT       skip temperature/magnet hardware control (default false)
%       .skipFirstMagControl skip first magnet control after Run (default false)
%       .skipFirstBTControl skip first temperature control and first magnet control after Run (default false)
%       .trackZAfterTemperatureChange run ImageNVC TrackZ after successful T set
%       .verbose            print logs (default true)
%
% Output
%   out: summary struct with per-temperature step results.

if nargin < 2 || isempty(runtimeCtx)
    runtimeCtx = struct();
end
ensure_bt_control_on_path();
runtimeCtx = apply_defaults(runtimeCtx);

validate_queue_steps(queueSteps);

rows = repmat(struct( ...
    'index', 0, ...
    'T_K', NaN, ...
    'pidP', NaN, ...
    'pidI', NaN, ...
    'pidD', NaN, ...
    'nB', 0, ...
    'temperatureStatus', '', ...
    'temperatureMessage', '', ...
    'temperatureInfo', struct(), ...
    'bRunOut', struct(), ...
    'masterDbRowsAdded', 0, ...
    'tempHistoryFilesSaved', 0, ...
    'tempHistoryWarnings', 0, ...
    'status', '', ...
    'message', ''), 0, 1);

out = struct();
out.startedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
out.finishedAt = '';
out.status = 'running';
out.stopReason = '';
out.rows = rows;
out.runRoot = '';
out.masterDbPath = '';
out.masterWarningsPath = '';
out.notionSpoolPath = '';
out.notionQueueLogPath = '';
out.notionUploadLogPath = '';

try
    out.runRoot = create_run_root(runtimeCtx.saveRoot);
    [out.masterDbPath, out.masterWarningsPath] = init_master_db(out.runRoot);
    [out.notionSpoolPath, out.notionQueueLogPath, out.notionUploadLogPath] = init_notion_event_logs(out.runRoot);
catch ME
    out.status = 'failed';
    out.stopReason = sprintf('Failed to initialize run folder/logs: %s', ME.message);
    out.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    return;
end

if runtimeCtx.resetStopLatch
    clear_stop_b_field_queue(struct( ...
        'stopAppDataKey', runtimeCtx.stopAppDataKey, ...
        'hFigAuto', runtimeCtx.hFigAuto, ...
        'verbose', runtimeCtx.verbose));
end

log_msg(runtimeCtx, sprintf('Queue start: %d T-steps, mode=%s, testModeNoBT=%d, skipFirstMagControl=%d, trackZAfterTemperatureChange=%d.', ...
    numel(queueSteps), char(string(runtimeCtx.mode)), logical(runtimeCtx.testModeNoBT), ...
    logical(runtimeCtx.skipFirstMagControl), logical(runtimeCtx.trackZAfterTemperatureChange)));

for i = 1:numel(queueSteps)
    step = queueSteps(i);

    row = struct( ...
        'index', i, ...
        'T_K', step.T_K, ...
        'pidP', step.pidP, ...
        'pidI', step.pidI, ...
        'pidD', step.pidD, ...
        'nB', numel(step.bListkG), ...
        'temperatureStatus', 'pending', ...
        'temperatureMessage', '', ...
        'temperatureInfo', struct(), ...
        'bRunOut', struct(), ...
        'masterDbRowsAdded', 0, ...
        'tempHistoryFilesSaved', 0, ...
        'tempHistoryWarnings', 0, ...
        'status', 'running', ...
        'message', '');

    [stopNow, stopWhy] = is_stop_requested(runtimeCtx);
    if stopNow
        row.status = 'stopped';
        row.message = stopWhy;
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'stopped';
        out.stopReason = stopWhy;
        break;
    end

    skipFirstBTThisStep = logical(runtimeCtx.skipFirstBTControl) && (i == 1);
    if runtimeCtx.testModeNoBT || runtimeCtx.skipTemperatureControl || skipFirstBTThisStep
        log_msg(runtimeCtx, sprintf('Step %d/%d: skip temperature set for T=%.6g K.', ...
            i, numel(queueSteps), step.T_K));
        row.temperatureStatus = 'skipped';
        if skipFirstBTThisStep && ~runtimeCtx.testModeNoBT && ~runtimeCtx.skipTemperatureControl
            row.temperatureMessage = 'Skipped first temperature control by runtimeCtx.skipFirstBTControl.';
        else
            row.temperatureMessage = 'Skipped temperature control by runtime settings.';
        end
        row.temperatureInfo = struct('ok', true, 'skipped', true, ...
            'testModeNoBT', logical(runtimeCtx.testModeNoBT), ...
            'skipTemperatureControl', logical(runtimeCtx.skipTemperatureControl), ...
            'skipFirstBTControl', skipFirstBTThisStep);
    else
        log_msg(runtimeCtx, sprintf('Step %d/%d: set T=%.6g K (PID=%.6g, %.6g, %.6g).', ...
            i, numel(queueSteps), step.T_K, step.pidP, step.pidI, step.pidD));

        tCfg = runtimeCtx.tempBaseCfg;
        tCfg.pidP = step.pidP;
        tCfg.pidI = step.pidI;
        tCfg.pidD = step.pidD;
        tCfg.stopCheckEnabled = true;
        tCfg.stopAppDataKey = runtimeCtx.stopAppDataKey;
        tCfg.hFigAuto = runtimeCtx.hFigAuto;
        if strcmpi(char(string(runtimeCtx.mode)), 'persistent')
            % For persistent-mode queue transitions, allow paused+HS-off only
            % when current is explicitly near zero.
            tCfg.magGateRequirePsZero = true;
            tCfg.magGateAllowPausedStateWithPsOff = true;
        end
        tCfg.verbose = runtimeCtx.verbose;
        if ~isfield(tCfg, 'stopWaitGranularitySec') || isempty(tCfg.stopWaitGranularitySec)
            tCfg.stopWaitGranularitySec = 2;
        end
        if ~isfield(tCfg, 'commMaxBlockSecWhenStop') || isempty(tCfg.commMaxBlockSecWhenStop)
            tCfg.commMaxBlockSecWhenStop = 2;
        end

        [okLaserOff, msgLaserOff] = force_pb7_laser_off_for_temperature();
        if ~okLaserOff
            row.temperatureStatus = 'failed';
            row.temperatureMessage = sprintf('Laser/PB7 off before temperature set failed: %s', msgLaserOff);
            row.status = 'failed';
            row.message = row.temperatureMessage;
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'failed';
            out.stopReason = row.message;
            break;
        end
        log_msg(runtimeCtx, sprintf('Step %d/%d: laser/PB7 forced off before temperature control.', ...
            i, numel(queueSteps)));

        log_msg(runtimeCtx, sprintf('Step %d/%d: temperature control begin (maxWait=%.6g s, poll=%.6g s, commCap=%.6g s).', ...
            i, numel(queueSteps), tCfg.maxWaitSec, tCfg.pollSec, tCfg.commMaxBlockSecWhenStop));

        [okT, msgT, infoT] = set_temperature_safe(step.T_K, tCfg);
        row.temperatureInfo = infoT;
        row.temperatureMessage = msgT;
        if ~okT
            isStopTemp = contains(lower(char(string(msgT))), 'stop requested');
            if isStopTemp
                row.temperatureStatus = 'stopped';
                row.status = 'stopped';
                row.message = sprintf('Temperature set stopped: %s', msgT);
                out.rows(end + 1, 1) = row; %#ok<AGROW>
                out.status = 'stopped';
                out.stopReason = row.message;
            else
                row.temperatureStatus = 'failed';
                row.status = 'failed';
                row.message = sprintf('Temperature set failed: %s', msgT);
                out.rows(end + 1, 1) = row; %#ok<AGROW>
                out.status = 'failed';
                out.stopReason = row.message;
            end
            break;
        end
        row.temperatureStatus = 'success';
        log_msg(runtimeCtx, sprintf('Step %d/%d: temperature control complete.', i, numel(queueSteps)));

        [okLaserOn, msgLaserOn] = force_pb7_laser_on_after_temperature();
        if ~okLaserOn
            row.status = 'failed';
            row.message = sprintf('Laser/PB7 on after temperature stabilization failed: %s', msgLaserOn);
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'failed';
            out.stopReason = row.message;
            break;
        end
        log_msg(runtimeCtx, sprintf('Step %d/%d: laser/PB7 turned on after temperature stabilization.', ...
            i, numel(queueSteps)));

        if runtimeCtx.trackZAfterTemperatureChange
            log_msg(runtimeCtx, sprintf('Step %d/%d: TrackZ after temperature change begin.', i, numel(queueSteps)));
            [okTrackZ, msgTrackZ] = run_image_gui_trackz_after_temperature(runtimeCtx);
            if ~okTrackZ
                row.status = 'failed';
                row.message = sprintf('TrackZ after temperature change failed: %s', msgTrackZ);
                out.rows(end + 1, 1) = row; %#ok<AGROW>
                out.status = 'failed';
                out.stopReason = row.message;
                break;
            end
            log_msg(runtimeCtx, sprintf('Step %d/%d: TrackZ after temperature change complete.', i, numel(queueSteps)));
        end
    end

    [stopNow, stopWhy] = is_stop_requested(runtimeCtx);
    if stopNow
        row.status = 'stopped';
        row.message = stopWhy;
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'stopped';
        out.stopReason = stopWhy;
        break;
    end

    log_msg(runtimeCtx, sprintf('Step %d/%d: run %d B points at T=%.6g K.', ...
        i, numel(queueSteps), numel(step.bListkG), step.T_K));

    bCfg = struct();
    bCfg.mode = runtimeCtx.mode;
    bCfg.magnetCfg = runtimeCtx.magnetCfg;
    bCfg.magnetCfg.verbose = runtimeCtx.verbose;
    if ~isfield(bCfg.magnetCfg, 'stopWaitGranularitySec') || isempty(bCfg.magnetCfg.stopWaitGranularitySec)
        bCfg.magnetCfg.stopWaitGranularitySec = 2;
    end
    if ~isfield(bCfg.magnetCfg, 'pollSec') || isempty(bCfg.magnetCfg.pollSec)
        bCfg.magnetCfg.pollSec = 1;
    end
    bCfg.hFigAuto = runtimeCtx.hFigAuto;
    bCfg.hFigMain = runtimeCtx.hFigMain;
    bCfg.bEstimateScale = runtimeCtx.bEstimateScale;
    bCfg.resetStopLatch = false;
    bCfg.stopAppDataKey = runtimeCtx.stopAppDataKey;
    bCfg.writeStartLog = runtimeCtx.writeStartLog;
    bCfg.startLogPath = resolve_step_log_path(runtimeCtx.startLogPath, out.runRoot, i, 'b_field_queue_start_log_step_%02d.csv');
    bCfg.writeAnalysisSnippet = runtimeCtx.writeAnalysisSnippet;
    bCfg.analysisSnippetPath = resolve_step_log_path(runtimeCtx.analysisSnippetPath, out.runRoot, i, 'b_field_queue_analysis_snippet_step_%02d.txt');
    bCfg.writeNotionSequenceLog = true;
    bCfg.notionSpoolPath = out.notionSpoolPath;
    bCfg.notionQueueLogPath = out.notionQueueLogPath;
    bCfg.notionPageKey = runtimeCtx.notionParentPageKey;
    bCfg.runRoot = out.runRoot;
    bCfg.masterDbPath = out.masterDbPath;
    bCfg.masterWarningsPath = out.masterWarningsPath;
    bCfg.tempBaseCfg = runtimeCtx.tempBaseCfg;
    bCfg.tempHistoryCfg = runtimeCtx.tempHistoryCfg;
    bCfg.tbStepIndex = i;
    bCfg.tSetK = step.T_K;
    bCfg.testModeNoBT = runtimeCtx.testModeNoBT;
    bCfg.skipFirstMagControl = (logical(runtimeCtx.skipFirstMagControl) || ...
        logical(runtimeCtx.skipFirstBTControl)) && (i == 1);
    bCfg.verbose = runtimeCtx.verbose;
    bCfg.skipTemperatureControl = runtimeCtx.skipTemperatureControl;

    bCfg.handlesImage = runtimeCtx.handlesImage;
    bCfg.hFigImage = runtimeCtx.hFigImage;
    bCfg.spots = runtimeCtx.spots;
    bCfg.spotSettleSec = runtimeCtx.spotSettleSec;
    bCfg.skipFieldControl = runtimeCtx.skipFieldControl;

    outB = v3_2.run_b_queue_multispot(step.bListkG, bCfg);
    row.bRunOut = outB;

    if isstruct(outB) && isfield(outB, 'rows') && ~isempty(outB.rows)
        totalAdded = 0;
        totalTempFiles = 0;
        totalTempWarn = 0;
        postProcStopped = false;
        postProcStopWhy = '';
        for iB = 1:numel(outB.rows)
            [stopNowPost, stopWhyPost] = is_stop_requested(runtimeCtx);
            if stopNowPost
                postProcStopped = true;
                postProcStopWhy = stopWhyPost;
                log_msg(runtimeCtx, sprintf('Step %d/%d: stop requested during post-processing at B item %d.', ...
                    i, numel(queueSteps), iB));
                break;
            end
            bItem = outB.rows(iB);
            if ~isstruct(bItem)
                continue;
            end
            if ~isfield(bItem, 'status') || ~strcmpi(char(string(bItem.status)), 'success')
                continue;
            end
            totalAdded = totalAdded + max(0, round(safe_struct_field(bItem, 'masterDbRowsAdded', 0)));
            totalTempFiles = totalTempFiles + max(0, round(safe_struct_field(bItem, 'tempHistoryFilesSaved', 0)));
            totalTempWarn = totalTempWarn + max(0, round(safe_struct_field(bItem, 'tempHistoryWarnings', 0)));
        end
        row.masterDbRowsAdded = totalAdded;
        row.tempHistoryFilesSaved = totalTempFiles;
        row.tempHistoryWarnings = totalTempWarn;
        if postProcStopped
            row.status = 'stopped';
            row.message = sprintf('Stopped during post-processing at T=%.6g K: %s', step.T_K, postProcStopWhy);
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'stopped';
            out.stopReason = row.message;
            break;
        end
    end

    if strcmpi(outB.status, 'failed')
        row.status = 'failed';
        row.message = sprintf('B queue failed at T=%.6g K: %s', step.T_K, safe_struct_field(outB, 'stopReason', ''));
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'failed';
        out.stopReason = row.message;
        break;
    end
    if strcmpi(outB.status, 'stopped')
        row.status = 'stopped';
        row.message = sprintf('Stopped during B queue at T=%.6g K: %s', step.T_K, safe_struct_field(outB, 'stopReason', ''));
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'stopped';
        out.stopReason = row.message;
        break;
    end

    % Between temperature steps, always ramp magnet back to zero field.
    % This is skipped in test mode where no hardware actions are performed.
    hasNextTStep = (i < numel(queueSteps));
    if hasNextTStep && ~runtimeCtx.testModeNoBT
        log_msg(runtimeCtx, sprintf('Step %d/%d complete: ramp magnet to 0 kG before next T step.', ...
            i, numel(queueSteps)));
        magZeroCfg = runtimeCtx.magnetCfg;
        magZeroCfg.zeroFirstDriven = true;
        magZeroCfg.zeroFirstPersistent = true;
        magZeroCfg.skipSecondRampIfTargetZero = true;
        magZeroCfg.stopCheckEnabled = true;
        magZeroCfg.stopAppDataKey = runtimeCtx.stopAppDataKey;
        magZeroCfg.hFigAuto = runtimeCtx.hFigAuto;
        magZeroCfg.verbose = runtimeCtx.verbose;
        if ~isfield(magZeroCfg, 'stopWaitGranularitySec') || isempty(magZeroCfg.stopWaitGranularitySec)
            magZeroCfg.stopWaitGranularitySec = 2;
        end
        if ~isfield(magZeroCfg, 'pollSec') || isempty(magZeroCfg.pollSec)
            magZeroCfg.pollSec = 1;
        end
        [okZero, msgZero] = set_z_magnet_mode(0, runtimeCtx.mode, magZeroCfg);
        if ~okZero
            row.status = 'failed';
            row.message = sprintf('Post-step zero-field ramp failed at T=%.6g K: %s', step.T_K, msgZero);
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'failed';
            out.stopReason = row.message;
            break;
        end
    end

    row.status = 'success';
    row.message = 'Completed';
    out.rows(end + 1, 1) = row; %#ok<AGROW>
end

if strcmp(out.status, 'running')
    out.status = 'finished';
end
out.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end

function [ok, msg] = run_image_gui_trackz_after_temperature(runtimeCtx)
ok = false;
msg = '';
figImage = safe_struct_field(runtimeCtx, 'hFigImage', []);
if isempty(figImage) || ~isgraphics(figImage, 'figure')
    msg = 'ImageNVC GUI figure is not bound.';
    return;
end

handlesImage = safe_struct_field(runtimeCtx, 'handlesImage', struct());
if isempty(handlesImage) || ~isstruct(handlesImage)
    try
        handlesImage = guidata(figImage);
    catch
        handlesImage = struct();
    end
end
if isempty(handlesImage) || ~isstruct(handlesImage)
    msg = 'ImageNVC handles are unavailable.';
    return;
end

hObject = figImage;
if isfield(handlesImage, 'TrackZ') && isgraphics(handlesImage.TrackZ, 'uicontrol')
    hObject = handlesImage.TrackZ;
end

try
    ImageFunctionPool('TrackZ', hObject, [], handlesImage);
    ok = true;
catch ME
    msg = ME.message;
end
end

function [ok, msg] = force_pb7_laser_off_for_temperature()
ok = false;
msg = '';

try
    if exist('PBFunctionPool', 'file') ~= 2
        msg = 'PBFunctionPool.m is not on the MATLAB path.';
        return;
    end
    PBFunctionPool('PBON', 0);
    ok = true;
catch ME
    msg = ME.message;
end
end

function [ok, msg] = force_pb7_laser_on_after_temperature()
ok = false;
msg = '';

try
    if exist('PBFunctionPool', 'file') ~= 2
        msg = 'PBFunctionPool.m is not on the MATLAB path.';
        return;
    end
    PBFunctionPool('PBON', 2^7);
    ok = true;
catch ME
    msg = ME.message;
end
end

function validate_queue_steps(queueSteps)
if ~isstruct(queueSteps)
    error('SmartT1:v3_1:InvalidQueue', 'queueSteps must be a struct array.');
end
required = {'T_K', 'pidP', 'pidI', 'pidD', 'bListkG'};
for i = 1:numel(required)
    if ~isfield(queueSteps, required{i})
        error('SmartT1:v3_1:InvalidQueue', 'queueSteps missing field: %s', required{i});
    end
end
for i = 1:numel(queueSteps)
    s = queueSteps(i);
    if ~(isnumeric(s.T_K) && isscalar(s.T_K) && isfinite(s.T_K))
        error('SmartT1:v3_1:InvalidQueue', 'queueSteps(%d).T_K must be finite scalar.', i);
    end
    if ~(isnumeric(s.pidP) && isscalar(s.pidP) && isfinite(s.pidP))
        error('SmartT1:v3_1:InvalidQueue', 'queueSteps(%d).pidP must be finite scalar.', i);
    end
    if ~(isnumeric(s.pidI) && isscalar(s.pidI) && isfinite(s.pidI))
        error('SmartT1:v3_1:InvalidQueue', 'queueSteps(%d).pidI must be finite scalar.', i);
    end
    if ~(isnumeric(s.pidD) && isscalar(s.pidD) && isfinite(s.pidD))
        error('SmartT1:v3_1:InvalidQueue', 'queueSteps(%d).pidD must be finite scalar.', i);
    end
    if ~(isnumeric(s.bListkG) && isvector(s.bListkG) && ~isempty(s.bListkG) && all(isfinite(s.bListkG)))
        error('SmartT1:v3_1:InvalidQueue', 'queueSteps(%d).bListkG must be a non-empty finite numeric vector.', i);
    end
end
end

function runtimeCtx = apply_defaults(runtimeCtx)
fileCfg = bt_control_cfg_load('run_tb_queue_minimal');
runtimeCtx = set_default(runtimeCtx, 'hFigAuto', cfg_file_value(fileCfg, 'hFigAuto', []));
runtimeCtx = set_default(runtimeCtx, 'hFigMain', cfg_file_value(fileCfg, 'hFigMain', []));
runtimeCtx = set_default(runtimeCtx, 'mode', cfg_file_value(fileCfg, 'mode', 'driven'));
runtimeCtx = set_default(runtimeCtx, 'magnetCfg', cfg_file_value(fileCfg, 'magnetCfg', struct()));
runtimeCtx = set_default(runtimeCtx, 'bEstimateScale', cfg_file_value(fileCfg, 'bEstimateScale', 1000));
runtimeCtx = set_default(runtimeCtx, 'tempBaseCfg', cfg_file_value(fileCfg, 'tempBaseCfg', default_temp_base_cfg()));
runtimeCtx = set_default(runtimeCtx, 'resetStopLatch', cfg_file_value(fileCfg, 'resetStopLatch', true));
runtimeCtx = set_default(runtimeCtx, 'stopAppDataKey', cfg_file_value(fileCfg, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE'));
runtimeCtx = set_default(runtimeCtx, 'writeStartLog', cfg_file_value(fileCfg, 'writeStartLog', false));
runtimeCtx = set_default(runtimeCtx, 'startLogPath', cfg_file_value(fileCfg, 'startLogPath', ''));
runtimeCtx = set_default(runtimeCtx, 'writeAnalysisSnippet', cfg_file_value(fileCfg, 'writeAnalysisSnippet', false));
runtimeCtx = set_default(runtimeCtx, 'analysisSnippetPath', cfg_file_value(fileCfg, 'analysisSnippetPath', ''));
runtimeCtx = set_default(runtimeCtx, 'notionParentPageKey', cfg_file_value(fileCfg, 'notionParentPageKey', ''));
runtimeCtx = set_default(runtimeCtx, 'testModeNoBT', cfg_file_value(fileCfg, 'testModeNoBT', false));
runtimeCtx = set_default(runtimeCtx, 'skipTemperatureControl', false);
runtimeCtx = set_default(runtimeCtx, 'skipFieldControl', false);
runtimeCtx = set_default(runtimeCtx, 'skipFirstMagControl', cfg_file_value(fileCfg, 'skipFirstMagControl', false));
runtimeCtx = set_default(runtimeCtx, 'skipFirstBTControl', cfg_file_value(fileCfg, 'skipFirstBTControl', false));
runtimeCtx = set_default(runtimeCtx, 'trackZAfterTemperatureChange', cfg_file_value(fileCfg, 'trackZAfterTemperatureChange', false));
runtimeCtx = set_default(runtimeCtx, 'tempHistoryCfg', cfg_file_value(fileCfg, 'tempHistoryCfg', default_temp_history_cfg()));
runtimeCtx = set_default(runtimeCtx, 'saveRoot', cfg_file_value(fileCfg, 'saveRoot', fullfile(get_v32_root_dir(), 'AutoRunSequences_v3_2_Saves')));
runtimeCtx = set_default(runtimeCtx, 'spots', repmat(v3_2.new_spot(), 0, 1));
runtimeCtx = set_default(runtimeCtx, 'spotSettleSec', 0.05);
runtimeCtx = set_default(runtimeCtx, 'hFigImage', []);
runtimeCtx = set_default(runtimeCtx, 'handlesImage', struct());
runtimeCtx = set_default(runtimeCtx, 'verbose', cfg_file_value(fileCfg, 'verbose', true));
end

function cfg = default_temp_base_cfg()
cfg = struct();
cfg.tcIp = '192.168.0.116';
cfg.magIp = '192.168.0.101';
cfg.T_safe_max = 8;
cfg.T_tol = 0.02;
cfg.holdSec = 30;
cfg.maxWaitSec = 1800;
cfg.pollSec = 1;
cfg.lookbackMin = 5;
cfg.commRetryCount = 3;
cfg.commRetryBackoffSec = 0.5;
cfg.tcConnectTimeoutSec = 20;
cfg.tcResponseTimeoutSec = 30;
cfg.magPort = 7185;
cfg.magTimeoutSec = 3;
cfg.verbose = false;
end

function cfg = default_temp_history_cfg()
cfg = struct();
cfg.enabled = true;
cfg.channels = [3 8];
cfg.lookbackHours = 0.5;
cfg.maxLoopbackHours = 2;
cfg.estUtcOffsetHours = -5;
cfg.savePlotPng = true;
end

function s = set_default(s, key, val)
if ~isfield(s, key) || isempty(s.(key))
    s.(key) = val;
end
end

function v = cfg_file_value(s, key, fallback)
if isstruct(s) && isfield(s, key) && ~isempty(s.(key))
    v = s.(key);
else
    v = fallback;
end
end

function [tf, reason] = is_stop_requested(runtimeCtx)
tf = false;
reason = '';

try
    latched = getappdata(0, runtimeCtx.stopAppDataKey);
catch
    latched = false;
end
if ~isempty(latched) && logical(latched)
    tf = true;
    reason = 'Stop requested by stop latch.';
    return;
end

if isempty(runtimeCtx.hFigAuto) || ~(ishandle(runtimeCtx.hFigAuto) || isgraphics(runtimeCtx.hFigAuto))
    return;
end
try
    hAuto = guidata(runtimeCtx.hFigAuto);
    if isstruct(hAuto) && isfield(hAuto, 'pushbutton_stopProg') && isgraphics(hAuto.pushbutton_stopProg, 'uicontrol')
        ud = get(hAuto.pushbutton_stopProg, 'UserData');
        if ~isempty(ud) && logical(ud)
            tf = true;
            reason = 'Stop requested by v2.1 stop button.';
        end
    end
catch
end
end

function log_msg(runtimeCtx, txt)
if isfield(runtimeCtx, 'verbose') && runtimeCtx.verbose
    fprintf('[run_tb_queue_minimal] %s\n', txt);
end
end

function out = safe_struct_field(s, fieldName, fallback)
out = fallback;
if isstruct(s) && isfield(s, fieldName)
    out = s.(fieldName);
end
end

function [nFiles, nWarn] = save_temperature_history_for_point(runRoot, warningsPath, runtimeCtx, stepIdx, bIdx, tSetK, bSetG)
nFiles = 0;
nWarn = 0;

histCfg = safe_struct_field(runtimeCtx, 'tempHistoryCfg', default_temp_history_cfg());
if ~logical(safe_struct_field(histCfg, 'enabled', true))
    return;
end

tcBase = safe_struct_field(runtimeCtx, 'tempBaseCfg', struct());
tcIp = strtrim(char(string(safe_struct_field(tcBase, 'tcIp', ''))));
if isempty(tcIp)
    append_warning_line(warningsPath, 'Temperature history capture skipped: tempBaseCfg.tcIp is empty.');
    nWarn = nWarn + 1;
    return;
end

channels = double(safe_struct_field(histCfg, 'channels', [3 8]));
channels = unique(round(channels(isfinite(channels))));
channels = channels(channels >= 1);
if isempty(channels)
    append_warning_line(warningsPath, 'Temperature history capture skipped: no valid channels configured.');
    nWarn = nWarn + 1;
    return;
end

lookbackHours = double(safe_struct_field(histCfg, 'lookbackHours', 0.5));
if ~isfinite(lookbackHours) || lookbackHours <= 0
    lookbackHours = 0.5;
end
lookbackMin = lookbackHours * 60;
estOffsetH = double(safe_struct_field(histCfg, 'estUtcOffsetHours', -5));
if ~isfinite(estOffsetH)
    estOffsetH = -5;
end
savePlotPng = logical(safe_struct_field(histCfg, 'savePlotPng', true));

readCfg = struct();
readCfg.connectTimeoutSec = min(double(safe_struct_field(tcBase, 'tcConnectTimeoutSec', 20)), 5);
readCfg.responseTimeoutSec = min(double(safe_struct_field(tcBase, 'tcResponseTimeoutSec', 30)), 5);

pointDir = fullfile(runRoot, 'temperature_history', sprintf('step_%02d_b_%02d', stepIdx, bIdx));
if ~isfolder(pointDir)
    [okMk, msgMk, idMk] = mkdir(pointDir);
    if ~okMk
        append_warning_line(warningsPath, sprintf('Temperature history folder create failed "%s": %s (%s)', pointDir, msgMk, idMk));
        nWarn = nWarn + 1;
        return;
    end
end

for iCh = 1:numel(channels)
    ch = channels(iCh);
    [okHist, tempK, tsPosix, msgHist] = bf_tc_read_channel_history(tcIp, ch, lookbackMin, readCfg);
    if ~okHist
        append_warning_line(warningsPath, sprintf('Temperature history read failed (step=%d, b=%d, ch=%d): %s', ...
            stepIdx, bIdx, ch, msgHist));
        nWarn = nWarn + 1;
        continue;
    end
    if isempty(tempK) || isempty(tsPosix)
        append_warning_line(warningsPath, sprintf('Temperature history empty (step=%d, b=%d, ch=%d).', ...
            stepIdx, bIdx, ch));
        nWarn = nWarn + 1;
        continue;
    end

    dtUtc = datetime(tsPosix, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
    dtEst = dtUtc + hours(estOffsetH);
    dtEst.TimeZone = '';

    txtPath = fullfile(pointDir, sprintf('ch%d_T_vs_time_EST.txt', ch));
    [okTxt, txtErr] = write_channel_history_txt(txtPath, ch, dtEst, tempK, lookbackHours, tSetK, bSetG, estOffsetH);
    if ~okTxt
        append_warning_line(warningsPath, sprintf('Temperature history TXT save failed (step=%d, b=%d, ch=%d): %s', ...
            stepIdx, bIdx, ch, txtErr));
        nWarn = nWarn + 1;
    else
        nFiles = nFiles + 1;
    end

    if savePlotPng
        pngPath = fullfile(pointDir, sprintf('ch%d_T_vs_time_EST.png', ch));
        [okPng, pngErr] = save_channel_history_plot_png(pngPath, ch, dtEst, tempK, tSetK, bSetG, estOffsetH);
        if ~okPng
            append_warning_line(warningsPath, sprintf('Temperature history plot save failed (step=%d, b=%d, ch=%d): %s', ...
                stepIdx, bIdx, ch, pngErr));
            nWarn = nWarn + 1;
        else
            nFiles = nFiles + 1;
        end
    end
end
end

function [ok, errMsg] = write_channel_history_txt(txtPath, ch, dtEst, tempK, lookbackHours, tSetK, bSetG, estOffsetH)
ok = false;
errMsg = '';

[fid, msg] = fopen(txtPath, 'w');
if fid < 0
    errMsg = sprintf('Cannot open "%s": %s', txtPath, msg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, '# Channel: %d\n', ch);
fprintf(fid, '# Time zone: EST (UTC%+.0f)\n', estOffsetH);
fprintf(fid, '# LookbackHours: %.6g\n', lookbackHours);
fprintf(fid, '# T_set_K: %.12g\n', double(tSetK));
fprintf(fid, '# B_set_G: %.12g\n', double(bSetG));
fprintf(fid, '# GeneratedAt: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'));
fprintf(fid, 'time_EST\ttemperature_K\n');

for i = 1:numel(tempK)
    tStr = datestr(dtEst(i), 'yyyy-mm-dd HH:MM:SS');
    fprintf(fid, '%s\t%.12g\n', tStr, double(tempK(i)));
end
ok = true;
end

function [ok, errMsg] = save_channel_history_plot_png(pngPath, ch, dtEst, tempK, tSetK, bSetG, estOffsetH)
ok = false;
errMsg = '';
h = [];
try
    h = figure('Visible', 'off', 'Color', 'w');
    x = datenum(dtEst);
    plot(x, tempK, '-', 'LineWidth', 1.2);
    grid on;
    datetick('x', 'yyyy-mm-dd HH:MM', 'keeplimits');
    xlabel(sprintf('Time (EST, UTC%+.0f)', estOffsetH));
    ylabel(sprintf('CH%d Temperature (K)', ch));
    title(sprintf('CH%d T vs Time | Tset=%.6g K | Bset=%.6g G', ch, double(tSetK), double(bSetG)));
    saveas(h, pngPath);
    ok = true;
catch ME
    errMsg = ME.message;
end
if ~isempty(h) && isgraphics(h)
    close(h);
end
end

function ensure_bt_control_on_path()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);
rootDir = fileparts(fileparts(thisDir));
btDir = fullfile(rootDir, 'AutoRunSequences_v3_1', 'BT_Control');

requiredFns = {'set_temperature_safe', 'run_b_field_queue_v2_1', 'clear_stop_b_field_queue', 'bf_tc_read_channel_history'};
for i = 1:numel(requiredFns)
    if exist(requiredFns{i}, 'file') ~= 2
        if isfolder(btDir)
            addpath(btDir);
        end
        break;
    end
end

for i = 1:numel(requiredFns)
    if exist(requiredFns{i}, 'file') ~= 2
        error('SmartT1:v3_1:BTControlMissing', ...
            'Cannot find %s.m. Expected under %s', requiredFns{i}, btDir);
    end
end
end

function runRoot = create_run_root(saveRoot)
if nargin < 1 || isempty(saveRoot)
    rootDir = get_v32_root_dir();
    savesDir = fullfile(rootDir, 'AutoRunSequences_v3_2_Saves');
else
    savesDir = char(string(saveRoot));
end
if ~isfolder(savesDir)
    [okMk, msgMk, idMk] = mkdir(savesDir);
    if ~okMk
        error('SmartT1:v3_1:RunRootCreateFailed', 'Cannot create saves folder "%s": %s (%s)', savesDir, msgMk, idMk);
    end
end

ts = datestr(now, 'yyyymmdd_HHMMSS_FFF');
runRoot = fullfile(savesDir, sprintf('TB_Run_%s', ts));
[okRun, msgRun, idRun] = mkdir(runRoot);
if ~okRun
    error('SmartT1:v3_1:RunRootCreateFailed', 'Cannot create run folder "%s": %s (%s)', runRoot, msgRun, idRun);
end
end

function [masterDbPath, warningsPath] = init_master_db(runRoot)
masterDbPath = fullfile(runRoot, 'master_db.csv');
warningsPath = fullfile(runRoot, 'master_db_warnings.log');

[fidDb, msgDb] = fopen(masterDbPath, 'w');
if fidDb < 0
    error('SmartT1:v3_1:MasterDbInitFailed', 'Cannot create master DB "%s": %s', masterDbPath, msgDb);
end
cleanupDb = onCleanup(@() fclose(fidDb)); %#ok<NASGU>
fprintf(fidDb, 'B_set,B_meas,T,measurement_family,group,measurement_type,sequence_name,date,num,spot_name,spot_order,spot_folder,comment\n');

[fidWarn, msgWarn] = fopen(warningsPath, 'w');
if fidWarn < 0
    error('SmartT1:v3_1:MasterDbInitFailed', 'Cannot create warning log "%s": %s', warningsPath, msgWarn);
end
cleanupWarn = onCleanup(@() fclose(fidWarn)); %#ok<NASGU>
fprintf(fidWarn, '[%s] master_db warning log initialized\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'));
end

function [spoolPath, queueLogPath, uploadLogPath] = init_notion_event_logs(runRoot)
spoolPath = fullfile(runRoot, 'notion_spool.jsonl');
queueLogPath = fullfile(runRoot, 'notion_queue_log.csv');
uploadLogPath = fullfile(runRoot, 'notion_upload_log.csv');

[fidSpool, msgSpool] = fopen(spoolPath, 'w');
if fidSpool < 0
    error('SmartT1:v3_1:NotionLogInitFailed', ...
        'Cannot create notion spool "%s": %s', spoolPath, msgSpool);
end
cleanupSpool = onCleanup(@() fclose(fidSpool)); %#ok<NASGU>

[fidQueue, msgQueue] = fopen(queueLogPath, 'w');
if fidQueue < 0
    error('SmartT1:v3_1:NotionLogInitFailed', ...
        'Cannot create notion queue log "%s": %s', queueLogPath, msgQueue);
end
cleanupQueue = onCleanup(@() fclose(fidQueue)); %#ok<NASGU>
fprintf(fidQueue, 'timestamp,status,op,sequence_name,save_string,figure_path,message\n');
end

function append_warning_line(warningsPath, msg)
[fid, fopenMsg] = fopen(warningsPath, 'a');
if fid < 0
    fprintf('[run_tb_queue_minimal] warning log write failed (%s): %s\n', warningsPath, fopenMsg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '[%s] %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'), char(string(msg)));
end

function outPath = resolve_step_log_path(inPath, runRoot, stepIdx, defaultPattern)
if ~isempty(inPath)
    outPath = inPath;
    return;
end
outPath = fullfile(runRoot, sprintf(defaultPattern, stepIdx));
end

function rootDir = get_v32_root_dir()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);
rootDir = fileparts(fileparts(thisDir));
end
