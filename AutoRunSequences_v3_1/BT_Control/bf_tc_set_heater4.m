function [ok, message, respStruct] = bf_tc_set_heater4(deviceIP, active, cfg)
%BF_TC_SET_HEATER4 Update Bluefors Heater 4 state.
%   ON payload (active=true): includes pid_mode, setpoint and PID values.
%   OFF payload (active=false): sends heater_nr=4, active=false only.
%
% Optional cfg fields for active=true:
%   .pidMode          integer (default 1)
%   .controlAlgorithm integer (optional, omitted when absent)

ok = false;
message = '';
respStruct = struct();

if nargin < 3 || isempty(cfg)
    cfg = struct();
end

if ~(islogical(active) || isnumeric(active))
    message = 'active must be logical/numeric scalar.';
    return;
end
active = logical(active);

url = sprintf('http://%s:5001/heater/update', deviceIP);

if active
    required = {'setpointK','pidP','pidI','pidD'};
    for i = 1:numel(required)
        if ~isfield(cfg, required{i}) || isempty(cfg.(required{i})) ...
                || ~(isnumeric(cfg.(required{i})) && isscalar(cfg.(required{i})) && isfinite(cfg.(required{i})))
            message = sprintf('Missing/invalid cfg.%s for active=true.', required{i});
            return;
        end
    end

    pidModeVal = 1;
    if isfield(cfg, 'pidMode') && ~isempty(cfg.pidMode)
        if ~(isnumeric(cfg.pidMode) && isscalar(cfg.pidMode) && isfinite(cfg.pidMode) && mod(cfg.pidMode,1)==0)
            message = 'cfg.pidMode must be an integer scalar.';
            return;
        end
        pidModeVal = double(cfg.pidMode);
    end

    payload = struct( ...
        'heater_nr', 4, ...
        'active', true, ...
        'pid_mode', pidModeVal, ...
        'setpoint', cfg.setpointK, ...
        'control_algorithm_settings', struct( ...
            'proportional', cfg.pidP, ...
            'integral', cfg.pidI, ...
            'derivative', cfg.pidD));

    if isfield(cfg, 'controlAlgorithm') && ~isempty(cfg.controlAlgorithm)
        if ~(isnumeric(cfg.controlAlgorithm) && isscalar(cfg.controlAlgorithm) && ...
                isfinite(cfg.controlAlgorithm) && mod(cfg.controlAlgorithm,1)==0)
            message = 'cfg.controlAlgorithm must be an integer scalar.';
            return;
        end
        payload.control_algorithm = double(cfg.controlAlgorithm);
    end
else
    payload = struct('heater_nr', 4, 'active', false);
end

try
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*

    resp = RequestMessage('post', ...
        HeaderField('Accept','application/json'), ...
        JSONProvider(payload)).send(URI(url));

    if resp.StatusCode ~= StatusCode.OK
        bodyTxt = '<unavailable>';
        try
            body = resp.Body.Data;
            if ischar(body) || isstring(body)
                bodyTxt = char(body);
            else
                bodyTxt = jsonencode(body);
            end
        catch
        end
        message = sprintf('HTTP %d %s. Body: %s', ...
            double(resp.StatusCode), string(resp.StatusLine.ReasonPhrase), bodyTxt);
        return;
    end

    respStruct = resp.Body.Data;
    if ~isfield(respStruct, 'status') || ~strcmpi(string(respStruct.status), 'OK')
        msg = 'Unknown API error';
        if isfield(respStruct, 'error') && isfield(respStruct.error, 'message')
            msg = char(string(respStruct.error.message));
        end
        message = sprintf('Bluefors rejected heater update: %s', msg);
        return;
    end

    ok = true;
    message = 'OK';
catch ME
    message = sprintf('bf_tc_set_heater4 failed: %s', ME.message);
end
end
