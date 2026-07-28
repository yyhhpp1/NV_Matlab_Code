function hc_PBClockCheck()
% hc_PBClockCheck  Report which PulseBlaster code is actually on the MATLAB path
% and what clock frequency it declares.
%
% There is no SpinAPI call that reports a board's PHYSICAL oscillator frequency.
% pb_core_clock / pb_set_clock only TELL the library what to assume, and every
% ns-to-tick conversion follows from that number. So a wrong declaration is
% silent: all pulse durations scale by (declared / physical) and nothing errors.
%
% This repo ships TWO copies of PBFunctionPool.m that declare DIFFERENT clocks,
% so the durations you get depend on MATLAB path order. This function reports
% which copy wins and what it declares. Pure reads: it does not program or start
% the board, and it does not modify any PulseBlaster code.
%
% Cross-check the reported firmware ID against SpinCore's documentation for your
% board model to get the rated clock, then confirm with a scope on a known pulse.

    fprintf('=== PulseBlaster clock / path report ===\n\n');

    % --- Which copies exist, and which one MATLAB will call ---------------- %
    reportShadowed('PBFunctionPool');
    reportShadowed('PBesrSetClock');
    reportShadowed('PBesrInit');

    % --- What the winning PBFunctionPool declares -------------------------- %
    hits = which('PBFunctionPool', '-all');
    if ~isempty(hits)
        fprintf('--- Clock declarations in the ACTIVE PBFunctionPool ---\n');
        fprintf('    %s\n', hits{1});
        reportDeclaredClock(hits{1});
        if numel(hits) > 1
            fprintf('--- ... and in the SHADOWED copy (NOT used, for contrast) ---\n');
            fprintf('    %s\n', hits{2});
            reportDeclaredClock(hits{2});
        end
    end

    % --- What the board says about itself ---------------------------------- %
    fprintf('--- Board identity (SpinAPI) ---\n');
    try
        LoadPBESR();
        try
            v = calllib('mypbesr', 'pb_get_version');
            fprintf('    pb_get_version    : %s\n', char(string(v)));
        catch ME
            fprintf('    pb_get_version    : unavailable (%s)\n', ME.message);
        end
        try
            PBesrInit();
            fid = calllib('mypbesr', 'pb_get_firmware_id');
            fprintf('    pb_get_firmware_id: %d (0x%X)\n', fid, fid);
            fprintf(['    Look this ID up in SpinCore''s docs for your board model;\n', ...
                     '    the model determines the rated clock (e.g. 250/400/500 MHz).\n']);
            PBesrClose();
        catch ME
            fprintf('    pb_get_firmware_id: unavailable (%s)\n', ME.message);
            try; PBesrClose(); catch; end
        end
    catch ME
        fprintf('    SpinAPI not loadable: %s\n', ME.message);
    end

    fprintf(['\nNote: no API reports the physical clock. If the declared value is\n', ...
             'wrong by a factor r, every duration is wrong by r -- a 100 us quarter\n', ...
             'bin silently becomes 100/r us. Confirm with a scope on a known pulse.\n']);
end

% ---------------------------------------------------------------------------- %
function reportShadowed(fname)
% List every copy of fname on the path. The FIRST is the one MATLAB calls.
    hits = which(fname, '-all');
    if isempty(hits)
        fprintf('%-16s NOT FOUND on the path.\n\n', [fname ':']);
        return
    end
    fprintf('%-16s %d copy(ies) on the path:\n', [fname ':'], numel(hits));
    for i = 1:numel(hits)
        if i == 1
            fprintf('   [ACTIVE]   %s\n', hits{i});
        else
            fprintf('   [shadowed] %s\n', hits{i});
        end
    end
    if numel(hits) > 1
        fprintf(2, ['   WARNING: shadowed copies exist. Which one runs depends on\n', ...
                    '   path order, so verify the ACTIVE one is the intended code.\n']);
    end
    fprintf('\n');
end

% ---------------------------------------------------------------------------- %
function reportDeclaredClock(filePath)
% Print the clock-related literals in filePath. Static text scan, no execution.
    txt = '';
    try
        txt = fileread(filePath);
    catch
        fprintf('        (could not read file)\n\n');
        return
    end

    ct = regexp(txt, 'ClockTime\s*=\s*1\s*/\s*([0-9.]+e?[0-9]*)', 'tokens');
    if isempty(ct)
        fprintf('        ClockTime      : none found\n');
    else
        for i = 1:numel(ct)
            hz = str2double(ct{i}{1});
            fprintf('        ClockTime      : 1/%s  -> %.6g MHz assumed\n', ...
                    ct{i}{1}, hz/1e6);
        end
    end

    % Only uncommented PBesrSetClock calls matter.
    lines = regexp(txt, '\r?\n', 'split');
    found = false;
    for i = 1:numel(lines)
        ln = regexprep(lines{i}, '%.*$', '');
        tok = regexp(ln, 'PBesrSetClock\s*\(\s*([0-9.]+)\s*\)', 'tokens', 'once');
        if ~isempty(tok)
            fprintf('        PBesrSetClock  : %s MHz  (line %d, active)\n', tok{1}, i);
            found = true;
        end
    end
    if ~found
        fprintf('        PBesrSetClock  : no active call found\n');
    end

    md = regexp(txt, 'MinDelay\s*=\s*ClockTime\s*\*\s*\(?\s*2\^([0-9]+)', 'tokens', 'once');
    if ~isempty(md)
        fprintf('        MinDelay       : ClockTime * 2^%s\n', md{1});
    end
    fprintf('\n');
end
