function [ok, temperatureK, timestampPosix, message, respData] = bf_tc_read_channel_history(deviceIP, channelNr, lookbackMin, readCfg)
%BF_TC_READ_CHANNEL_HISTORY Read temperature history from Bluefors TC channel.
%   [ok, temperatureK, timestampPosix, message, respData] = ...
%       bf_tc_read_channel_history(deviceIP, channelNr, lookbackMin, readCfg)
%
% Inputs
%   deviceIP   : Bluefors TC IP (without protocol/port)
%   channelNr  : channel number (e.g., 3, 8)
%   lookbackMin: history window in minutes
%   readCfg    : optional struct
%       .connectTimeoutSec  (default 20)
%       .responseTimeoutSec (default 30)
%
% Outputs
%   ok            : logical success flag
%   temperatureK  : Nx1 temperature vector in K
%   timestampPosix: Nx1 UTC POSIX timestamp vector (seconds)
%   message       : status/error message
%   respData      : raw decoded response body

ok = false;
temperatureK = [];
timestampPosix = [];
message = '';
respData = struct();

if nargin < 3 || isempty(lookbackMin)
    lookbackMin = 60;
end
if nargin < 4 || isempty(readCfg) || ~isstruct(readCfg)
    readCfg = struct();
end
if ~isfield(readCfg, 'connectTimeoutSec') || isempty(readCfg.connectTimeoutSec)
    readCfg.connectTimeoutSec = 20;
end
if ~isfield(readCfg, 'responseTimeoutSec') || isempty(readCfg.responseTimeoutSec)
    readCfg.responseTimeoutSec = 30;
end

if ~(isnumeric(channelNr) && isscalar(channelNr) && isfinite(channelNr))
    message = 'channelNr must be a finite scalar.';
    return;
end
if ~(isnumeric(lookbackMin) && isscalar(lookbackMin) && isfinite(lookbackMin) && lookbackMin > 0)
    message = 'lookbackMin must be a positive finite scalar.';
    return;
end

try
    t2 = datetime('now', 'TimeZone', 'UTC');
    t1 = t2 - minutes(lookbackMin);

    payload = struct( ...
        'channel_nr', round(channelNr), ...
        'start_time', char(datetime(t1, 'Format', "yyyy-MM-dd'T'HH:mm:ss'Z'")), ...
        'stop_time',  char(datetime(t2, 'Format', "yyyy-MM-dd'T'HH:mm:ss'Z'")), ...
        'fields',     {{'temperature', 'timestamp'}} );

    url = sprintf('http://%s:5001/channel/historical-data', deviceIP);
    d = [];

    try
        wopt = weboptions( ...
            'MediaType', 'application/json', ...
            'Timeout', readCfg.responseTimeoutSec, ...
            'HeaderFields', {'Accept', 'application/json'});
        d = webwrite(url, payload, wopt);
    catch MEweb
        import matlab.net.*
        import matlab.net.http.*
        import matlab.net.http.io.*

        req = RequestMessage('post', ...
            HeaderField('Accept', 'application/json'), ...
            JSONProvider(payload));

        opts = [];
        try
            opts = HTTPOptions('ConnectTimeout', readCfg.connectTimeoutSec, ...
                'ResponseTimeout', readCfg.responseTimeoutSec);
        catch
            try
                opts = HTTPOptions('ConnectTimeout', readCfg.connectTimeoutSec);
            catch
                opts = [];
            end
        end

        if isempty(opts)
            resp = req.send(URI(url));
        else
            resp = req.send(URI(url), opts);
        end

        if resp.StatusCode ~= StatusCode.OK
            message = sprintf('HTTP error %d %s', double(resp.StatusCode), string(resp.StatusLine.ReasonPhrase));
            return;
        end
        d = resp.Body.Data;
        respData = d;
        if isempty(d)
            rethrow(MEweb);
        end
    end

    if isempty(d)
        message = 'Empty response payload from Bluefors endpoint.';
        return;
    end
    if ischar(d) || isstring(d)
        try
            d = jsondecode(char(d));
        catch
            message = 'Bluefors response is text but not valid JSON.';
            return;
        end
    end
    respData = d;

    if ~isfield(d, 'status') || ~strcmpi(string(d.status), 'OK')
        message = 'API returned non-OK status.';
        return;
    end
    if ~isfield(d, 'measurements') || ~isfield(d.measurements, 'temperature') || ~isfield(d.measurements, 'timestamp')
        message = 'API response missing measurements.temperature/timestamp.';
        return;
    end

    temperatureK = double(d.measurements.temperature(:));
    timestampPosix = double(d.measurements.timestamp(:));
    if isempty(temperatureK) || isempty(timestampPosix)
        message = 'No samples in requested window.';
        return;
    end
    if numel(temperatureK) ~= numel(timestampPosix)
        message = sprintf('Mismatched vector lengths: T=%d, ts=%d.', numel(temperatureK), numel(timestampPosix));
        return;
    end

    finiteMask = isfinite(temperatureK) & isfinite(timestampPosix);
    temperatureK = temperatureK(finiteMask);
    timestampPosix = timestampPosix(finiteMask);
    if isempty(temperatureK)
        message = 'No finite samples in requested window.';
        return;
    end

    [timestampPosix, idx] = sort(timestampPosix, 'ascend');
    temperatureK = temperatureK(idx);

    ok = true;
    message = 'OK';
catch ME
    message = sprintf('bf_tc_read_channel_history failed (connectTimeout=%.6gs responseTimeout=%.6gs): %s', ...
        readCfg.connectTimeoutSec, readCfg.responseTimeoutSec, ME.message);
end
end
