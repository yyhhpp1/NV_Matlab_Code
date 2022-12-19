function InitEODrive

    if ~libisloaded('EO0x2DDrive')
        disp('Matlab: Load EO-Drive.dll')
        warning('off')
        loadlibrary('EO-Drive');
        warning('on')
    end
end