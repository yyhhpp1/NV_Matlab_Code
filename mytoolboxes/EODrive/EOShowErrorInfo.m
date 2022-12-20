function EOShowErrorInfo(val)
    if val==0
        disp('EO_SUCCESS');
    elseif val==-1
        disp('EO_GENERAL_ERROR');
    elseif val==-2
        disp('EO_DEV_ERROR');
    elseif val==-3
        disp('EO_DEV_NOT_ATTACHED');
    elseif val==-6
        disp('EO_ARGUMENT_ERROR');
    elseif val==-8
        disp('EO_INVALID_HANDLE');
    end
end