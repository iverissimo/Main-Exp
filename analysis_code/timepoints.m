function [tmp] = timepoints(events,smp1,fs)
%function to obtain vector of timepoints for specific events 
%(e.g. trial start, block start, iti periods,...)

%INPUT
%   events - event strcuture obtained by ft_filter_event
%   smp1 - first sample, within the testing phase
%   fs - sample frenquency
%OUTPUT
%   tmp - timepoint vector

for k = 1:length(events)
    tmp(k) = (events(k).sample - smp1)./fs; %start trial timepoints
end

end

