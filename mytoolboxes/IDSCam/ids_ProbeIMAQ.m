function ok = ids_ProbeIMAQ()
% ids_ProbeIMAQ  Can the Image Acquisition Toolbox replace the Python backend?
%
%   ok = ids_ProbeIMAQ
%
% Answers one question with evidence instead of argument: does IAT's GenTL
% adaptor surface the GenICam nodes this integration actually depends on?
%
% WHY THE QUESTION IS NOT OBVIOUS
%
% IAT flattens the remote device's node map into properties on the source object
% at connection time, and offers no raw node-map escape hatch -- if a node is not
% surfaced as a property, it cannot be reached at all. The nodes at risk are the
% SELECTOR-BASED ones, because reaching them means setting a selector first and
% then reading a different node whose meaning just changed:
%
%   LineSelector    -> LineMode, LineSource      (Line2 as an input; A2 sync out)
%   TimerSelector   -> TimerTriggerSource, ...   (A2 sync out)
%   CounterSelector -> CounterEventSource, ...   (C1 missed-trigger telemetry)
%
% Those are not decoration. C1 is what separates "too close to the rate ceiling"
% from "the camera never saw Line2" from "PB did not run" -- three faults that
% otherwise present identically as a fetch timeout. Losing it to gain a tidier
% transport would be a bad trade.
%
% WHAT A PASS AND A FAIL MEAN
%
%   all REQUIRED found  -> IAT is viable. Writing IDSCamIMAQ as a drop-in
%                          replacement for IDSCamInterface is then worth doing:
%                          it drops the Python dependency, removes the HDF5
%                          round-trip, and would let Stop interrupt a burst.
%   any REQUIRED missing -> IAT cannot drive this design on its own. Stay on the
%                          harvesters/GenTL backend.
%
% Read-only: creates a videoinput, reads properties, deletes it. Does not
% configure, arm or acquire. Safe to run at any time -- but it does open the
% camera, so run IDSCamRelease first if MATLAB already holds it through Python.

ok = false;

% --- Is the toolbox even here? ---------------------------------------------
if isempty(ver('imaq'))
    fprintf(2, ['[IMAQ] Image Acquisition Toolbox is NOT installed.\n', ...
                '       Install it plus the "GenICam Interface" support package\n', ...
                '       (Add-Ons -> Get Hardware Support Packages), then rerun.\n', ...
                '       Both are needed: the toolbox alone has no gentl adaptor.\n']);
    return
end
fprintf('[IMAQ] Image Acquisition Toolbox %s present.\n', ver('imaq').Version);

% --- Make sure the adaptor can actually find the IDS producer ---------------
% GENICAM_GENTL64_PATH is how the adaptor finds producers, and it is
% semicolon-separated -- several vendors coexist happily. On this rig it
% typically contains ONLY the Diaphus producer (the HeliCam's), because that is
% what C4Utility set. The IDS installer's entry is not always inherited by a
% MATLAB session, so add it here for THIS SESSION ONLY: a setenv does not touch
% the machine's environment, so it cannot disturb the HeliCam or survive a
% restart to surprise anyone later.
ctiDir = fileparts(IDSConfig().ctiPath);
envVar = getenv('GENICAM_GENTL64_PATH');
if isempty(envVar)
    fprintf('[IMAQ] GENICAM_GENTL64_PATH = <empty>\n');
else
    fprintf('[IMAQ] GENICAM_GENTL64_PATH = %s\n', envVar);
end

if ~contains(lower(envVar), lower(ctiDir))
    if isempty(envVar)
        newVar = ctiDir;
    else
        newVar = [envVar ';' ctiDir];
    end
    setenv('GENICAM_GENTL64_PATH', newVar);
    fprintf(['[IMAQ] IDS producer was NOT on the path -- added for this session:\n', ...
             '         %s\n'], ctiDir);
    % The adaptor caches its producer list on first use, so it has to be told.
    imaqreset;
end

try
    hw = imaqhwinfo('gentl');
catch ME
    fprintf(2, '[IMAQ] imaqhwinfo(''gentl'') failed: %s\n', ME.message);
    fprintf(2, '       The GenICam Interface support package is probably missing.\n');
    return
end

if isempty(hw.DeviceIDs)
    fprintf(2, '[IMAQ] The gentl adaptor enumerated 0 devices.\n');
    reportGenICamClash();
    fprintf(2, ['       Other things to rule out: the USB3 cable, and whether ', ...
                'another\n       process holds the camera (IDS peak Cockpit, or ', ...
                'this MATLAB via\n       Python -- run IDSCamRelease).\n']);
    return
end

fprintf('\n[IMAQ] %d device(s) visible to the gentl adaptor:\n', numel(hw.DeviceIDs));
for k = 1:numel(hw.DeviceInfo)
    fprintf('   %d: %s\n', hw.DeviceInfo(k).DeviceID, hw.DeviceInfo(k).DeviceName);
end

% --- Pick the IDS, by name ---------------------------------------------------
% NOT DeviceIDs{1}. The HeliCam is on this same adaptor over GigE, and it
% enumerates first. Probing it instead would report Width/Height/ExposureTime as
% "missing" -- perfectly true of a lock-in camera, and completely irrelevant to
% the question being asked. An earlier run of this function did exactly that and
% produced a confident, wrong verdict.
iIDS = [];
for k = 1:numel(hw.DeviceInfo)
    nm = lower(hw.DeviceInfo(k).DeviceName);
    if contains(nm, 'ids') || contains(nm, 'u3-31') || contains(nm, 'ueye')
        iIDS = k;
        break
    end
end

if isempty(iIDS)
    fprintf(2, ['\n[IMAQ] The IDS camera is NOT among them, so there is nothing to\n', ...
                '       probe. It IS attached and healthy -- the harvesters backend\n', ...
                '       enumerates it fine -- so this is a producer-path problem, not\n', ...
                '       a camera problem.\n', ...
                '       Verify the producer exists at:\n         %s\n'], ...
            IDSConfig().ctiPath);
    return
end

fprintf('\n[IMAQ] Probing device %d: %s\n', hw.DeviceInfo(iIDS).DeviceID, ...
        hw.DeviceInfo(iIDS).DeviceName);

vid = [];
cleanupVid = onCleanup(@() safeDelete(vid));
try
    vid = videoinput('gentl', hw.DeviceInfo(iIDS).DeviceID);
    src = getselectedsource(vid);
catch ME
    fprintf(2, '[IMAQ] Could not open the device: %s\n', ME.message);
    return
end

props = fieldnames(set(src));
fprintf('\n[IMAQ] Source object exposes %d properties.\n\n', numel(props));

% --- The nodes this design needs -------------------------------------------
required = {
    'Width',              'ROI';
    'Height',             'ROI';
    'OffsetX',            'ROI';
    'PixelFormat',        'ROI';
    'ExposureTime',       'exposure';
    'TriggerMode',        'trigger in (B1)';
    'TriggerSource',      'trigger in (B1)';
    'TriggerSelector',    'trigger in (B1)';
    'TriggerActivation',  'trigger in (B1)';
    'LineSelector',       'Line2 as INPUT -- selector-based';
    'LineMode',           'Line2 as INPUT -- selector-based';
    'CounterSelector',    'C1 telemetry -- selector-based';
    'CounterEventSource', 'C1 telemetry -- selector-based';
    'CounterValue',       'C1 telemetry -- selector-based';
    };

optional = {
    'TriggerDivider',     'only needed if scheme B5 ever comes back';
    'TimerSelector',      'A2 sync out -- selector-based';
    'TimerTriggerSource', 'A2 sync out -- selector-based';
    'TimerDelay',         'A2 sync out';
    'TimerDuration',      'A2 sync out';
    'LineSource',         'A2 sync out -- selector-based';
    'GainSelector',       'keep gain at 1.0';
    'Gain',               'keep gain at 1.0';
    };

nMissReq = report('REQUIRED', required, props);
nMissOpt = report('OPTIONAL', optional, props);

% --- Verdict ----------------------------------------------------------------
fprintf('\n================ verdict ================\n');
if nMissReq == 0
    ok = true;
    fprintf(['IAT IS VIABLE -- every required node is reachable.\n\n', ...
             'Worth doing: write IDSCamIMAQ as a drop-in for IDSCamInterface\n', ...
             '(same four-method protocol, the way FakeIDSCamera already is).\n', ...
             'It drops the Python dependency and its 3.9-3.11 constraint, removes\n', ...
             'the HDF5 round-trip, and lets Stop interrupt a burst by polling\n', ...
             'vid.FramesAvailable -- which the current readIQ cannot do.\n']);
    if nMissOpt > 0
        fprintf(2, ['\nBut %d optional node(s) are missing. Check the list above: if\n', ...
                    'the A2 sync-out nodes are among them you lose the scope\n', ...
                    'reference for the exposure-window calibration, which is worth\n', ...
                    'keeping the Python path around for even if the main run moves.\n'], ...
                nMissOpt);
    end
else
    fprintf(2, ['IAT CANNOT drive this design on its own -- %d required node(s)\n', ...
                'are not surfaced, and the adaptor has no raw node-map escape\n', ...
                'hatch to reach them. Stay on the harvesters/GenTL backend.\n'], ...
            nMissReq);
end
fprintf('=========================================\n');
end

% --------------------------------------------------------------------------- %
function nMissing = report(label, list, props)
fprintf('--- %s ---\n', label);
nMissing = 0;
for k = 1:size(list,1)
    name = list{k,1};
    % Case-insensitive: the adaptor is free to rename as it flattens.
    hit = props(strcmpi(props, name));
    if isempty(hit)
        % A near-miss is worth showing -- a renamed node is still reachable.
        near = props(contains(lower(props), lower(name)));
        if isempty(near)
            fprintf(2, '  %-20s MISSING   (%s)\n', name, list{k,2});
        else
            fprintf(2, '  %-20s MISSING   (%s) -- near: %s\n', ...
                    name, list{k,2}, strjoin(near', ', '));
        end
        nMissing = nMissing + 1;
    else
        fprintf('  %-20s ok        (%s)\n', name, list{k,2});
    end
end
end

function reportGenICamClash()
% Compare the GenICam runtime MATLAB's adaptor bundles against the one the IDS
% producer is built for, and say so if they differ.
%
% This is the failure this whole probe most needs to name, because it presents as
% "0 devices" with NO error -- indistinguishable from an unplugged camera. The
% GenTL producer is a DLL that the consumer loads in-process; if the consumer
% brings its own, older GenApi, the producer's node map cannot bind and the
% producer contributes nothing, quietly.
%
% Verified on this rig 2026-09-06: MATLAB R2023b's GenICam Interface support
% package bundles GenICam v3.1 (VC120/VS2013); the IDS peak U3V producer wants
% v3.5 (VC141/VS2017). Two major revisions and a different C++ runtime. It is
% not fixable from MATLAB -- the runtime is bundled and version-pinned inside the
% support package, with no supported way to point it elsewhere.

spRoot = fullfile(matlabshared.supportpkg.getSupportPackageRoot(), ...
                  'toolbox', 'imaq', 'supportpackages', 'gentl');
mlVer = findGenApi(spRoot);
% ...\ids_peak\ids_u3vgentl\64\x.cti -> three fileparts gets back to ids_peak.
idsRoot = fileparts(fileparts(fileparts(IDSConfig().ctiPath)));
idsVer  = findGenApi(fullfile(idsRoot, 'generic_sdk', 'api', 'lib', 'x86_64'));

if isempty(mlVer) || isempty(idsVer)
    return
end

fprintf(2, '\n       GenICam runtime versions:\n');
fprintf(2, '         MATLAB gentl adaptor : %s\n', mlVer);
fprintf(2, '         IDS peak producer    : %s\n', idsVer);

if ~strcmp(mlVer, idsVer)
    fprintf(2, ['\n       *** THIS IS ALMOST CERTAINLY THE CAUSE. ***\n', ...
                '       The adaptor loads its OWN GenApi, and the IDS producer is built\n', ...
                '       against a different one, so the producer fails to bind and\n', ...
                '       contributes zero devices -- with no error, which is why this\n', ...
                '       looks like an unplugged camera.\n\n', ...
                '       Not fixable from MATLAB: the runtime is bundled and pinned\n', ...
                '       inside the support package. STAY ON THE HARVESTERS BACKEND,\n', ...
                '       whose genicam wheel ships a matching runtime -- which is why\n', ...
                '       ids_acquire.py enumerates this camera without trouble.\n']);
end
end

function v = findGenApi(root)
% Version string of the GenApi DLL under a tree, e.g. 'v3_1 (VC120)'.
v = '';
try
    d = dir(fullfile(root, '**', 'GenApi_MD_VC*.dll'));
catch
    return
end
if isempty(d); return; end
tok = regexp(d(1).name, 'GenApi_MD_(VC\d+)_(v[\d_]+)\.dll', 'tokens', 'once');
if numel(tok) == 2
    v = sprintf('%s (%s)', tok{2}, tok{1});
else
    v = d(1).name;
end
end

function safeDelete(vid)
if ~isempty(vid)
    try; delete(vid); catch; end
end
end
