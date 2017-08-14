
%instrhwinfo('serial')
%to check name of serial port

%if mac use instrfind to see in matlab serial port status
%or write in terminal  ls /dev/tty.* and it will give back comport names

function abductor_robot(angle,srl)%,comport)

fwrite(srl,angle); % send angle numerical value to arduino
pause(1);
fwrite(srl,180); % send angle numerical value to arduino
pause(0.5);

end
