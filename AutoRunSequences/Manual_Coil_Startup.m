global gMag

% connect
gMag.x= Keithley2200(PortMap('keithleyX'));
gMag.y= Keithley2200(PortMap('keithleyY'));
gMag.z= Keithley2200(PortMap('keithleyZ'));

% set voltage
gMag.x.VSet(30)
gMag.y.VSet(30)
gMag.z.VSet(30)

% zero current
gMag.x.ISet(0);
gMag.y.ISet(0);
gMag.z.ISet(0);

% turn on output
gMag.x.OutputOnOff(1)
gMag.y.OutputOnOff(1)
gMag.z.OutputOnOff(1)