function large_scan_with_attocube(hObject, eventdata, handles)
global gPiezo

amc = gPiezo.amc;
x = 0;
y = 1;

control_setControlAmplitude(amc, x,  60000); 
control_setControlAmplitude(amc, y,  60000); 
control_setControlOutput(amc, x, true);
control_setControlOutput(amc, y, true);

Nsteps = 50;
Nx = 3;
Ny = 3;

for i = 1:Nx
    move_setNSteps(amc, 0, true, Nsteps);
    for j = 1:Ny
        %move
        move_setNSteps(amc, 1, true, Nsteps);
        
        %find z
        
        %scan
        
    end
end
        
end

