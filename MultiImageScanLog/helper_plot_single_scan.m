function D = helper_plot_single_scan(savedpath)
path = savedpath;

fid = fopen(path, 'r');
if fid < 0
    error('Cannot open %s', path);
end

% --- Read header lines ---
header1 = fgetl(fid);
header2 = fgetl(fid);

% --- Parse NVx and NVy ---
% Example: "xRange in distance [um]: [-98 98] NVx:101 bFixVx:0 ..."
NVx = sscanf(header1, '%*[^N]NVx:%d');
NVy = sscanf(header2, '%*[^N]NVy:%d');

% ---- Parse X and Y range ----
xr = sscanf(header1, 'VxRange in distance [um]: [%f %f]');
yr = sscanf(header2, 'VyRange in distance [um]: [%f %f]');


% --- Skip to start of numeric data ---
% numeric block continues until the line "Notes:"
nums = [];
while true
    pos = ftell(fid);
    line = fgetl(fid);
    if ~ischar(line)
        break
    end
    if contains(line, 'Notes:')
        break
    end
    val = str2double(line);
    if ~isnan(val)
        nums(end+1) = val; %#ok<AGROW>
    end
end

fclose(fid);

% --- Reshape into NVy × NVx image ---
if numel(nums) ~= NVx * NVy
    error('Size mismatch: expected %d values, got %d', NVx*NVy, numel(nums));
end

data = reshape(nums, NVx, NVy)';
% ^ reshape then transpose → (y,x) correct orientation

% --- Build coordinate axes ---
D.x = linspace(xr(1), xr(2), NVx);
D.y = linspace(yr(1), yr(2), NVy);
D.data = data;



end 