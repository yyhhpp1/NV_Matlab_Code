function AutoAlign_Bfield_v10(hObject, eventdata, handles)
%======================================================================
% AutoAlign_Bfield_ver1
% Stable version for automatic NV B-field alignment.
%
% - Performs two ESR scans (left/right peaks) per iteration.
% - Fits each with Lorentzian using lsqcurvefit.
% - Computes B_parallel, B_perp, and misalignment angle.
% - Adjusts magnet currents iteratively until alignment.
% - If ESR scan crosses 3.0375 GHz, window is shifted downward.
%======================================================================
global gmSEQ gMag
gamma_e = 2.8e-3;       % GHz/G
D = 2.871;               % GHz (zero-field splitting)

%------------------- User Parameters ----------------------------------
tolerance = 0;           % convergence threshold
max_iter  = 10;             % max iterations
scanRange = 0.02;           % ±range [GHz]
f_minus_center = 2.04;      % initial ESR center [GHz]
step_gain = 0.05;          % current adjustment scale
step_dir  = [0, 1, 0];      % direction of current adjustment
I_init    = [2.3721, 0.8207, 4.5125]/2;  % starting currents [A]

% ESR acquisition settings
Npts   = 101;
NAve   = 6;
Misc   = 10;
fixPow = -45;

% Contrast thresholds and scan behavior
edge_thresh     = 0.010;   % GHz from boundary before rescan
max_rescan      = 2;
contrast_thresh = 0.005;   % 0.5%
coarse_factor   = 3;

%======================================================================
% Data save initialization
%======================================================================
SAVE_ROOT = "C:\Users\MoleculeExp\Desktop\autoruns\auto_align\";
timestamp = datestr(now,'yyyymmdd_HHMMSS');
savePath  = fullfile(SAVE_ROOT, "Run_" + timestamp);
if ~isfolder(savePath), mkdir(savePath); end
logFile = fullfile(savePath, "alignment_log.csv");
fid = fopen(logFile,'w');
fprintf(fid,'Iter,Ix[A],Iy[A],Iz[A],omega_minus[GHz],omega_plus[GHz],Bpar[G],Bperp[G],theta[deg],Status\n');

%======================================================================
% Initialization
%======================================================================
I = I_init;
setCurrents(I);
gmSEQ.bAutoRun = true;
fprintf('AutoAlign_Bfield_ver1 start: I = [%.4f, %.4f, %.4f] A\n', I);

%======================================================================
% Main feedback loop
%======================================================================
for iter = 1:max_iter
    fprintf('\n=== Iteration %d ===\n', iter);
    if ~gmSEQ.bAutoRun, logStop('STOP_USER'); break; end

    % Left and right ESR centers
    f_plus_center = 2*D - f_minus_center;
    omega_minus = smartESR(f_minus_center);
    if ~gmSEQ.bAutoRun, logStop('STOP_USER'); break; end
    if isnan(omega_minus), break; end

    omega_plus  = smartESR(f_plus_center);
    if ~gmSEQ.bAutoRun, logStop('STOP_USER'); break; end
    if isnan(omega_plus), break; end

    if isnan(omega_minus) || isnan(omega_plus)
        warning('ESR failed — stopping alignment.');
        logStop('ERROR_ESR'); break;
    end
    fprintf('  ω- = %.6f GHz, ω+ = %.6f GHz\n', omega_minus, omega_plus);

    %------------------------------------------------------------
    % Compute field alignment
    %------------------------------------------------------------
    Bpar = sqrt(-(D+omega_plus-2*omega_minus)*(D+omega_minus-2*omega_plus)*(D+omega_minus+omega_plus)) ...
           /(3*gamma_e*sqrt(3*D));
    Bperp = sqrt(-(2*D-omega_plus-omega_minus)*(2*D+2*omega_minus-omega_plus)*(2*D-omega_minus+2*omega_plus)) ...
            /(3*gamma_e*sqrt(3*D));
    Bpar = real(Bpar); Bperp = real(Bperp);
    theta = real(atan2(Bperp,Bpar))*180/pi;
    if isnan(theta), theta = 999; end

    fprintf('  B_parallel = %.3f G, B_perp = %.3f G, θ = %.3f°\n', Bpar,Bperp,theta);
    fprintf(fid,'%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,OK\n',...
        iter,I(1),I(2),I(3),omega_minus,omega_plus,Bpar,Bperp,theta);
    fseek(fid,0,'cof');

    % Convergence check
    if abs(Bperp/Bpar) < tolerance
        disp('Alignment converged!'); break;
    end

    %------------------------------------------------------------
    % Current update
    %------------------------------------------------------------
    fprintf('  I_old = [%.6f, %.6f, %.6f] A\n', I);
    dI = step_gain*step_dir;
    I = I + dI;
    setCurrents(I);
    fprintf('  ΔI    = [%.6f, %.6f, %.6f] A\n', dI);
    f_minus_center = omega_minus;
end

fclose(fid);
fprintf('\nFinal I = [%.4f, %.4f, %.4f] A\n', I);
disp('Auto-alignment completed.');

%======================================================================
% Helper functions
%======================================================================

    function [f_low,f_high] = enforceFreqBounds(f_low,f_high)
        % Shift ESR scan if it crosses 3.0375 GHz
        f_forbid = 3.0375;  % GHz forbidden zone
        if f_low < f_forbid && f_high > f_forbid
            shift = f_high - f_forbid;
            f_low  = f_low  - shift;
            f_high = f_high - shift;
            fprintf('⚙️  Scan window crosses %.4f GHz → shifted down by %.4f GHz.\n', ...
                    f_forbid, shift);
        end
    end

    function omega = smartESR(center)
        omega = NaN;
        f_low = center - scanRange;
        f_high = center + scanRange;
        [f_low,f_high] = enforceFreqBounds(f_low,f_high);

        for attempt = 1:max_rescan
            if ~gmSEQ.bAutoRun, disp('User stop during smartESR.'); return; end
            [freq,PL] = runESR(handles,f_low,f_high);
            if isempty(freq), return; end

            contrast = (max(PL)-min(PL))/max(PL);
            if contrast < contrast_thresh
                fprintf('  Low contrast (%.3f%%) → coarse scan...\n',100*contrast);
                coarse_low  = center - coarse_factor*scanRange;
                coarse_high = center + coarse_factor*scanRange;
                [coarse_low,coarse_high] = enforceFreqBounds(coarse_low,coarse_high);
                [freqC,PLC] = runESR(handles,coarse_low,coarse_high);
                if isempty(freqC), return; end
                fc = fitLorentz(freqC,PLC,(coarse_low+coarse_high)/2);
                if isnan(fc), warning('Coarse fit failed.'); return; end
                fprintf('  Coarse ESR peak at %.4f GHz → narrow re-scan.\n', fc);

                f_low = fc - scanRange;
                f_high = fc + scanRange;
                [f_low,f_high] = enforceFreqBounds(f_low,f_high);
                [freq,PL] = runESR(handles,f_low,f_high);
                if isempty(freq), return; end
            end

            omega_fit = fitLorentz(freq,PL,(f_low+f_high)/2);
            if isnan(omega_fit)
                warning('Fit failed in smartESR.'); return;
            end

            if (omega_fit - f_low < edge_thresh) || (f_high - omega_fit < edge_thresh)
                fprintf('  Peak near edge (%.3f GHz). Re-scan #%d\n', omega_fit, attempt);
                center = omega_fit;
                f_low = center - scanRange;
                f_high = center + scanRange;
                [f_low,f_high] = enforceFreqBounds(f_low,f_high);
                continue;
            else
                omega = omega_fit;
                break;
            end
        end
    end

    function [freq,PL] = runESR(handles,f1,f2)
        if ~gmSEQ.bAutoRun, freq=[]; PL=[]; return; end
        gmSEQ.name="ESR";
        set(handles.sequence,'String',"ESR");
        set(handles.sequence,'Value',1);
        set(handles.FROM1,'String',f1);
        set(handles.TO1,'String',f2);
        set(handles.SweepNPoints,'String',Npts);
        set(handles.Average,'String',NAve);
        set(handles.misc,'String',Misc);
        set(handles.fixPow,'String',fixPow);
        drawnow limitrate nocallbacks;
        if ~gmSEQ.bAutoRun, freq=[]; PL=[]; return; end
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);
        if ~gmSEQ.bAutoRun, freq=[]; PL=[]; return; end
        freq = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;  % GHz
        PL   = double(gmSEQ.signal(1,:));
    end

    function f_fit = fitLorentz(x,y,fc)
        try
            lorentz=@(p,x) p(1)-p(2)./(1+((x-p(3))/p(4)).^2);
            [val, idx] = min(y);
            p0=[mean(y),max(y)-min(y),x(idx),3e-3];
            opts=optimoptions('lsqcurvefit','Display','off');
            popt=lsqcurvefit(lorentz,p0,x,y,[],[],opts);
            f_fit=popt(3);
        catch
            warning('Lorentz fit failed → NaN');
            f_fit=NaN;
        end
    end

    function setCurrents(I)
        gMag.x.ISet(I(1)); pause(0.3);
        gMag.y.ISet(I(2)); pause(0.3);
        gMag.z.ISet(I(3)); pause(0.3);
    end

    function logStop(tag)
        fprintf(fid,'%d,%.6f,%.6f,%.6f,NaN,NaN,NaN,NaN,NaN,%s\n',iter,I,tag);
        fseek(fid,0,'cof');
    end
end
