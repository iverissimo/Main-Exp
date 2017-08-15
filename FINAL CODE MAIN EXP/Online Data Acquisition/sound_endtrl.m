

function sound_endtrl
%function to give audio cue for trial END

Fs = 8000; %sampling rate [Hz]
dur_beep = 0.1; %duration of the beep [s]
beep_time = 0:(1/Fs):dur_beep; %time vector

freq = 200;

low_beep = sin(2*pi*freq*beep_time); %sin wave at 60Hz

sound(low_beep,Fs)

end