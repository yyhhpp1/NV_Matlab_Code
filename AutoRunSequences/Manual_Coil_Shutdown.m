global gMag

% zero current
gMag.x.ISet(0);
gMag.y.ISet(0);
gMag.z.ISet(0);

% turn on output
gMag.x.OutputOnOff(0)
gMag.y.OutputOnOff(0)
gMag.z.OutputOnOff(0)

%disconnect
delete(gMag.x)
delete(gMag.y)
delete(gMag.z)