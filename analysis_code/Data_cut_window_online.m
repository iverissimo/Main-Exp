function [data,events,hdr] = Data_cut_window_online(traindata,traindevents,hdr,tot_trial,train_wndow,init_offset,ovrl,ovrl_wndow)
%
% Author: In?s V., April 2017
%
% Function for cutting data into windows, to train a classifier
% That works for the online case (with iv_startSigProcBuffer)
% Goal: Cut trials into Xms epoch windows, and use all of them to train a
% linear classifier to distinguish 2 classes
% Additionaly, the windows can overlap and have an initial offset

% Inputs
% traindata -{cell Nx1} cell array of data segments for each recorded event
% devents -- [struct Nx1] structure containing the events associated with each data block
% hdr - header struct with info regarding the data
% tot_trial - total trial length (5000 ms)
% train_wndow - epoch window to train the classifier (750 ms)
%
%   Optional
%   init_offset - initial offset [when movement actually started] (500 ms)
%   ovrl - overlap windows? (0 - no)
%   ovrl_wndow - length of overlap (ms)

% Outputs
% data - [ch x time x epoch] data
% events - [struct epoch x 1] set of buf event structures which contain epoch labels in value field
% hdr - header struct with info regarding the data

if (nargin < 8) ovrl_wndow = 0; warning('No overlap window was chosen... No overlap will occur'); end;
if (nargin < 7) ovrl = 0; end;
if (nargin < 6) init_offset = 0; end;
if (nargin < 5) error('Not enough input arguments'); end;

num_wind = floor((tot_trial-init_offset)/train_wndow); % rounds a number to the next smaller integer.
offs = init_offset;

%offs=init_offset:num_wind:tot_trial;

for i=1:num_wind   %loop to concatenate several train_wndow within same 5s trial,to obtain [ch x time x epoch] data
    
    smp_offset = (offs/1000)*hdr.fsample;
    smp_train_wndow = (train_wndow/1000)*hdr.fsample;
    
    for m = 1:length(traindevents) %number of events/epochs     
        for h = 1:hdr.nchans %number of channels 
            %data_AvsB(m).buf(:,1:smp_train_window)=traindata(m).buf(:,smp_offset+(1:smp_train_window));
            for k = 1:smp_train_wndow %window that we want to slice              
                data_AvsB(m).buf(h,k) = traindata(m).buf(h,smp_offset+k);
            end
        end
    end
    
    new_data = cat(3,data_AvsB(1).buf,data_AvsB(2).buf);
    
    for j = 1:length(traindevents)-2
        new_data = cat(3,new_data,data_AvsB(j+2).buf);
    end
    
    if i == 1
        data = new_data;
        events = traindevents;
    else
        data = cat(3,data,new_data);
        events = cat(1,events,traindevents);
    end
    
    %increment window to slice new segment of trial next loop
    if(ovrl == 1) %if we want to overlap epoch windows
        offs = offs + train_wndow - ovrl_wndow;
    else % if no overlap
        offs = offs + train_wndow;
    end
    
end

end

