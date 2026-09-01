function InitEODrive

    if ~libisloaded('EO0x2DDrive')
        disp('Matlab: Load EO-Drive.dll')
        warning('off')
        loadlibrary('EO-Drive.dll', 'eo-drive.h'); 
        loadlibrary('EO-Drive');
        warning('on')
    end
end