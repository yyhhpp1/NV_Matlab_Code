d = daq("ni");
addoutput(d,"Dev3","ao0","Voltage");
addoutput(d,"Dev3","ao1","Voltage");
signal1 = 1*sin((1:10000)*2*pi/1000)-0.08; 
signal2 = 1*cos((1:10000)*2*pi/1000)+0.85;
signalAll = [signal1', signal2'];
preload(d,signalAll)
start(d,"RepeatOutput")
pause(1)
stop(d);clear d