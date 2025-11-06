function AutoAlign_Bfield_ver2(hObject, eventdata, handles)
%======================================================================
% AutoAlign_Bfield_ver2
% Smart coordinate-wise NV B-field alignment
% - Builds on ver1 (all safety + ESR logic preserved)
% - Removes B_perp/B_par scaling of step
% - Quantizes current changes to 0.005 A
%======================================================================
global gmSEQ gMag
gamma_e = 2.8e-3;       % GHz/G
D = 2.87;               % GHz (ZFS)

%------------------- USER PARAMETERS ----------------------------------
tolerance = 1e-3;           % convergence threshold
max_iter  = 10;             % total outer iterations
scanRange = 0.02;           % ±range [GHz]
f_minus_center = 1.86;      % initial ESR center [GHz]
I_init    = [1.4353, 0.0000, 2.7584]; % initial currents [A]

% smart directional search
axes_list = [1, 2];         % optimize x then y
step_init = 0.05;           % A
step_resolution = 0.005;    % A
smooth_alpha = 0.4;         % EMA for metric
noise_floor = 1e-4;         % stop if change smaller than this

% ESR parameters
Npts=101; NAve=5; Misc=5; fixPow=-45;
edge_thresh=0.010; max_rescan=2; contrast_thresh=0.005; coarse_factor=3;

% current limits
I_min = [0,0,0]; I_max = [5,5,5];

% save location
SAVE_ROOT = "C:\Users\MoleculeExp\Desktop\autoruns\auto_align\";
timestamp = datestr(now,'yyyymmdd_HHMMSS');
savePath  = fullfile(SAVE_ROOT, "Run_" + timestamp);
if ~isfolder(savePath), mkdir(savePath); end
logFile = fullfile(savePath, "alignment_log.csv");
fid = fopen(logFile,'w');
fprintf(fid,'Iter,Ix[A],Iy[A],Iz[A],Bpar[G],Bperp[G],theta[deg],Metric,Status\n');

%======================================================================
% INIT
%======================================================================
I = I_init;
setCurrents(I);
gmSEQ.bAutoRun = true;
fprintf('Starting AutoAlign_Bfield_ver2 at I = [%.4f, %.4f, %.4f]\n', I);

m_prev = Inf;

%======================================================================
% MAIN ITERATION LOOP
%======================================================================
for iter = 1:max_iter
    fprintf('\n=== Iteration %d ===\n', iter);
    if ~gmSEQ.bAutoRun, logStop('STOP_USER'); break; end

    % optimize sequentially along defined axes
    for ax = axes_list
        if ~gmSEQ.bAutoRun, break; end
        I = optimizeAxis(ax, I);
        if any(I < I_min) || any(I > I_max)
            warning('Current limit reached, stopping.');
            logStop('STOP_LIMIT'); gmSEQ.bAutoRun=false; break;
        end
    end
    if ~gmSEQ.bAutoRun, break; end

    % evaluate final misalignment after both axes
    [~,~,Bpar,Bperp,theta] = measureMisalign(I);
    metric = Bperp/Bpar;
    metric_smooth = smooth_alpha*metric + (1-smooth_alpha)*m_prev;

    fprintf(fid,'%d,%.6f,%.6f,%.6f,%.4f,%.4f,%.3f,%.5e,OK\n',...
        iter,I(1),I(2),I(3),Bpar,Bperp,theta,metric_smooth);

    fprintf('Iter %d summary: θ=%.3f°, B⊥/B∥=%.3e (smoothed)\n',iter,theta,metric_smooth);

    if metric_smooth < tolerance || abs(metric_smooth - m_prev) < noise_floor
        fprintf('Converged (metric %.3e)\n', metric_smooth);
        break;
    end
    m_prev = metric_smooth;
end

fclose(fid);
fprintf('\nFinal I = [%.4f, %.4f, %.4f]\n', I);
disp('Smart auto-alignment completed.');

%======================================================================
% === Helper functions ===
%======================================================================
    function Inew = optimizeAxis(ax, I)
        % scan three points along one current axis and fit quadratic
        step = step_init;
        Ipoints = [-step, 0, step];
        metrics = zeros(1,3);
        for k = 1:3
            dI = zeros(1,3); dI(ax) = Ipoints(k);
            Itest = I + dI;
            if any(Itest < I_min) || any(Itest > I_max)
                metrics(k) = Inf; continue;
            end
            setCurrents(Itest);
            [~,~,Bpar,Bperp,~] = measureMisalign(Itest);
            metrics(k) = Bperp/Bpar;
            fprintf('  I(%d)=%.4f → metric=%.3e\n', ax, Itest(ax), metrics(k));
        end

        coeffs = polyfit(Ipoints, metrics, 2);
        if coeffs(1) > 0
            dI_opt = -coeffs(2)/(2*coeffs(1));
            dI_opt = max(min(dI_opt, step), -step);
            dI_opt = round(dI_opt/step_resolution)*step_resolution; % quantize
            fprintf('  Quadratic min @ ΔI=%.4f A (quantized)\n', dI_opt);
        else
            [~,idx] = min(metrics);
            dI_opt = Ipoints(idx);
            dI_opt = round(dI_opt/step_resolution)*step_resolution;
            fprintf('  Non-convex fit → use ΔI=%.4f A (quantized)\n', dI_opt);
        end

        Inew = I;
        Inew(ax) = I(ax) + dI_opt;
        setCurrents(Inew);
    end

    function [omega_minus,omega_plus,Bpar,Bperp,theta] = measureMisalign(I)
        setCurrents(I);
        f_minus_center = 1.86;
        f_plus_center = 2*D - f_minus_center;
        omega_minus = smartESR(f_minus_center);
        if isnan(omega_minus), omega_plus=NaN; Bpar=NaN; Bperp=NaN; theta=NaN; return; end
        omega_plus  = smartESR(f_plus_center);

        Bpar = sqrt(-(D+omega_plus-2*omega_minus)*(D+omega_minus-2*omega_plus)*(D+omega_minus+omega_plus)) ...
            /(3*gamma_e*sqrt(3*D));
        Bperp = sqrt(-(2*D-omega_plus-omega_minus)*(2*D+2*omega_minus-omega_plus)*(2*D-omega_minus+2*omega_plus)) ...
            /(3*gamma_e*sqrt(3*D));
        Bpar = real(Bpar); Bperp = real(Bperp);
        theta = real(atan2(Bperp,Bpar))*180/pi;
    end

%======================================================================
% ESR logic (inherited from ver1)
%======================================================================
    function [f_low,f_high] = enforceFreqBounds(f_low,f_high)
        % Shift window down if it crosses 3.0375 GHz
        f_forbid = 3.0375;
        if f_low < f_forbid && f_high > f_forbid
            shift = f_high - f_forbid;
            f_low  = f_low  - shift;
            f_high = f_high - shift;
            fprintf('⚙️  Scan window crosses %.4f GHz → shifted down by %.4f GHz.\n',...
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
            if isnan(omega_fit), warning('Fit failed in smartESR.'); return; end

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
        set(handles.sequence,'String',"ESR");pause(0.05);
        set(handles.sequence,'Value',1);pause(0.05);
        set(handles.FROM1,'String',f1);pause(0.05);
        set(handles.TO1,'String',f2);pause(0.05);
        set(handles.SweepNPoints,'String',Npts);pause(0.05);
        set(handles.Average,'String',NAve);pause(0.05);
        set(handles.misc,'String',Misc);pause(0.05);
        set(handles.fixPow,'String',fixPow);pause(0.05);
        drawnow limitrate nocallbacks;
        if ~gmSEQ.bAutoRun, freq=[]; PL=[]; return; end
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);
        if ~gmSEQ.bAutoRun, freq=[]; PL=[]; return; end
        freq = double(gmSEQ.SweepParam)*gmSEQ.ScaleT; % GHz
        PL   = double(gmSEQ.signal(1,:));
    end

    function f_fit = fitLorentz(x,y,fc)
        try
            lorentz=@(p,x) p(1)-p(2)./(1+((x-p(3))/p(4)).^2);
            p0=[mean(y),max(y)-min(y),fc,5e-3];
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
        fprintf(fid,'%d,%.6f,%.6f,%.6f,NaN,NaN,NaN,NaN,%s\n',iter,I,tag);
        fseek(fid,0,'cof');
    end
end
