function robot_rest(srl)
% servo move 180 degrees to "resting" position (no abduction) 

fwrite(srl,180); % send angle numerical value to arduino
pause(1);
end

