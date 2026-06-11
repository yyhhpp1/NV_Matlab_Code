thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, 'BT_Control'));

cfg = struct();
cfg.tcIp = '192.168.0.145';

cfg.heaterNr = 4;
cfg.controlChannel = 8;

% Run + identification both in conventional mode
cfg.pidControlMode = 'conventional';
cfg.identificationPidControlMode = 'conventional';
cfg.pidModeValue = 1;
cfg.identificationPidModeValue = 1;
cfg.conventionalControlAlgorithm = 1;

% Your 5 K starting point in conventional form:
% Kp=0.02, Ti=60, Td=0
% Convert to canonical (Kp, Ki, Kd) expected by autotune:
% Ki = Kp/Ti, Kd = Kp*Td
cfg.initialPid = struct('P', 0.002, 'I', 0.002/60, 'D', 0);

% Bounds in canonical form.
% Force Td=0 by forcing D=0 always.
cfg.pidBounds = struct( ...
    'Pmin', 0, 'Pmax', 0.2, ...
    'Imin', 0, 'Imax', 0.002, ...
    'Dmin', 0, 'Dmax', 0);

cfg.pollSec = 2.0;
cfg.settleTolK = 0.05;
cfg.settleHoldSec = 120;
cfg.settleTimeoutSec = 3600;
cfg.idTimeoutSec = 1800;
cfg.idMinResponseK = 0.01;
cfg.lambdaFactor = 2.5;
cfg.validateTimeoutSec = 3600;
cfg.maxOvershootK = 0.15;
cfg.maxAbsErrorK = 1.0;

cfg.idStepDeltaK = [ ...
    5   0.03; ...
    10  0.05; ...
    20  0.08; ...
    40  0.12; ...
    80  0.20];

cfg.interpolationMethod = 'linear';
cfg.profileMonotonicMode = 'off';
cfg.profileExtrapolation = 'extrap';

cfg.logRoot = 'D:\t1_auto_saves_v3_1';
cfg.logPrefix = 'PID_AutoTune_5K_80K_CONV_Td0';
cfg.verbose = true;

nPoints = 12;
[ok, msg, result] = autotune_pid_temperature_range([5 80], nPoints, cfg);

disp(ok);
disp(msg);
if isstruct(result) && isfield(result, 'runFolder')
    disp(result.runFolder);
end
