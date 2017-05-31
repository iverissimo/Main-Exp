
function [srl] = initSrlPort(comport)

delete(instrfindall);
srl = serial(comport); % creates a serial port object 
set(srl,'DataBits',8); %guaranty that serial port has the same 
set(srl,'StopBits',1); %properties as defined in arduino
set(srl,'BaudRate',115200);%9600);
set(srl,'Parity','none');

fopen(srl); % connects the serial port object to the device
pause(2)%SUPER IMPORTANT, need to give time for arduino to connect

end
