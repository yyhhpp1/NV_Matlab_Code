% Define server IP and port
serverIP = PortMap('magnet_611_z');
serverPort = PortMap('magnet_611_port');

% Create a TCP client
t = tcpclient(serverIP, serverPort);
t.Timeout = 3;

% Read data from the server
data = writeread(t,"SYST:ERR?\n");
disp(char(data));

write(t,"CONFigure:FIELD:UNITS 0\n");
data = writeread(t,"FIELD:UNITS?\n");
disp(char(data));

write(t,"CONFigure:FIELD:TARGet 1052\n");
data = writeread(t,"FIELD:TARGet?\n");
disp(char(data));

% Clean up
clear t;