%instrhwinfo('serial')
%to check name of serial port

function [max_force] = robot_abd(srl,option)%tot_time)
% Inputs:
%       srl - Serial Port name ('COM5') 
%       tot_time - total time for feedback (1.5s) = time to do full rotation
%
% Outputs:
%       max_force - value of analog read by force meter
tic
sendEvent('stimulus','feedback');
fwrite(srl,option);%tot_time); % send numerical value to arduino + serial port name
%max_force = fscanf(arduino,'%d'); % read data from the Arduino
[max_force] = fread(srl);
%pause(tot_time);
toc
end

