
function soundTest(dur_iti)
%function to give audio cue for trial start
%INPUT - iti duration [s]

Fs = 8000; %sampling rate [Hz]
dur_beep = 0.1; %duration of the beep [s]
beep_time = 0:(1/Fs):dur_beep; %time vector

freq = 240;
freq2 = 600; %frequency of beep [Hz]

low_beep = sin(2*pi*freq*beep_time); %sin wave at 60Hz
high_beep = sin(2*pi*freq2*beep_time); %sin wave at 60Hz

sendEvent('relax','iti')

if dur_iti > 3
    pause(dur_iti-3)
end

sound(low_beep,Fs)
pause(1)
sound(low_beep,Fs)
pause(1)
sound(low_beep,Fs)
pause(1)
sound(high_beep,Fs)
end