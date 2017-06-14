% script to run calibration data and save plots
% do it for abd vs rest and flex vs abd
% also compare loaded data to data cut out from buffer

%data saved and loaded
calib = 1;
dt = load_data(subjnum);
load(dt{1});
[traindata,traindevents,~] = Data_cut_window_online(traindata,traindevents,hdr,5000,750,500);

%Rest vs Abduction
[clsfr_RestvsAbd,res_RestvsAbd,X_RestvsAbd,Y_RestvsAbd]=buffer_train_ersp_clsfr(traindata,traindevents,hdr,...
    'capFile','cap_conf_ines64ch','overridechnms',1,...
    'badchrm',1,'badchthresh',3.5,'badtrrm',1,'badtrthresh',3,'visualize',1,...
    'detrend',1,'spatialfilter','car','width_ms',250,'freqband',[8 30]);

saveas(2, fullfile(pth, sprintf('ersp_load')), 'png');
saveas(3, fullfile(pth, sprintf('auc_load')), 'png');
saveas(4, fullfile(pth, sprintf('confusion_load')), 'png');
close all;
%sub1 - classification was 89.1%
%sub2 - classification was 81.0%
%sub3 - classification was 88.8%
%sub4 - classification was 85.2%
%sub5 - classification was 78.9%

% see classifier performance and plots with data from buffer
[data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd,allevents_RestvsAbd]=sliceraw(fname,'startSet',{'movement' {'toe_abd' 'rest'}},'trlen_ms',5000);
[data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd,allevents_FlexvsAbd]=sliceraw(fname,'startSet',{'movement' {'toe_abd' 'toe_flex'}},'trlen_ms',5000);

% Define calibration trials from buffer and cut them
if subjnum == 1 %some issues with this experiment, different approach
    
    mi_endcal = matchEvents(all_events,{'calibrate'},{'end'}); %find end of calibration phase
    ind_endcal = find(mi_endcal); %find index
    mi_startcal = matchEvents(all_events,{'startPhase.cmd'},{'calibrate'}); %find beginnig of calibration phase
    ind_startcal = find(mi_startcal); %find index
    
    calib_events = all_events(ind_startcal:ind_endcal(length(ind_endcal)));
    calib_events = ft_filter_event(calib_events,'type','movement'); %only events of type movement, within calib phase
    
    for i = 1:length(devents_RestvsAbd)
        mat(i) = devents_RestvsAbd(i).sample;
    end
    
    indx = find(mat == calib_events(length(calib_events)).sample); %index of last mov event of calibration phase
    
    calibDAT_abd_rest = data_RestvsAbd(1:indx);
    calibEV_abd_rest = devents_RestvsAbd(1:indx);
    
    [data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd] = Copy_of_Data_cut_window_online(calibDAT_abd_rest,calibEV_abd_rest,hdr_RestvsAbd,5000,750,500);
    
    calibDAT_abd_flex = data_FlexvsAbd(1:indx);
    calibEV_abd_flex = devents_FlexvsAbd(1:indx);
    
    [data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd] = Copy_of_Data_cut_window_online(calibDAT_abd_flex,calibEV_abd_flex,hdr_FlexvsAbd,5000,750,500);
    
else
    [data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd] = Copy_of_Data_cut_window_online(data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd,5000,750,500);
    [data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd] = Copy_of_Data_cut_window_online(data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd,5000,750,500);
end

%Rest vs Abduction
[clsfr_RestvsAbd,res_RestvsAbd,X_RestvsAbd,Y_RestvsAbd ]=buffer_train_ersp_clsfr(data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd,...
    'capFile','cap_conf_ines64ch','overridechnms',1,...
    'badchrm',1,'badchthresh',3.5,'badtrrm',1,'badtrthresh',3,'visualize',1,...
    'detrend',1,'spatialfilter','car','width_ms',250,'freqband',[8 30]);

saveas(2, fullfile(pth, sprintf('ersp_RAcalib_buffer')), 'png');
saveas(3, fullfile(pth, sprintf('auc_RAcalib_buffer')), 'png');
saveas(4, fullfile(pth, sprintf('confusion_RAcalib_buffer')), 'png');
close all;
%sub1 - classification was 89.2%
%sub2 - classification was 81.7%
%sub3 - classification was 88.8%
%sub4 - classification was 85.2%
%sub5 - classification was 78.9%

%Abduction vs Flexion
[clsfr_FlexvsAbd,res_FlexvsAbd,X_FlexvsAbd,Y_FlexvsAbd]=buffer_train_ersp_clsfr(data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd,...
    'capFile','cap_conf_ines64ch','overridechnms',1,...
    'badchrm',1,'badchthresh',3.5,'badtrrm',1,'badtrthresh',3,'visualize',1,...
    'detrend',1,'spatialfilter','car','width_ms',250,'freqband',[8 30]);

saveas(2, fullfile(pth, sprintf('ersp_FAcalib_buffer')), 'png');
saveas(3, fullfile(pth, sprintf('auc_FAcalib_buffer')), 'png');
saveas(4, fullfile(pth, sprintf('confusion_FAcalib_buffer')), 'png');
close all;
%sub1 - classification was 73.7%
%sub2 - classification was 62.2%
%sub3 - classification was 84.7%
%sub4 - classification was 69.6%
%sub5 - classification was 62.7%

