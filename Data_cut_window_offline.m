function [data,events,hdr] = Data_cut_window_offline(fname,evt_type,evt_val1,evt_val2,tot_trial,train_wndow,init_offset,ovrl,ovrl_wndow)
%
% Author: Inês V., April 2017
%
% Function for cutting data into windows, to train a classifier
% Goal: Cut trials into Xms epoch windows, and use all of them to train a
% linear classifier to distinguish 2 classes
% Additionaly, the windows can overlap and have an initial offset

% Inputs
% fname - directory which contains the file name (string)
% evt_type - name of the event type to match (string)
% evt_val1 - name of the event value of 1st class to match (string)
% evt_val2 - name of the event value of 2nd class to match (string)
% tot_trial - total trial length (5000 ms)
% train_wndow - epoch window to train the classifier (750 ms)
%
%   Optional
%   ovrl - overlap windows? (0 - no)
%   ovrl_wndow - length of overlap (ms)
%   init_offset - initial offset [when movement actually started] (500 ms)

% Outputs
% data - [ch x time x epoch] data
% events - [struct epoch x 1] set of buf event structures which contain epoch labels in value field
% hdr - header struct with info regarding the data

if (nargin < 9) ovrl_wndow = 0; warning('No overlap window was chosen... No overlap will occur'); end;
if (nargin < 8) ovrl = 0; end;
if (nargin < 7) init_offset = 0; end;
if (nargin < 6) error('Not enough input arguments'); end;

num_wind = floor((tot_trial-init_offset)/train_wndow); % rounds a number to the next smaller integer.
offs = init_offset;

for i=1:num_wind   %loop to concatenate several train_wndow within same 5s trial,to obtain [ch x time x epoch] data
    
    [data_AvsB,devents_RestvsAbd,hdr,~]=sliceraw(fname,'startSet',{evt_type {evt_val1 evt_val2}},'trlen_ms',train_wndow,'offset_ms',offs);
    new_data = cat(3,data_AvsB(1).buf,data_AvsB(2).buf);
    
    for j = 1:length(devents_RestvsAbd)-2
        new_data = cat(3,new_data,data_AvsB(j+2).buf);
    end
    
    if i == 1
        data = new_data;
        events = devents_RestvsAbd;
    else
        data = cat(3,data,new_data);
        events = cat(1,events,devents_RestvsAbd);
    end
    
    %increment window to slice new segment of trial next loop
    if(ovrl == 1) %if we want to overlap epoch windows
        offs = offs + train_wndow - ovrl_wndow;
    else % if no overlap
        offs = offs + train_wndow;
    end
    
end

end

