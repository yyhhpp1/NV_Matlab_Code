function [ok, message, result] = autotune_pid_temperature_range(TRangeK, nPoints, cfg)
%AUTOTUNE_PID_TEMPERATURE_RANGE Standalone PID autotune over a temperature range.
%   [ok, message, result] = autotune_pid_temperature_range(TRangeK, nPoints, cfg)
%
% Inputs
%   TRangeK : [Tmin Tmax] in Kelvin
%   nPoints : number of tune points (>=2)
%   cfg     : struct
%
% Required cfg fields:
%   tcIp
%   pidBounds struct with: Pmin,Pmax,Imin,Imax,Dmin,Dmax
%   initialPid struct with: P,I,D (canonical coefficients Kp,Ki,Kd)
%
% Optional cfg fields:
%   heaterNr                (default 4)
%   controlChannel          (default 8)
%   pollSec                 (default 2.0)
%   lookbackMin             (default 5)
%   commRetryCount          (default 3)
%   commRetryBackoffSec     (default 0.5)
%   verifyTol               (default 1e-12)
%   pidMin                  (default 0)
%   verifyRetryWithMinClamp (default true)
%   pidControlMode          (default 'conventional') % 'conventional' | 'step'
%   pidModeValue            (default 1) % Bluefors heater pid_mode value
%   identificationPidControlMode (default '') % empty => pidControlMode
%   identificationPidModeValue   (default []) % empty => pidModeValue
%   identificationControlAlgorithm (default []) % empty => by mode
%   conventionalControlAlgorithm (default 1)
%   stepControlAlgorithm    (default 2)
%   stepCoeffScale          (default 100)
%   conventionalTiMin       (default 1e-9)
%   conventionalTiMax       (default 1e9)
%   settleTolK              (default 0.02)
%   settleHoldSec           (default 60)
%   settleTimeoutSec        (default 1800)
%   idStepDeltaK            (default 0.05) scalar, Nx2 schedule [T,deltaK], or function_handle(T)->deltaK
%   idTimeoutSec            (default 900)
%   idMinResponseK          (default 0.01)
%   lambdaFactor            (default 2.0)
%   validateTimeoutSec      (default 1200)
%   maxOvershootK           (default 0.05)
%   maxAbsErrorK            (default 0.5)
%   interpolationMethod     (default 'linear')
%   profileExtrapolation    (default 'extrap') % 'extrap' or numeric scalar
%   profileMonotonicMode    (default 'off') % 'off'|'nondecreasing'|'nonincreasing'
%   logRoot                 (default pwd)
%   logPrefix               (default 'PID_AutoTune')
%   verbose                 (default true)

ok = false;
message = '';
result = struct();

if nargin < 3 || ~isstruct(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

result.startedAt = now_stamp();
result.endedAt = '';
result.ok = false;
result.message = '';
result.config = cfg;
result.request = struct('TRangeK', TRangeK, 'nPoints', nPoints);
result.runFolder = '';
result.stepLogPath = '';
result.profileLogPath = '';
result.resultMatPath = '';
result.points = repmat(new_point_record(), 0, 1);
result.profile = struct('Tgrid', [], 'Pgrid', [], 'Igrid', [], 'Dgrid', [], ...
    'pidControlMode', '', 'controllerCoeffNames', [], 'method', char(cfg.interpolationMethod));
result.finalState = struct('heaterActive', NaN, 'setpointK', NaN, 'pid', new_pid(NaN, NaN, NaN), ...
    'pidController', new_pid(NaN, NaN, NaN), 'pidControlMode', '', 'message', '');
result.failureSummary = '';

[valid, errMsg] = validate_inputs(TRangeK, nPoints, cfg);
if ~valid
    message = errMsg;
    result.message = message;
    result.failureSummary = message;
    result.endedAt = now_stamp();
    return;
end

cfg.pidControlMode = normalize_pid_control_mode(cfg.pidControlMode);

runMode = cfg.pidControlMode;
runPidModeValue = cfg.pidModeValue;
[runHasAlg, runAlg] = selected_control_algorithm(cfg, runMode, []);
runCtx = struct( ...
    'mode', runMode, ...
    'pidModeValue', runPidModeValue, ...
    'hasControlAlgorithm', runHasAlg, ...
    'controlAlgorithm', runAlg, ...
    'label', 'run');

idMode = runMode;
if ~isempty(cfg.identificationPidControlMode)
    idMode = normalize_pid_control_mode(cfg.identificationPidControlMode);
end
idPidModeValue = runPidModeValue;
if ~isempty(cfg.identificationPidModeValue)
    idPidModeValue = cfg.identificationPidModeValue;
end
[idHasAlg, idAlg] = selected_control_algorithm(cfg, idMode, cfg.identificationControlAlgorithm);
idCtx = struct( ...
    'mode', idMode, ...
    'pidModeValue', idPidModeValue, ...
    'hasControlAlgorithm', idHasAlg, ...
    'controlAlgorithm', idAlg, ...
    'label', 'identification');

result.profile.pidControlMode = runCtx.mode;
result.profile.controllerCoeffNames = controller_coeff_names(runCtx.mode);
result.profile.runPidControlMode = runCtx.mode;
result.profile.identificationPidControlMode = idCtx.mode;
result.profile.runControllerCoeffNames = controller_coeff_names(runCtx.mode);
result.profile.identificationControllerCoeffNames = controller_coeff_names(idCtx.mode);

Tmin = min(TRangeK);
Tmax = max(TRangeK);
Tpoints = linspace(Tmin, Tmax, nPoints).';

[okFolder, runFolder, stepLogPath, profileLogPath, resultMatPath, folderMsg] = setup_log_paths(cfg);
if ~okFolder
    message = folderMsg;
    result.message = message;
    result.failureSummary = message;
    result.endedAt = now_stamp();
    return;
end
result.runFolder = runFolder;
result.stepLogPath = stepLogPath;
result.profileLogPath = profileLogPath;
result.resultMatPath = resultMatPath;

if cfg.verbose
    fprintf('[autotune_pid_temperature_range] Run folder: %s\n', runFolder);
    fprintf('[autotune_pid_temperature_range] Run mode=%s pid_mode=%d control_algorithm=%s\n', ...
        runCtx.mode, runCtx.pidModeValue, control_algorithm_label(runCtx.hasControlAlgorithm, runCtx.controlAlgorithm));
    fprintf('[autotune_pid_temperature_range] ID  mode=%s pid_mode=%d control_algorithm=%s\n', ...
        idCtx.mode, idCtx.pidModeValue, control_algorithm_label(idCtx.hasControlAlgorithm, idCtx.controlAlgorithm));
end

[okStepLog, stepLogMsg] = init_step_log(stepLogPath);
if ~okStepLog
    message = stepLogMsg;
    result.message = message;
    result.failureSummary = message;
    result.endedAt = now_stamp();
    return;
end

currentPid = new_pid(cfg.initialPid.P, cfg.initialPid.I, cfg.initialPid.D);
acceptedMask = false(numel(Tpoints), 1);
fatalAbort = false;
fatalMessage = '';

for i = 1:numel(Tpoints)
    Ti = Tpoints(i);
    rec = new_point_record();
    rec.index = i;
    rec.targetK = Ti;
    rec.stage = 'start';
    rec.pidStart = currentPid;

    vlog('Point %d/%d target=%.6g K', i, numel(Tpoints), Ti);

    % Stage A: apply current PID at point and settle.
    vlog('Stage A: apply current PID and verify at target %.6g K', Ti);
    [okApplyA, msgApplyA, outApplyA] = apply_pid_setpoint_verified(Ti, currentPid, runCtx);
    rec.pidRequested = outApplyA.pidRequested;
    rec.pidReadback1 = outApplyA.pidReadback1;
    rec.pidRetryRequested = outApplyA.pidRetryRequested;
    rec.pidReadback2 = outApplyA.pidReadback2;
    rec.verifyPassed = outApplyA.verifyPassed;
    rec.verifyMessage = outApplyA.verifyMessage;
    rec.usedClampRetry = outApplyA.usedClampRetry;
    if ~okApplyA
        rec.status = 'fatal_fail';
        rec.stage = 'apply_start_pid';
        rec.message = sprintf('PID set/verify failed at stage A: %s', msgApplyA);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        fatalAbort = true;
        fatalMessage = rec.message;
        vlog('Stage A failed: %s', rec.message);
        break;
    end
    vlog('Stage A verify passed. Settling at %.6g K', Ti);

    [okSettleA, settleA, msgSettleA] = wait_temperature_settle(Ti, cfg.settleTimeoutSec, cfg.settleTolK, cfg.settleHoldSec);
    rec.settleBefore = settleA;
    if ~okSettleA
        rec.status = settleA.status;
        rec.stage = 'settle_before_id';
        rec.message = sprintf('Settle-before-ID failed: %s', msgSettleA);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        if settleA.hardFailure
            fatalAbort = true;
            fatalMessage = rec.message;
            vlog('Settle-before-ID hard failure: %s', rec.message);
            break;
        end
        vlog('Settle-before-ID soft failure: %s', rec.message);
        continue;
    end

    % Stage B: identification step.
    [okDeltaK, deltaIdK, deltaMsg] = evaluate_id_step_deltaK(cfg, Ti);
    if ~okDeltaK
        rec.status = 'fatal_fail';
        rec.stage = 'id_step_delta';
        rec.message = sprintf('Invalid ID step delta at %.6g K: %s', Ti, deltaMsg);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        fatalAbort = true;
        fatalMessage = rec.message;
        vlog('ID step delta evaluation failed: %s', rec.message);
        break;
    end
    Tstep = Ti + deltaIdK;
    rec.identificationDeltaK = deltaIdK;
    rec.identificationStepSetpointK = Tstep;
    vlog('Stage B: apply ID step delta %.6g K to %.6g K', deltaIdK, Tstep);

    [okApplyB, msgApplyB, outApplyB] = apply_pid_setpoint_verified(Tstep, currentPid, idCtx);
    if ~okApplyB
        rec.status = 'fatal_fail';
        rec.stage = 'apply_id_step';
        rec.message = sprintf('PID set/verify failed at stage B: %s', msgApplyB);
        rec.pidRequested = outApplyB.pidRequested;
        rec.pidReadback1 = outApplyB.pidReadback1;
        rec.pidRetryRequested = outApplyB.pidRetryRequested;
        rec.pidReadback2 = outApplyB.pidReadback2;
        rec.verifyPassed = outApplyB.verifyPassed;
        rec.verifyMessage = outApplyB.verifyMessage;
        rec.usedClampRetry = outApplyB.usedClampRetry;
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        fatalAbort = true;
        fatalMessage = rec.message;
        vlog('Stage B failed: %s', rec.message);
        break;
    end

    vlog('Stage B verify passed. Collecting step response');
    [okResp, respData, msgResp] = collect_step_response(Tstep, cfg.idTimeoutSec);
    rec.identification = respData;
    if ~okResp
        rec.status = respData.status;
        rec.stage = 'collect_step_response';
        rec.message = sprintf('Step-response collection failed: %s', msgResp);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        if respData.hardFailure
            fatalAbort = true;
            fatalMessage = rec.message;
            vlog('Step-response hard failure: %s', rec.message);
            break;
        end
        vlog('Step-response soft failure: %s', rec.message);
        continue;
    end

    [okFit, model, msgFit] = fit_fopdt(respData.tSec, respData.tempK, deltaIdK, cfg.idMinResponseK);
    rec.model = model;
    if ~okFit
        rec.status = 'rejected_fit';
        rec.stage = 'fit_model';
        rec.message = msgFit;
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        vlog('Model fit rejected: %s', msgFit);
        continue;
    end
    vlog('Model fit OK: Kproc=%.6g L=%.6g tau=%.6g', model.Kproc, model.L, model.tau);

    [okPidRaw, pidRaw, msgPidRaw] = compute_pid_imc(model, cfg.lambdaFactor, cfg.pollSec);
    rec.pidCandidateRaw = pidRaw;
    if ~okPidRaw
        rec.status = 'rejected_pid_compute';
        rec.stage = 'compute_pid';
        rec.message = msgPidRaw;
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        vlog('PID compute rejected: %s', msgPidRaw);
        continue;
    end

    pidCandidate = clamp_pid(pidRaw, cfg.pidBounds);
    rec.pidCandidateClamped = pidCandidate;
    vlog('Stage C candidate PID raw [%.6g %.6g %.6g], clamped [%.6g %.6g %.6g]', ...
        pidRaw.P, pidRaw.I, pidRaw.D, pidCandidate.P, pidCandidate.I, pidCandidate.D);

    % Stage C: apply candidate at Ti, verify, and validate.
    vlog('Stage C: apply candidate PID at %.6g K', Ti);
    [okApplyC, msgApplyC, outApplyC] = apply_pid_setpoint_verified(Ti, pidCandidate, runCtx);
    rec.pidRequested = outApplyC.pidRequested;
    rec.pidReadback1 = outApplyC.pidReadback1;
    rec.pidRetryRequested = outApplyC.pidRetryRequested;
    rec.pidReadback2 = outApplyC.pidReadback2;
    rec.verifyPassed = outApplyC.verifyPassed;
    rec.verifyMessage = outApplyC.verifyMessage;
    rec.usedClampRetry = outApplyC.usedClampRetry;
    if ~okApplyC
        rec.status = 'fatal_fail';
        rec.stage = 'apply_candidate_pid';
        rec.message = sprintf('PID set/verify failed at stage C: %s', msgApplyC);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        fatalAbort = true;
        fatalMessage = rec.message;
        vlog('Stage C failed: %s', rec.message);
        break;
    end

    vlog('Stage C verify passed. Running validation settle');
    [okVal, valInfo, msgVal] = wait_temperature_settle(Ti, cfg.validateTimeoutSec, cfg.settleTolK, cfg.settleHoldSec);
    rec.validation = valInfo;
    if ~okVal
        rec.status = valInfo.status;
        rec.stage = 'validate';
        rec.message = sprintf('Validation failed: %s', msgVal);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        if valInfo.hardFailure
            fatalAbort = true;
            fatalMessage = rec.message;
            vlog('Validation hard failure: %s', rec.message);
            break;
        end
        vlog('Validation soft failure: %s', rec.message);
        continue;
    end
    if valInfo.overshootK > cfg.maxOvershootK
        rec.status = 'rejected_overshoot';
        rec.stage = 'validate';
        rec.message = sprintf('Overshoot %.6g K exceeds limit %.6g K.', valInfo.overshootK, cfg.maxOvershootK);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        vlog('Validation rejected (overshoot): %s', rec.message);
        continue;
    end
    if valInfo.maxAbsErrorK > cfg.maxAbsErrorK
        rec.status = 'rejected_abs_error';
        rec.stage = 'validate';
        rec.message = sprintf('Max abs error %.6g K exceeds limit %.6g K.', valInfo.maxAbsErrorK, cfg.maxAbsErrorK);
        result.points(end + 1, 1) = rec; %#ok<AGROW>
        append_step_log_row(stepLogPath, rec);
        vlog('Validation rejected (abs error): %s', rec.message);
        continue;
    end

    rec.pidAccepted = outApplyC.pidAppliedCanonical;
    rec.pidAcceptedController = outApplyC.pidAppliedController;
    rec.status = 'accepted';
    rec.stage = 'done';
    rec.message = 'Point accepted.';
    acceptedMask(i) = true;
    currentPid = rec.pidAccepted;
    result.points(end + 1, 1) = rec; %#ok<AGROW>
    append_step_log_row(stepLogPath, rec);
    vlog('Point accepted. Canonical PID=[%.6g %.6g %.6g], controller coeffs=[%.6g %.6g %.6g]', ...
        currentPid.P, currentPid.I, currentPid.D, ...
        rec.pidAcceptedController.P, rec.pidAcceptedController.I, rec.pidAcceptedController.D);
end

if fatalAbort
    [~, offMsg] = send_heater_off();
    message = sprintf('%s Heater OFF: %s', fatalMessage, offMsg);
    result.message = message;
    result.failureSummary = fatalMessage;
    result.finalState.heaterActive = false;
    result.finalState.message = offMsg;
    result.ok = false;
    result.endedAt = now_stamp();
    save_result_mat(resultMatPath, result);
    vlog('Fatal abort. %s', message);
    ok = false;
    return;
end

acceptedIdx = find(acceptedMask);
if numel(acceptedIdx) < 2
    [~, offMsg] = send_heater_off();
    message = sprintf('Autotune failed: only %d point(s) accepted (<2). Heater OFF: %s', numel(acceptedIdx), offMsg);
    result.message = message;
    result.failureSummary = message;
    result.finalState.heaterActive = false;
    result.finalState.message = offMsg;
    result.ok = false;
    result.endedAt = now_stamp();
    save_result_mat(resultMatPath, result);
    vlog('Autotune failed: %s', message);
    ok = false;
    return;
end

Tgrid = zeros(numel(acceptedIdx), 1);
Pgrid = zeros(numel(acceptedIdx), 1);
Igrid = zeros(numel(acceptedIdx), 1);
Dgrid = zeros(numel(acceptedIdx), 1);
for k = 1:numel(acceptedIdx)
    rec = result.points(acceptedIdx(k));
    Tgrid(k) = rec.targetK;
    Pgrid(k) = rec.pidAccepted.P;
    Igrid(k) = rec.pidAccepted.I;
    Dgrid(k) = rec.pidAccepted.D;
end
[Tsrc, sortIdx] = sort(Tgrid);
Psrc = Pgrid(sortIdx);
Isrc = Igrid(sortIdx);
Dsrc = Dgrid(sortIdx);

Tprofile = Tpoints(:);
interpMethod = char(cfg.interpolationMethod);
[Pprofile, interpMethodP, PsrcOut] = interpolate_profile_axis(Tsrc, Psrc, Tprofile, cfg);
[Iprofile, interpMethodI, IsrcOut] = interpolate_profile_axis(Tsrc, Isrc, Tprofile, cfg);
[Dprofile, interpMethodD, DsrcOut] = interpolate_profile_axis(Tsrc, Dsrc, Tprofile, cfg);
interpMethod = sprintf('P:%s;I:%s;D:%s', interpMethodP, interpMethodI, interpMethodD);

result.profile = struct( ...
    'Tgrid', Tprofile, ...
    'Pgrid', Pprofile, ...
    'Igrid', Iprofile, ...
    'Dgrid', Dprofile, ...
    'pidControlMode', runCtx.mode, ...
    'controllerCoeffNames', {controller_coeff_names(runCtx.mode)}, ...
    'runPidControlMode', runCtx.mode, ...
    'identificationPidControlMode', idCtx.mode, ...
    'runControllerCoeffNames', {controller_coeff_names(runCtx.mode)}, ...
    'identificationControllerCoeffNames', {controller_coeff_names(idCtx.mode)}, ...
    'Tsource', Tsrc, ...
    'Psource', PsrcOut, ...
    'Isource', IsrcOut, ...
    'Dsource', DsrcOut, ...
    'method', interpMethod);

[okProfileCsv, profileCsvMsg] = write_profile_csv(profileLogPath, Tprofile, Pprofile, Iprofile, Dprofile);
if ~okProfileCsv
    [~, offMsg] = send_heater_off();
    message = sprintf('Failed to write profile CSV: %s. Heater OFF: %s', profileCsvMsg, offMsg);
    result.message = message;
    result.failureSummary = message;
    result.finalState.heaterActive = false;
    result.finalState.message = offMsg;
    result.ok = false;
    result.endedAt = now_stamp();
    save_result_mat(resultMatPath, result);
    vlog('Autotune failed: %s', message);
    ok = false;
    return;
end

% End state on success: hold last setpoint, heater ON with last accepted PID.
lastSetpoint = Tpoints(end);
vlog('Final hold: setpoint %.6g K with PID [%.6g %.6g %.6g]', ...
    lastSetpoint, currentPid.P, currentPid.I, currentPid.D);
[okFinalApply, msgFinalApply, outFinalApply] = apply_pid_setpoint_verified(lastSetpoint, currentPid, runCtx);
result.finalState.pid = currentPid;
result.finalState.pidControlMode = runCtx.mode;
result.finalState.setpointK = lastSetpoint;
result.finalState.heaterActive = okFinalApply;
result.finalState.message = msgFinalApply;
result.finalState.verify = outFinalApply;
if isfield(outFinalApply, 'pidAppliedController') && has_finite_pid(outFinalApply.pidAppliedController)
    result.finalState.pidController = outFinalApply.pidAppliedController;
else
    [okCtrlMap, pidCtrlMap] = canonical_to_controller_pid(currentPid, cfg, runCtx.mode);
    if okCtrlMap
        result.finalState.pidController = pidCtrlMap;
    end
end
if ~okFinalApply
    [~, offMsg] = send_heater_off();
    message = sprintf('Failed to hold final setpoint: %s. Heater OFF: %s', msgFinalApply, offMsg);
    result.message = message;
    result.failureSummary = message;
    result.finalState.heaterActive = false;
    result.finalState.message = offMsg;
    result.ok = false;
    result.endedAt = now_stamp();
    save_result_mat(resultMatPath, result);
    vlog('Final hold failed: %s', message);
    ok = false;
    return;
end

ok = true;
message = sprintf('Autotune completed with %d accepted points.', numel(acceptedIdx));
result.ok = true;
result.message = message;
result.endedAt = now_stamp();
save_result_mat(resultMatPath, result);
vlog('%s', message);

    function [okLocal, msgLocal, outLocal] = apply_pid_setpoint_verified(targetK, pid, ctrlCtx)
        [okMap, pidCtrl, msgMap] = canonical_to_controller_pid(pid, cfg, ctrlCtx.mode);
        if ~okMap
            okLocal = false;
            msgLocal = sprintf('Failed to map canonical PID to %s mode coefficients: %s', ctrlCtx.mode, msgMap);
            outLocal = empty_verify_out();
            outLocal.pidRequestedCanonical = pid;
            outLocal.pidRequestedController = new_pid(NaN, NaN, NaN);
            outLocal.pidAppliedCanonical = pid;
            outLocal.pidAppliedController = new_pid(NaN, NaN, NaN);
            return;
        end

        cfgSet = struct( ...
            'setpointK', targetK, ...
            'pidP', pidCtrl.P, ...
            'pidI', pidCtrl.I, ...
            'pidD', pidCtrl.D, ...
            'pidMode', ctrlCtx.pidModeValue);
        if ctrlCtx.hasControlAlgorithm
            cfgSet.controlAlgorithm = ctrlCtx.controlAlgorithm;
        end
        cfgVerify = struct( ...
            'heaterNr', cfg.heaterNr, ...
            'verifyTol', cfg.verifyTol, ...
            'pidMin', cfg.pidMin, ...
            'verifyRetryWithMinClamp', cfg.verifyRetryWithMinClamp, ...
            'commRetryCount', cfg.commRetryCount, ...
            'commRetryBackoffSec', cfg.commRetryBackoffSec, ...
            'verbose', cfg.verbose);
        vlog('Apply setpoint %.6g K mode=%s pid_mode=%d controller coeffs=[%.6g %.6g %.6g]', ...
            targetK, ctrlCtx.mode, ctrlCtx.pidModeValue, pidCtrl.P, pidCtrl.I, pidCtrl.D);
        [okLocal, msgLocal, outLocal] = bf_tc_set_heater4_verified(cfg.tcIp, true, cfgSet, cfgVerify);

        outLocal.pidRequestedCanonical = pid;
        outLocal.pidRequestedController = pidCtrl;
        outLocal.pidAppliedController = effective_controller_pid_from_verify(outLocal, pidCtrl);
        outLocal.pidAppliedCanonical = controller_to_canonical_pid(outLocal.pidAppliedController, cfg, ctrlCtx.mode);
    end

    function [okLocal, msgLocal] = send_heater_off()
        cfgVerify = struct( ...
            'heaterNr', cfg.heaterNr, ...
            'commRetryCount', cfg.commRetryCount, ...
            'commRetryBackoffSec', cfg.commRetryBackoffSec, ...
            'verbose', cfg.verbose);
        [okLocal, msgLocal] = bf_tc_set_heater4_verified(cfg.tcIp, false, struct(), cfgVerify);
    end

    function [okSettle, settleInfo, settleMsg] = wait_temperature_settle(targetK, timeoutSec, tolK, holdSec)
        okSettle = false;
        settleMsg = '';
        settleInfo = struct( ...
            'status', '', ...
            'hardFailure', false, ...
            'samples', repmat(struct('tNow', '', 'tSec', NaN, 'T_K', NaN), 0, 1), ...
            'overshootK', NaN, ...
            'maxAbsErrorK', NaN, ...
            'settleTimeSec', NaN, ...
            'message', '');

        tStart = tic;
        tInTol = NaN;
        tempSeries = [];
        timeSeries = [];
        while toc(tStart) <= timeoutSec
            [okRead, TK, tStr, msgRead] = read_temp_with_retry(cfg.controlChannel);
            tNow = toc(tStart);
            if ~okRead
                settleInfo.status = 'hard_fail_read';
                settleInfo.hardFailure = true;
                settleInfo.message = msgRead;
                settleMsg = msgRead;
                return;
            end

            row = struct('tNow', tStr, 'tSec', tNow, 'T_K', TK);
            settleInfo.samples(end + 1, 1) = row; %#ok<AGROW>
            tempSeries(end + 1, 1) = TK; %#ok<AGROW>
            timeSeries(end + 1, 1) = tNow; %#ok<AGROW>

            if abs(TK - targetK) <= tolK
                if isnan(tInTol)
                    tInTol = tic;
                end
                if toc(tInTol) >= holdSec
                    settleInfo.status = 'ok';
                    settleInfo.hardFailure = false;
                    settleInfo.settleTimeSec = tNow;
                    settleInfo.overshootK = max(tempSeries - targetK);
                    settleInfo.maxAbsErrorK = max(abs(tempSeries - targetK));
                    settleInfo.message = 'Settled';
                    okSettle = true;
                    settleMsg = '';
                    return;
                end
            else
                tInTol = NaN;
            end

            pause(max(0.01, cfg.pollSec));
        end

        settleInfo.status = 'timeout';
        settleInfo.hardFailure = false;
        settleInfo.overshootK = max(tempSeries - targetK);
        settleInfo.maxAbsErrorK = max(abs(tempSeries - targetK));
        settleInfo.message = sprintf('Timeout waiting settle at %.6g K.', targetK);
        settleMsg = settleInfo.message;
    end

    function [okResp, outResp, msgResp] = collect_step_response(targetK, timeoutSec)
        okResp = false;
        msgResp = '';
        outResp = struct( ...
            'status', '', ...
            'hardFailure', false, ...
            'targetK', targetK, ...
            'tSec', [], ...
            'tempK', [], ...
            'samples', repmat(struct('tNow', '', 'tSec', NaN, 'T_K', NaN), 0, 1), ...
            'message', '');

        tStart = tic;
        while toc(tStart) <= timeoutSec
            [okRead, TK, tStr, msgRead] = read_temp_with_retry(cfg.controlChannel);
            tNow = toc(tStart);
            if ~okRead
                outResp.status = 'hard_fail_read';
                outResp.hardFailure = true;
                outResp.message = msgRead;
                msgResp = msgRead;
                return;
            end

            outResp.tSec(end + 1, 1) = tNow; %#ok<AGROW>
            outResp.tempK(end + 1, 1) = TK; %#ok<AGROW>
            outResp.samples(end + 1, 1) = struct('tNow', tStr, 'tSec', tNow, 'T_K', TK); %#ok<AGROW>

            if numel(outResp.tempK) >= 12 && tNow > 20
                y = outResp.tempK;
                lastWin = y(end-5:end);
                prevWin = y(end-11:end-6);
                if abs(mean(lastWin) - mean(prevWin)) <= max(1e-6, cfg.settleTolK / 3)
                    outResp.status = 'ok';
                    outResp.hardFailure = false;
                    outResp.message = 'Reached quasi-steady window.';
                    okResp = true;
                    msgResp = '';
                    return;
                end
            end

            pause(max(0.01, cfg.pollSec));
        end

        if numel(outResp.tempK) >= 6
            outResp.status = 'ok_timeout_partial';
            outResp.hardFailure = false;
            outResp.message = 'ID timeout reached; using collected partial data.';
            okResp = true;
            msgResp = '';
            return;
        end

        outResp.status = 'timeout';
        outResp.hardFailure = false;
        outResp.message = 'Insufficient step-response data before timeout.';
        msgResp = outResp.message;
    end

    function vlog(fmt, varargin)
        if cfg.verbose
            fprintf('[autotune_pid_temperature_range] %s\n', sprintf(fmt, varargin{:}));
        end
    end

    function [okRead, TK, tStr, msgRead] = read_temp_with_retry(channelNr)
        okRead = false;
        TK = NaN;
        tStr = '';
        msgRead = 'unknown';
        for kk = 1:cfg.commRetryCount
            [ok1, t1, tdt, msg1] = bf_tc_read_latest_channel(cfg.tcIp, channelNr, cfg.lookbackMin);
            if ok1
                okRead = true;
                TK = t1;
                tStr = char(tdt);
                msgRead = '';
                return;
            end
            msgRead = msg1;
            if kk < cfg.commRetryCount
                pause(max(0, cfg.commRetryBackoffSec));
            end
        end
    end

    function pidOut = effective_controller_pid_from_verify(outVerify, fallbackPid)
        pidOut = fallbackPid;
        if isstruct(outVerify)
            if isfield(outVerify, 'usedClampRetry') && logical(outVerify.usedClampRetry) && ...
                    isfield(outVerify, 'pidReadback2') && has_finite_pid(outVerify.pidReadback2)
                pidOut = outVerify.pidReadback2;
                return;
            end
            if isfield(outVerify, 'pidReadback1') && has_finite_pid(outVerify.pidReadback1)
                pidOut = outVerify.pidReadback1;
            end
        end
    end

    function out = empty_verify_out()
        out = struct( ...
            'verifyPassed', false, ...
            'usedClampRetry', false, ...
            'pidRequested', new_pid(NaN, NaN, NaN), ...
            'pidReadback1', new_pid(NaN, NaN, NaN), ...
            'pidRetryRequested', new_pid(NaN, NaN, NaN), ...
            'pidReadback2', new_pid(NaN, NaN, NaN), ...
            'verifyMessage', '', ...
            'setMessage1', '', ...
            'setMessage2', '', ...
            'queryMessage1', '', ...
            'queryMessage2', '', ...
            'heaterRead1', struct(), ...
            'heaterRead2', struct(), ...
            'pidRequestedCanonical', new_pid(NaN, NaN, NaN), ...
            'pidRequestedController', new_pid(NaN, NaN, NaN), ...
            'pidAppliedCanonical', new_pid(NaN, NaN, NaN), ...
            'pidAppliedController', new_pid(NaN, NaN, NaN));
    end
end

function cfg = apply_defaults(cfg)
cfg = set_default(cfg, 'heaterNr', 4);
cfg = set_default(cfg, 'controlChannel', 8);
cfg = set_default(cfg, 'pollSec', 2.0);
cfg = set_default(cfg, 'lookbackMin', 5);
cfg = set_default(cfg, 'commRetryCount', 3);
cfg = set_default(cfg, 'commRetryBackoffSec', 0.5);
cfg = set_default(cfg, 'verifyTol', 1e-12);
cfg = set_default(cfg, 'pidMin', 0);
cfg = set_default(cfg, 'verifyRetryWithMinClamp', true);
cfg = set_default(cfg, 'pidControlMode', 'conventional');
cfg = set_default(cfg, 'pidModeValue', 1);
cfg = set_default(cfg, 'identificationPidControlMode', '');
cfg = set_default(cfg, 'identificationPidModeValue', []);
cfg = set_default(cfg, 'identificationControlAlgorithm', []);
cfg = set_default(cfg, 'conventionalControlAlgorithm', 1);
cfg = set_default(cfg, 'stepControlAlgorithm', 2);
cfg = set_default(cfg, 'stepCoeffScale', 100);
cfg = set_default(cfg, 'conventionalTiMin', 1e-9);
cfg = set_default(cfg, 'conventionalTiMax', 1e9);
cfg = set_default(cfg, 'settleTolK', 0.02);
cfg = set_default(cfg, 'settleHoldSec', 60);
cfg = set_default(cfg, 'settleTimeoutSec', 1800);
cfg = set_default(cfg, 'idStepDeltaK', 0.05);
cfg = set_default(cfg, 'idTimeoutSec', 900);
cfg = set_default(cfg, 'idMinResponseK', 0.01);
cfg = set_default(cfg, 'lambdaFactor', 2.0);
cfg = set_default(cfg, 'validateTimeoutSec', 1200);
cfg = set_default(cfg, 'maxOvershootK', 0.05);
cfg = set_default(cfg, 'maxAbsErrorK', 0.5);
cfg = set_default(cfg, 'interpolationMethod', 'linear');
cfg = set_default(cfg, 'profileExtrapolation', 'extrap');
cfg = set_default(cfg, 'profileMonotonicMode', 'off');
cfg = set_default(cfg, 'logRoot', pwd);
cfg = set_default(cfg, 'logPrefix', 'PID_AutoTune');
cfg = set_default(cfg, 'verbose', true);
end

function cfg = set_default(cfg, key, value)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = value;
end
end

function [ok, errMsg] = validate_inputs(TRangeK, nPoints, cfg)
ok = false;
errMsg = '';

if ~(isnumeric(TRangeK) && numel(TRangeK) == 2 && all(isfinite(TRangeK)))
    errMsg = 'TRangeK must be a numeric [Tmin Tmax] with finite values.';
    return;
end
if ~(isnumeric(nPoints) && isscalar(nPoints) && isfinite(nPoints) && mod(nPoints, 1) == 0 && nPoints >= 2)
    errMsg = 'nPoints must be an integer >= 2.';
    return;
end
if TRangeK(1) == TRangeK(2)
    errMsg = 'TRangeK endpoints must be different.';
    return;
end

required = {'tcIp','pidBounds','initialPid'};
for i = 1:numel(required)
    k = required{i};
    if ~isfield(cfg, k) || isempty(cfg.(k))
        errMsg = sprintf('Missing required cfg.%s.', k);
        return;
    end
end

b = cfg.pidBounds;
bKeys = {'Pmin','Pmax','Imin','Imax','Dmin','Dmax'};
for i = 1:numel(bKeys)
    key = bKeys{i};
    if ~isfield(b, key) || ~(isnumeric(b.(key)) && isscalar(b.(key)) && isfinite(b.(key)))
        errMsg = sprintf('Missing/invalid cfg.pidBounds.%s.', key);
        return;
    end
end
if b.Pmin > b.Pmax || b.Imin > b.Imax || b.Dmin > b.Dmax
    errMsg = 'Invalid pidBounds min/max ordering.';
    return;
end

p = cfg.initialPid;
pKeys = {'P','I','D'};
for i = 1:numel(pKeys)
    key = pKeys{i};
    if ~isfield(p, key) || ~(isnumeric(p.(key)) && isscalar(p.(key)) && isfinite(p.(key)))
        errMsg = sprintf('Missing/invalid cfg.initialPid.%s.', key);
        return;
    end
end

numKeys = {'heaterNr','controlChannel','pollSec','lookbackMin','commRetryCount','commRetryBackoffSec', ...
    'verifyTol','pidMin','settleTolK','settleHoldSec','settleTimeoutSec', ...
    'idTimeoutSec','idMinResponseK','lambdaFactor','validateTimeoutSec','maxOvershootK','maxAbsErrorK'};
for i = 1:numel(numKeys)
    key = numKeys{i};
    if ~(isnumeric(cfg.(key)) && isscalar(cfg.(key)) && isfinite(cfg.(key)))
        errMsg = sprintf('cfg.%s must be a finite numeric scalar.', key);
        return;
    end
end

if cfg.pollSec <= 0 || cfg.settleTolK <= 0 || cfg.settleHoldSec <= 0 || cfg.settleTimeoutSec <= 0 || ...
        cfg.idTimeoutSec <= 0 || cfg.validateTimeoutSec <= 0 || cfg.verifyTol <= 0 || cfg.pidMin < 0 || ...
        cfg.lambdaFactor <= 0
    errMsg = 'Timing/tolerance fields must be > 0, and cfg.pidMin must be >= 0.';
    return;
end
if cfg.commRetryCount < 1 || mod(cfg.commRetryCount, 1) ~= 0
    errMsg = 'cfg.commRetryCount must be integer >= 1.';
    return;
end
if ~(ischar(cfg.logRoot) || isstring(cfg.logRoot))
    errMsg = 'cfg.logRoot must be a path string.';
    return;
end
if ~(ischar(cfg.logPrefix) || isstring(cfg.logPrefix))
    errMsg = 'cfg.logPrefix must be a string.';
    return;
end
if ~(ischar(cfg.interpolationMethod) || isstring(cfg.interpolationMethod))
    errMsg = 'cfg.interpolationMethod must be a string.';
    return;
end
if ischar(cfg.profileExtrapolation) || isstring(cfg.profileExtrapolation)
    extrapTxt = lower(strtrim(char(string(cfg.profileExtrapolation))));
    if ~strcmp(extrapTxt, 'extrap')
        errMsg = 'cfg.profileExtrapolation string must be ''extrap''.';
        return;
    end
elseif ~(isnumeric(cfg.profileExtrapolation) && isscalar(cfg.profileExtrapolation) && isfinite(cfg.profileExtrapolation))
    errMsg = 'cfg.profileExtrapolation must be ''extrap'' or a finite numeric scalar.';
    return;
end
if ~(ischar(cfg.profileMonotonicMode) || isstring(cfg.profileMonotonicMode))
    errMsg = 'cfg.profileMonotonicMode must be ''off'', ''nondecreasing'', or ''nonincreasing''.';
    return;
end
monoMode = normalize_monotonic_mode(cfg.profileMonotonicMode);
if ~(strcmp(monoMode, 'off') || strcmp(monoMode, 'nondecreasing') || strcmp(monoMode, 'nonincreasing'))
    errMsg = 'cfg.profileMonotonicMode must be ''off'', ''nondecreasing'', or ''nonincreasing''.';
    return;
end
if ~(ischar(cfg.pidControlMode) || isstring(cfg.pidControlMode))
    errMsg = 'cfg.pidControlMode must be ''conventional'' or ''step''.';
    return;
end
mode = normalize_pid_control_mode(cfg.pidControlMode);
if ~(strcmp(mode, 'conventional') || strcmp(mode, 'step'))
    errMsg = 'cfg.pidControlMode must be ''conventional'' or ''step''.';
    return;
end
if ~(isnumeric(cfg.pidModeValue) && isscalar(cfg.pidModeValue) && isfinite(cfg.pidModeValue) && mod(cfg.pidModeValue,1)==0)
    errMsg = 'cfg.pidModeValue must be an integer scalar.';
    return;
end
if cfg.pidModeValue < 0
    errMsg = 'cfg.pidModeValue must be >= 0.';
    return;
end
if ~isempty(cfg.identificationPidControlMode)
    if ~(ischar(cfg.identificationPidControlMode) || isstring(cfg.identificationPidControlMode))
        errMsg = 'cfg.identificationPidControlMode must be empty, ''conventional'', or ''step''.';
        return;
    end
    idMode = normalize_pid_control_mode(cfg.identificationPidControlMode);
    if ~(strcmp(idMode, 'conventional') || strcmp(idMode, 'step'))
        errMsg = 'cfg.identificationPidControlMode must be empty, ''conventional'', or ''step''.';
        return;
    end
end
if ~isempty(cfg.identificationPidModeValue)
    if ~(isnumeric(cfg.identificationPidModeValue) && isscalar(cfg.identificationPidModeValue) && ...
            isfinite(cfg.identificationPidModeValue) && mod(cfg.identificationPidModeValue,1)==0 && ...
            cfg.identificationPidModeValue >= 0)
        errMsg = 'cfg.identificationPidModeValue must be empty or an integer >= 0.';
        return;
    end
end
if ~isempty(cfg.identificationControlAlgorithm) && ~is_empty_or_int_scalar(cfg.identificationControlAlgorithm)
    errMsg = 'cfg.identificationControlAlgorithm must be empty or integer scalar.';
    return;
end
if ~(isnumeric(cfg.stepCoeffScale) && isscalar(cfg.stepCoeffScale) && isfinite(cfg.stepCoeffScale) && cfg.stepCoeffScale > 0)
    errMsg = 'cfg.stepCoeffScale must be > 0.';
    return;
end
if ~(isnumeric(cfg.conventionalTiMin) && isscalar(cfg.conventionalTiMin) && isfinite(cfg.conventionalTiMin) && cfg.conventionalTiMin > 0) || ...
        ~(isnumeric(cfg.conventionalTiMax) && isscalar(cfg.conventionalTiMax) && isfinite(cfg.conventionalTiMax) && cfg.conventionalTiMax >= cfg.conventionalTiMin)
    errMsg = 'cfg.conventionalTiMin/TiMax must satisfy 0 < TiMin <= TiMax.';
    return;
end
if ~is_empty_or_int_scalar(cfg.conventionalControlAlgorithm)
    errMsg = 'cfg.conventionalControlAlgorithm must be empty or integer scalar.';
    return;
end
if ~is_empty_or_int_scalar(cfg.stepControlAlgorithm)
    errMsg = 'cfg.stepControlAlgorithm must be empty or integer scalar.';
    return;
end
if isa(cfg.idStepDeltaK, 'function_handle')
    % accepted, evaluated at runtime
elseif isnumeric(cfg.idStepDeltaK) && isscalar(cfg.idStepDeltaK) && isfinite(cfg.idStepDeltaK) && cfg.idStepDeltaK > 0
    % accepted scalar
elseif isnumeric(cfg.idStepDeltaK) && ndims(cfg.idStepDeltaK) == 2 && size(cfg.idStepDeltaK, 2) == 2 && size(cfg.idStepDeltaK, 1) >= 2
    if ~all(isfinite(cfg.idStepDeltaK(:)))
        errMsg = 'cfg.idStepDeltaK schedule must contain finite values.';
        return;
    end
    Tsch = cfg.idStepDeltaK(:, 1);
    Dsch = cfg.idStepDeltaK(:, 2);
    if any(Dsch <= 0)
        errMsg = 'cfg.idStepDeltaK schedule deltaK values must be > 0.';
        return;
    end
    if any(diff(Tsch) <= 0)
        errMsg = 'cfg.idStepDeltaK schedule temperatures must be strictly increasing.';
        return;
    end
else
    errMsg = 'cfg.idStepDeltaK must be scalar > 0, Nx2 [T,deltaK] schedule, or function handle.';
    return;
end

ok = true;
end

function [ok, runFolder, stepLogPath, profileLogPath, resultMatPath, msg] = setup_log_paths(cfg)
ok = false;
runFolder = '';
stepLogPath = '';
profileLogPath = '';
resultMatPath = '';
msg = '';

try
    stamp = datestr(now, 'yyyymmdd_HHMMSS');
    runFolder = fullfile(char(cfg.logRoot), sprintf('%s_%s', char(cfg.logPrefix), stamp));
    if ~isfolder(runFolder)
        mkdir(runFolder);
    end
    stepLogPath = fullfile(runFolder, 'autotune_step_log.csv');
    profileLogPath = fullfile(runFolder, 'autotune_profile.csv');
    resultMatPath = fullfile(runFolder, 'autotune_result.mat');
    ok = true;
catch ME
    msg = sprintf('Failed to create log folder/paths: %s', ME.message);
end
end

function [ok, msg] = init_step_log(path)
ok = false;
msg = '';
fid = fopen(path, 'w');
if fid < 0
    msg = sprintf('Unable to create step log: %s', path);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, ['timestamp,index,targetK,stage,status,message,' ...
    'idDeltaK,' ...
    'pReq,iReq,dReq,pRead1,iRead1,dRead1,pRetryReq,iRetryReq,dRetryReq,pRead2,iRead2,dRead2,' ...
    'verifyPassed,usedClampRetry,overshootK,settleTimeSec,maxAbsErrorK\n']);
ok = true;
end

function append_step_log_row(path, rec)
fid = fopen(path, 'a');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

overshootK = NaN;
settleTimeSec = NaN;
maxAbsErrorK = NaN;
if isfield(rec, 'validation') && isstruct(rec.validation)
    if isfield(rec.validation, 'overshootK'), overshootK = rec.validation.overshootK; end
    if isfield(rec.validation, 'settleTimeSec'), settleTimeSec = rec.validation.settleTimeSec; end
    if isfield(rec.validation, 'maxAbsErrorK'), maxAbsErrorK = rec.validation.maxAbsErrorK; end
elseif isfield(rec, 'settleBefore') && isstruct(rec.settleBefore)
    if isfield(rec.settleBefore, 'overshootK'), overshootK = rec.settleBefore.overshootK; end
    if isfield(rec.settleBefore, 'settleTimeSec'), settleTimeSec = rec.settleBefore.settleTimeSec; end
    if isfield(rec.settleBefore, 'maxAbsErrorK'), maxAbsErrorK = rec.settleBefore.maxAbsErrorK; end
end

fprintf(fid, '%s,%d,%.12g,%s,%s,"%s",%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%d,%d,%.12g,%.12g,%.12g\n', ...
    now_stamp(), rec.index, rec.targetK, csv_token(rec.stage), csv_token(rec.status), sanitize_csv_text(rec.message), ...
    rec.identificationDeltaK, ...
    rec.pidRequested.P, rec.pidRequested.I, rec.pidRequested.D, ...
    rec.pidReadback1.P, rec.pidReadback1.I, rec.pidReadback1.D, ...
    rec.pidRetryRequested.P, rec.pidRetryRequested.I, rec.pidRetryRequested.D, ...
    rec.pidReadback2.P, rec.pidReadback2.I, rec.pidReadback2.D, ...
    logical_to_num(rec.verifyPassed), logical_to_num(rec.usedClampRetry), ...
    overshootK, settleTimeSec, maxAbsErrorK);
end

function [ok, msg] = write_profile_csv(path, Tgrid, Pgrid, Igrid, Dgrid)
ok = false;
msg = '';
fid = fopen(path, 'w');
if fid < 0
    msg = sprintf('Unable to create profile CSV: %s', path);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid, 'T_K,Kp,Ki,Kd\n');
for i = 1:numel(Tgrid)
    fprintf(fid, '%.12g,%.12g,%.12g,%.12g\n', Tgrid(i), Pgrid(i), Igrid(i), Dgrid(i));
end
ok = true;
end

function save_result_mat(path, result)
try %#ok<TRYNC>
    save(path, 'result');
end
end

function rec = new_point_record()
rec = struct( ...
    'index', NaN, ...
    'targetK', NaN, ...
    'stage', '', ...
    'status', '', ...
    'message', '', ...
    'pidStart', new_pid(NaN, NaN, NaN), ...
    'pidRequested', new_pid(NaN, NaN, NaN), ...
    'pidReadback1', new_pid(NaN, NaN, NaN), ...
    'pidRetryRequested', new_pid(NaN, NaN, NaN), ...
    'pidReadback2', new_pid(NaN, NaN, NaN), ...
    'verifyPassed', false, ...
    'verifyMessage', '', ...
    'usedClampRetry', false, ...
    'identificationDeltaK', NaN, ...
    'identificationStepSetpointK', NaN, ...
    'identification', struct(), ...
    'model', struct(), ...
    'pidCandidateRaw', new_pid(NaN, NaN, NaN), ...
    'pidCandidateClamped', new_pid(NaN, NaN, NaN), ...
    'pidAccepted', new_pid(NaN, NaN, NaN), ...
    'pidAcceptedController', new_pid(NaN, NaN, NaN), ...
    'settleBefore', struct(), ...
    'validation', struct());
end

function pid = new_pid(P, I, D)
pid = struct('P', double(P), 'I', double(I), 'D', double(D));
end

function pidOut = clamp_pid(pidIn, b)
pidOut = new_pid( ...
    min(max(pidIn.P, b.Pmin), b.Pmax), ...
    min(max(pidIn.I, b.Imin), b.Imax), ...
    min(max(pidIn.D, b.Dmin), b.Dmax));
end

function tf = has_finite_pid(pid)
tf = isstruct(pid) && isfield(pid, 'P') && isfield(pid, 'I') && isfield(pid, 'D') && ...
    isnumeric(pid.P) && isnumeric(pid.I) && isnumeric(pid.D) && ...
    isscalar(pid.P) && isscalar(pid.I) && isscalar(pid.D) && ...
    isfinite(pid.P) && isfinite(pid.I) && isfinite(pid.D);
end

function mode = normalize_pid_control_mode(modeIn)
mode = lower(strtrim(char(string(modeIn))));
if strcmp(mode, 'conventional') || strcmp(mode, 'conv')
    mode = 'conventional';
elseif strcmp(mode, 'step') || strcmp(mode, 'temperature_step') || strcmp(mode, 'temp_step')
    mode = 'step';
end
end

function [ok, pidCtrl, msg] = canonical_to_controller_pid(pidCanon, cfg, modeOverride)
ok = false;
msg = '';
pidCtrl = new_pid(NaN, NaN, NaN);

mode = normalize_pid_control_mode(cfg.pidControlMode);
if nargin >= 3 && ~isempty(modeOverride)
    mode = normalize_pid_control_mode(modeOverride);
end
if strcmp(mode, 'step')
    s = cfg.stepCoeffScale;
    pidCtrl = new_pid(pidCanon.P * s, pidCanon.I * s, pidCanon.D * s);
    ok = has_finite_pid(pidCtrl);
    if ~ok
        msg = 'Non-finite step-mode coefficients.';
    end
    return;
end

K = pidCanon.P;
Ki = pidCanon.I;
Kd = pidCanon.D;
if ~(isfinite(K) && isfinite(Ki) && isfinite(Kd))
    msg = 'Non-finite canonical PID.';
    return;
end
if K < 0 || Ki < 0 || Kd < 0
    msg = 'Canonical PID has negative coefficient(s), unsupported for conventional mapping.';
    return;
end

if Ki > 0
    if K <= 0
        msg = 'Cannot map Ki>0 with K<=0 to conventional mode (K,Ti,Td).';
        return;
    end
    Ti = K / Ki;
else
    Ti = cfg.conventionalTiMax;
end
Ti = min(max(Ti, cfg.conventionalTiMin), cfg.conventionalTiMax);

if K > 0
    Td = Kd / K;
else
    Td = 0;
end
Td = max(Td, 0);

pidCtrl = new_pid(K, Ti, Td);
ok = true;
end

function pidCanon = controller_to_canonical_pid(pidCtrl, cfg, modeOverride)
mode = normalize_pid_control_mode(cfg.pidControlMode);
if nargin >= 3 && ~isempty(modeOverride)
    mode = normalize_pid_control_mode(modeOverride);
end
if strcmp(mode, 'step')
    s = cfg.stepCoeffScale;
    pidCanon = new_pid(pidCtrl.P / s, pidCtrl.I / s, pidCtrl.D / s);
    return;
end

K = pidCtrl.P;
Ti = pidCtrl.I;
Td = pidCtrl.D;
if ~(isfinite(K) && isfinite(Ti) && isfinite(Td))
    pidCanon = new_pid(NaN, NaN, NaN);
    return;
end
if Ti <= 0
    Ki = 0;
else
    Ki = K / Ti;
end
pidCanon = new_pid(K, max(Ki, 0), max(K * max(Td, 0), 0));
end

function [hasAlg, algVal] = selected_control_algorithm(cfg, modeOverride, algorithmOverride)
hasAlg = false;
algVal = NaN;
if nargin >= 3 && ~isempty(algorithmOverride)
    algVal = algorithmOverride;
    hasAlg = true;
    return;
end
mode = normalize_pid_control_mode(cfg.pidControlMode);
if nargin >= 2 && ~isempty(modeOverride)
    mode = normalize_pid_control_mode(modeOverride);
end
if strcmp(mode, 'step')
    if isempty(cfg.stepControlAlgorithm)
        return;
    end
    algVal = cfg.stepControlAlgorithm;
else
    if isempty(cfg.conventionalControlAlgorithm)
        return;
    end
    algVal = cfg.conventionalControlAlgorithm;
end
hasAlg = true;
end

function txt = control_algorithm_label(hasAlg, algVal)
if hasAlg
    txt = num2str(algVal);
else
    txt = 'none';
end
end

function [ok, deltaK, msg] = evaluate_id_step_deltaK(cfg, targetK)
ok = false;
deltaK = NaN;
msg = '';

v = cfg.idStepDeltaK;
if isa(v, 'function_handle')
    try
        deltaK = v(targetK);
    catch ME
        msg = sprintf('idStepDeltaK function error: %s', ME.message);
        return;
    end
elseif isnumeric(v) && isscalar(v) && isfinite(v)
    deltaK = v;
elseif isnumeric(v) && ndims(v) == 2 && size(v, 2) == 2 && size(v, 1) >= 2
    try
        deltaK = interp1(v(:,1), v(:,2), targetK, 'linear', 'extrap');
    catch ME
        msg = sprintf('idStepDeltaK schedule interpolation error: %s', ME.message);
        return;
    end
else
    msg = 'Unsupported cfg.idStepDeltaK format.';
    return;
end

if ~(isnumeric(deltaK) && isscalar(deltaK) && isfinite(deltaK) && deltaK > 0)
    msg = sprintf('idStepDeltaK evaluated to invalid value: %.12g', deltaK);
    return;
end
ok = true;
end

function [yProfile, methodUsed, ySourceOut] = interpolate_profile_axis(Tsrc, ysrc, Tprofile, cfg)
ySourceOut = ysrc(:);
monoMode = normalize_monotonic_mode(cfg.profileMonotonicMode);
if ~strcmp(monoMode, 'off')
    ySourceOut = enforce_monotonic_series(ySourceOut, monoMode);
end

methodUsed = char(cfg.interpolationMethod);
extrapOpt = cfg.profileExtrapolation;
if isstring(extrapOpt)
    extrapOpt = char(extrapOpt);
end
try
    yProfile = interp1(Tsrc, ySourceOut, Tprofile, methodUsed, extrapOpt);
catch
    methodUsed = 'linear';
    try
        yProfile = interp1(Tsrc, ySourceOut, Tprofile, methodUsed, extrapOpt);
    catch
        yProfile = interp1(Tsrc, ySourceOut, Tprofile, methodUsed, 'extrap');
        methodUsed = 'linear_fallback_extrap';
    end
end

if ~strcmp(monoMode, 'off')
    yProfile = enforce_monotonic_series(yProfile(:), monoMode);
else
    yProfile = yProfile(:);
end
end

function mode = normalize_monotonic_mode(modeIn)
mode = lower(strtrim(char(string(modeIn))));
if strcmp(mode, 'increasing')
    mode = 'nondecreasing';
elseif strcmp(mode, 'decreasing')
    mode = 'nonincreasing';
elseif strcmp(mode, 'none')
    mode = 'off';
end
end

function yOut = enforce_monotonic_series(yIn, mode)
yOut = yIn(:);
if strcmp(mode, 'nondecreasing')
    for k = 2:numel(yOut)
        if yOut(k) < yOut(k - 1)
            yOut(k) = yOut(k - 1);
        end
    end
elseif strcmp(mode, 'nonincreasing')
    for k = 2:numel(yOut)
        if yOut(k) > yOut(k - 1)
            yOut(k) = yOut(k - 1);
        end
    end
end
end

function names = controller_coeff_names(modeIn)
mode = normalize_pid_control_mode(modeIn);
if strcmp(mode, 'step')
    names = {'K1', 'K2', 'K3'};
else
    names = {'K', 'Ti', 'Td'};
end
end

function tf = is_empty_or_int_scalar(v)
tf = isempty(v) || (isnumeric(v) && isscalar(v) && isfinite(v) && mod(v,1)==0 && v >= 0);
end

function [ok, model, msg] = fit_fopdt(tSec, y, deltaU, minResponse)
ok = false;
msg = '';
model = struct('y0', NaN, 'yInf', NaN, 'dy', NaN, 'Kproc', NaN, 'L', NaN, 'tau', NaN, ...
    't2pct', NaN, 't63pct', NaN, 'deltaU', deltaU);

if numel(tSec) < 6 || numel(y) < 6
    msg = 'Insufficient points for step-response fit.';
    return;
end

n0 = min(5, numel(y));
n1 = min(5, numel(y));
y0 = mean(y(1:n0));
yInf = mean(y(end-n1+1:end));
dy = yInf - y0;
if abs(dy) < minResponse
    msg = sprintf('Step response too small (|dy|=%.6g < %.6g).', abs(dy), minResponse);
    return;
end
if ~(isfinite(deltaU) && deltaU ~= 0)
    msg = 'Invalid step deltaU.';
    return;
end
Kproc = dy / deltaU;
if ~isfinite(Kproc) || Kproc <= 0
    msg = sprintf('Invalid process gain Kproc=%.6g (must be >0).', Kproc);
    return;
end

if dy > 0
    y2 = y0 + 0.02 * dy;
    y63 = y0 + 0.632 * dy;
    idx2 = find(y >= y2, 1, 'first');
    idx63 = find(y >= y63, 1, 'first');
else
    y2 = y0 + 0.02 * dy;
    y63 = y0 + 0.632 * dy;
    idx2 = find(y <= y2, 1, 'first');
    idx63 = find(y <= y63, 1, 'first');
end
if isempty(idx2) || isempty(idx63)
    msg = 'Unable to locate 2%%/63.2%% crossing points.';
    return;
end

t2 = tSec(idx2);
t63 = tSec(idx63);
L = t2;
tau = t63 - L;
if ~(isfinite(L) && isfinite(tau) && tau > 0)
    msg = sprintf('Invalid model timing L=%.6g tau=%.6g.', L, tau);
    return;
end

model.y0 = y0;
model.yInf = yInf;
model.dy = dy;
model.Kproc = Kproc;
model.L = L;
model.tau = tau;
model.t2pct = t2;
model.t63pct = t63;
ok = true;
end

function [ok, pid, msg] = compute_pid_imc(model, lambdaFactor, pollSec)
ok = false;
msg = '';
pid = new_pid(NaN, NaN, NaN);

Kproc = model.Kproc;
L = model.L;
tau = model.tau;
if ~(isfinite(Kproc) && isfinite(L) && isfinite(tau) && Kproc > 0 && tau > 0 && L >= 0)
    msg = 'Invalid model parameters for IMC PID.';
    return;
end

lambda = max(lambdaFactor * L, 0.5 * max(1e-6, pollSec));
den = Kproc * (lambda + L);
if den <= 0
    msg = 'Invalid denominator in IMC formula.';
    return;
end

Kc = tau / den;
Ti = tau + L / 2;
Td = (tau * L) / max(1e-12, (2 * tau + L));
P = Kc;
I = Kc / max(Ti, 1e-12);
D = Kc * Td;
if ~(isfinite(P) && isfinite(I) && isfinite(D))
    msg = 'Computed PID contains non-finite values.';
    return;
end

pid = new_pid(P, I, D);
ok = true;
end

function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end

function out = sanitize_csv_text(txt)
out = char(string(txt));
out = strrep(out, '"', '""');
out = strrep(out, sprintf('\n'), ' | ');
out = strrep(out, sprintf('\r'), ' ');
end

function out = csv_token(txt)
out = char(string(txt));
out = strrep(out, ',', ';');
end

function n = logical_to_num(v)
n = 0;
if ~isempty(v) && logical(v)
    n = 1;
end
end
