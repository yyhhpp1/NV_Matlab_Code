function [ok, T_K, tOut, message, respData] = bf_tc_read_latest_channel(deviceIP, channelNr, lookbackMin)
%BF_TC_READ_LATEST_CHANNEL Read newest temperature point from Bluefors TC.
%   Uses POST /channel/historical-data and returns the latest sample.

ok = false;
T_K = NaN;
tOut = '';
message = '';
respData = struct();

if nargin < 3 || isempty(lookbackMin)
    lookbackMin = 5;
end

if ~(isnumeric(channelNr) && isscalar(channelNr) && isfinite(channelNr))
    message = 'channelNr must be a finite scalar.';
    return;
end

try
    t2 = datetime('now','TimeZone','UTC');
    t1 = t2 - minutes(lookbackMin);

    payload = struct( ...
        'channel_nr', channelNr, ...
        'start_time', char(datetime(t1,'Format',"yyyy-MM-dd'T'HH:mm:ss'Z'")), ...
        'stop_time',  char(datetime(t2,'Format',"yyyy-MM-dd'T'HH:mm:ss'Z'")), ...
        'fields',     {{'temperature','timestamp'}} );

    url = sprintf('http://%s:5001/channel/historical-data', deviceIP);

    import matlab.net.*
    import matlab.net.http.*
    import matlab.net.http.io.*

    resp = RequestMessage('post', ...
        HeaderField('Accept','application/json'), ...
        JSONProvider(payload)).send(URI(url));

    if resp.StatusCode ~= StatusCode.OK
        message = sprintf('HTTP error %d %s', double(resp.StatusCode), string(resp.StatusLine.ReasonPhrase));
        return;
    end

    d = resp.Body.Data;
    respData = d;

    if ~isfield(d, 'status') || ~strcmpi(string(d.status), 'OK')
        message = 'API returned non-OK status.';
        return;
    end
    if ~isfield(d, 'measurements') || ~isfield(d.measurements, 'temperature') || ~isfield(d.measurements, 'timestamp')
        message = 'API response missing measurements.temperature/timestamp.';
        return;
    end

    T = double(d.measurements.temperature(:));
    ts = double(d.measurements.timestamp(:));
    if isempty(T) || isempty(ts)
        message = 'No samples in requested window.';
        return;
    end

    T_K = T(end);
    tOut = char(datetime(ts(end), 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC', ...
        'Format', "yyyy-MM-dd'T'HH:mm:ss'Z'"));
    ok = true;
    message = 'OK';
catch ME
    message = sprintf('bf_tc_read_latest_channel failed: %s', ME.message);
end
end

