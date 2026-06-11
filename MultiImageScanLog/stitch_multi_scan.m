logFile = 'closedloop_scan_log_20260409_164328.csv';

map_x = [-100, -10];
map_y = [-10, 100];

stitch_multiscan(logFile, map_x, map_y)

function stitch_multiscan(logFile, map_x, map_y)

    % ====== User-set brightness bounds ======
    brightness_min = 0;       % <<--- set your values here
    brightness_max = 20000000;    % <<--- set your values here
    % =========================================

    % ====== Load log ======
    T = readtable(logFile, 'Delimiter', ',');

    ix = T.ix;
    iy = T.iy;
    files = T.file;

    N = height(T);

    % ====== Load first tile to get axes ======
    D0 = helper_plot_single_scan(files{1});

    tileX = D0.x;
    tileY = D0.y;
    img0  = D0.data;

    [NY, NX] = size(img0);

    [locX, locY] = meshgrid(tileX, tileY);

    figure; hold on;
    set(gcf,'Color','k');   % window background black
    set(gca,'Color','k');   % axes background black

    colormap pink;

    % ====== Place tiles by (ix, iy) with mapping ======
    for k = 1:N
        D = helper_plot_single_scan(files{k});
        img = D.data;

        % ---- Clamp brightness to min/max ----
        img = max(min(img, brightness_max), brightness_min);
        % -------------------------------------

        iix = ix(k);
        iiy = iy(k);

        baseX = iix * map_x(1) + iiy * map_y(1);
        baseY = iix * map_x(2) + iiy * map_y(2);

        surf(baseX + locX, baseY + locY, zeros(size(img)), img, ...
             'EdgeColor','none');
    end

    axis equal tight;
    xlabel('Stitched X', 'Color', 'w');
    ylabel('Stitched Y', 'Color', 'w');
    title('Stitched Multi-Scan Mosaic (Index-mapped)', 'Color', 'w');

    set(gca,'XColor','w','YColor','w');  % white ticks

    % ====== Add brightness legend (colorbar) ======
    cb = colorbar;
    cb.Label.String = 'Brightness';
    cb.Color = 'w';
    cb.Label.Color = 'w';

    % Set colorbar to your chosen brightness scale
    caxis([brightness_min brightness_max]);

    hold off;

end



% function stitch_multiscan(logFile, map_x, map_y)
% % map_x = [dx_x, dx_y] : plot shift when motor X increments
% % map_y = [dy_x, dy_y] : plot shift when motor Y increments
% %
% % Uses read_scan_txt(savedPath) to load each tile
% 
%     % ====== Load log ======
%     T = readtable(logFile, 'Delimiter', ',');
%     ix = T.ix;
%     iy = T.iy;
%     files = T.file;
% 
%     N = height(T);
% 
%     % ====== Load first tile to get size and axes ======
%     D0 = helper_plot_single_scan(files{1});
% 
%     tileX = D0.x;     % local x coordinates (vector)
%     tileY = D0.y;     % local y coordinates (vector)
%     img0  = D0.data;
% 
%     [NY, NX] = size(img0);   % tile size (rows × cols)
% 
%     % local coordinate grid for plotting each tile
%     [locX, locY] = meshgrid(tileX, tileY);
% 
%     figure; hold on;
%     colormap pink;
% 
%     % ====== Iterate in true physical order (as logged) ======
%     for k = 1:N
% 
%         % Load tile
%         D = helper_plot_single_scan(files{k});
%         img = D.data;
% 
%         iix = ix(k);
%         iiy = iy(k);
% 
%         % Global tile placement via mapping:
%         %     X = iix * map_x(1)  +  iiy * map_y(1)
%         %     Y = iix * map_x(2)  +  iiy * map_y(2)
%         baseX = iix * map_x(1) + iiy * map_y(1);
%         baseY = iix * map_x(2) + iiy * map_y(2);
% 
%         % Plot the tile in correct physical coordinates
%         surf( baseX + locX, baseY + locY, zeros(size(img)), img, ...
%               'EdgeColor','none');
% 
%     end
% 
%     axis equal tight;
%     xlabel('Physical X');
%     ylabel('Physical Y');
%     title('Stitched Multi-Scan Mosaic');
% 
%     hold off;
% end
