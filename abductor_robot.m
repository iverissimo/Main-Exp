
%instrhwinfo('serial')
%to check name of serial port

function abductor_robot(angle,srl)%,comport)
tic

sendEvent('stimulus','feedback');
fwrite(srl,angle); % send angle numerical value to arduino
pause(0.5);
fwrite(srl,0); % send angle numerical value to arduino
pause(1);

toc
end
