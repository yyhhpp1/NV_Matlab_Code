function [ok, heater, message, resp] = bf_tc_read_heater(deviceIP, heaterNr)
%BF_TC_READ_HEATER Read Bluefors heater settings/state by heater number.
%   [ok, heater, message, resp] = bf_tc_read_heater(deviceIP, heaterNr)
%
% Endpoint:
%   POST http://<deviceIP>:5001/heater
% Payload:
%   struct('heater_nr', heaterNr)
%
% The response format can vary; this helper returns:
%   - resp: full decoded response body
%   - heater: best-effort extracted heater struct with fields such as:
%       heater_nr, active, pid_mode, setpoint, control_algorithm_settings, ...

ok = false;
heater = struct();
message = '';
resp = struct();

if ~(isnumeric(heaterNr) && isscalar(heaterNr) && isfinite(heaterNr) && mod(heaterNr, 1) == 0)
    message = 'heaterNr must be an integer scalar.';
    return;
end
if heaterNr < 1 || heaterNr > 4
    message = 'heaterNr must be in range 1..4.';
    return;
end

url = sprintf('http://%s:5001/heater', deviceIP);
payload = struct('heater_nr', double(heaterNr));

try
    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*

    req = RequestMessage('post', ...
        HeaderField('Accept', 'application/json'), ...
        JSONProvider(payload));
    httpResp = req.send(URI(url));

    if httpResp.StatusCode ~= StatusCode.OK
        message = sprintf('HTTP error %d %s', ...
            double(httpResp.StatusCode), string(httpResp.StatusLine.ReasonPhrase));
        return;
    end

    body = httpResp.Body.Data;
    resp = body;

    if isstruct(body) && isfield(body, 'status') && ~strcmpi(string(body.status), 'OK')
        errTxt = 'API returned non-OK status.';
        if isfield(body, 'error') && isstruct(body.error) && isfield(body.error, 'message')
            errTxt = char(string(body.error.message));
        end
        message = errTxt;
        return;
    end

    [heaterExtract, okExtract, msgExtract] = extract_heater_struct(body, heaterNr);
    if ~okExtract
        message = msgExtract;
        return;
    end

    heater = heaterExtract;
    ok = true;
    message = 'OK';
catch ME
    message = sprintf('bf_tc_read_heater failed: %s', ME.message);
end
end

function [heater, ok, message] = extract_heater_struct(body, heaterNr)
heater = struct();
ok = false;
message = 'Unable to extract heater object from response.';

if ~isstruct(body)
    return;
end

% Case 1: top-level already looks like heater object.
if has_heater_like_fields(body)
    heater = body;
    ok = true;
    message = '';
    return;
end

% Case 2: nested under common keys.
candidateKeys = {'heater', 'data', 'result', 'settings', 'payload'};
for i = 1:numel(candidateKeys)
    key = candidateKeys{i};
    if ~isfield(body, key)
        continue;
    end
    v = body.(key);
    if isstruct(v) && has_heater_like_fields(v)
        heater = v;
        ok = true;
        message = '';
        return;
    end
end

% Case 3: array of heaters under common keys.
arrayKeys = {'heaters', 'data', 'result', 'payload'};
for i = 1:numel(arrayKeys)
    key = arrayKeys{i};
    if ~isfield(body, key)
        continue;
    end
    v = body.(key);
    if ~isstruct(v)
        continue;
    end
    if isscalar(v) && has_heater_like_fields(v)
        heater = v;
        ok = true;
        message = '';
        return;
    end
    if numel(v) > 1
        for j = 1:numel(v)
            hj = v(j);
            if ~isstruct(hj) || ~has_heater_like_fields(hj)
                continue;
            end
            if isfield(hj, 'heater_nr') && isequaln(double(hj.heater_nr), double(heaterNr))
                heater = hj;
                ok = true;
                message = '';
                return;
            end
        end
    end
end
end

function tf = has_heater_like_fields(s)
if ~isstruct(s)
    tf = false;
    return;
end
tf = isfield(s, 'heater_nr') || isfield(s, 'active') || ...
    isfield(s, 'pid_mode') || isfield(s, 'setpoint') || ...
    isfield(s, 'control_algorithm_settings');
end
