
%instrhwinfo('serial') %to check name of serial port

function arduinotest(angle,dur_wait)

%rotate servomotor to a certain position, wait X seconds, return to
%original position (0)

%input - angle: final position (degrees)
%      - wait: time to wait in that position (seconds) 

%output - prints position in command window
 tic
a = arduino('COM5','Uno','libraries','Servo'); %Create an arduino object and include the Servo library.

s = servo(a,'D8','MinPulseDuration',700*10^-6,'MaxPulseDuration',2300*10^-6); %Create a servo object using pin 8 
                                                                                   %that moves from 0 to 180 degrees.

num_angle = angle/180; %numeric value between 0 and 1 for writePosition

sendEvent('stimulus','feedback'); %send event see if has the correct type and value
writePosition(s, num_angle); %move to final position

current_pos = readPosition(s);
current_pos = current_pos*180;
fprintf('Current motor position is %0.2f degrees\n', current_pos);

pause(dur_wait); %wait 1 seconds

writePosition(s, 0); %return to 0 degrees

current_pos = readPosition(s);
fprintf('Current motor position is %d degrees\n', current_pos);

clear s a; %Once the connection is no longer needed, clear the associate objects.
toc
end