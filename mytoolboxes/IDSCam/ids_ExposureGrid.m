function [expoNs, nQuanta, info] = ids_ExposureGrid(wantNs, widthPx, mode)
% ids_ExposureGrid  Snap an exposure to the IDS uEye+ hardware grid (ns).
%
%   [expoNs, nQuanta, info] = ids_ExposureGrid(wantNs, widthPx)
%   [...] = ids_ExposureGrid(wantNs, widthPx, 'floor'|'round'|'ceil')
%
%   wantNs   desired exposure, ns
%   widthPx  ROI WIDTH in pixels -- the minimum exposure depends on width, not
%            height (findings sec.2.2)
%   mode     'floor' (default), 'round' or 'ceil'
%
%   expoNs   the exposure the camera will actually hold, ns
%   nQuanta  expoNs expressed in grid quanta (what gets written, conceptually)
%   info     .quantumNs .minNs .maxNs .clampedLow .clampedHigh .snapNs
%
% THE GRID
%
% ExposureTime increments in 5.5556 us = exactly 400 ticks of the camera's
% 72 MHz sensor clock (DeviceClockFrequency is [ReadOnly] and pinned to
% [72e6, 72e6]). Anything you write is snapped to that grid by the camera, so
% snapping here first means the value MATLAB reports and the value the sensor
% holds cannot disagree -- the same reason hc_MinExposureNs exists on the
% HeliCam side.
%
% 'floor' is the default because every caller in this integration is fitting an
% exposure INSIDE a block whose length is fixed by PB. Rounding up there would
% quietly push the exposure past the block boundary and start dropping triggers.
%
% THE MINIMUM DEPENDS ON ROI WIDTH
%
% Measured (findings sec.2.2): 39 us at W=256, 42 at W=512, 43 at W=640,
% 50-51 at W=1280 -- about 36 us + 11.2 ns * W. The fit is used rather than a
% single literal because a narrow ROI genuinely can expose shorter, and pinning
% the floor at the 1280-wide value would forbid legal settings.
%
% The fit is CONSERVATIVE once snapped up to the grid, which is the direction to
% err in: predicted 38.9 us vs 39 measured at W=256, 44.4 vs 42 at W=512, 44.4 vs
% 43 at W=640, 55.6 vs 50-51 at W=1280. It forbids a few legal short exposures at
% wide ROIs; it never permits an illegal one.
%
% The camera is still the authority: this is a prediction, and configure() reads
% ExposureTime.Minimum() back from the node map and warns on a disagreement.

    if nargin < 3 || isempty(mode); mode = 'floor'; end
    if nargin < 2 || isempty(widthPx); widthPx = 1280; end

    info = struct();
    info.quantumNs = 400 / 72e6 * 1e9;          % 5555.5556 ns, exactly 400 ticks

    % Predicted floor from the ROI-width fit, itself snapped UP to the grid: a
    % floor that is not on the grid is not a settable value.
    minRawNs   = 36000 + 11.2 * widthPx;
    info.minNs = ceil(minRawNs / info.quantumNs) * info.quantumNs;
    info.maxNs = 2000005000;                    % 2,000,005 us, the node's maximum

    if ~isfinite(wantNs); wantNs = 0; end

    switch lower(mode)
        case 'floor'; snap = @floor;
        case 'ceil';  snap = @ceil;
        case 'round'; snap = @round;
        otherwise
            error('ids_ExposureGrid:BadMode', ...
                  'mode must be ''floor'', ''round'' or ''ceil'', got ''%s''.', mode);
    end

    nQuanta = snap(wantNs / info.quantumNs);
    expoNs  = nQuanta * info.quantumNs;

    info.snapNs      = expoNs - wantNs;         % negative under 'floor'
    info.clampedLow  = false;
    info.clampedHigh = false;

    if expoNs < info.minNs
        expoNs          = info.minNs;
        nQuanta         = round(expoNs / info.quantumNs);
        info.clampedLow = true;
    end
    if expoNs > info.maxNs
        expoNs           = floor(info.maxNs / info.quantumNs) * info.quantumNs;
        nQuanta          = round(expoNs / info.quantumNs);
        info.clampedHigh = true;
    end
end
