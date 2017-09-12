% script to run calibration data and save plots
% do it for abd vs rest and flex vs abd
% also compare loaded data to data cut out from buffer

%data saved and loaded
calib = 1;
load(['C:/Users/Inês/Desktop/FINAL CODE MAIN EXP/Subjects/' ...
    sprintf('troubleshooting subjects/subject%s/session%s',num2str(subjnum),num2str(sessnum)) ...
    '/' sprintf('training_data_test_sub%s_session%s',num2str(subjnum),num2str(sessnum))]);
[traindata,traindevents,~] = Data_cut_window_online(traindata,traindevents,hdr,5000,750,500);

%Rest vs Abduction
[clsfr_RestvsAbd,res_RestvsAbd,X_RestvsAbd,Y_RestvsAbd]=buffer_train_ersp_clsfr(traindata,traindevents,hdr,...
    'capFile','cap_conf_ines64ch','overridechnms',1,...
    'badchrm',1,'badchthresh',3.5,'badtrrm',1,'badtrthresh',3,'visualize',1,...
    'detrend',1,'spatialfilter','car+wht','width_ms',250,'freqband',[8 30],...
    'adaptspatialfiltFn',{'filtPipeline' {'rmEMGFilt' []} ...
    {'artChRegress',[],{'EXG1' 'EXG2' 'EXG3' 'EXG4' 'AFz' 'AF3' 'FP1' 'FPz' ...
   'FP2' 'AF4' 'AF8' 'AF7' 'Iz' 'O1' 'Oz' 'O2' 'P9' 'P10' '1/f' 'EMG'}}});

perf = input('Performance percentage? ');

saveas(2, fullfile(pth, sprintf('ersp_load_%s%%.png',num2str(perf))));
saveas(3, fullfile(pth, sprintf('auc_load_%s%%.png',num2str(perf))));
saveas(4, fullfile(pth, sprintf('confusion_load_%s%%.png',num2str(perf))));
close all;

% see classifier performance and plots with data from buffer
[data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd,allevents_RestvsAbd]=sliceraw(fname,'startSet',{'movement' {'toe_abd' 'rest'}},'trlen_ms',5000);
[data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd,allevents_FlexvsAbd]=sliceraw(fname,'startSet',{'movement' {'toe_abd' 'toe_flex'}},'trlen_ms',5000);

% Define calibration trials from buffer and cut them
[data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd] = Data_cut_window_offline_FINAL(data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd,5000,750,500);
[data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd] = Data_cut_window_offline_FINAL(data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd,5000,750,500);

%Rest vs Abduction
[clsfr_RestvsAbd,res_RestvsAbd,X_RestvsAbd,Y_RestvsAbd ]=buffer_train_ersp_clsfr(data_RestvsAbd,devents_RestvsAbd,hdr_RestvsAbd,...
    'capFile','cap_conf_ines64ch','overridechnms',1,...
    'badchrm',1,'badchthresh',3.5,'badtrrm',1,'badtrthresh',3,'visualize',1,...
    'detrend',1,'spatialfilter','car+wht','width_ms',250,'freqband',[8 30],...
    'adaptspatialfiltFn',{'filtPipeline' {'rmEMGFilt' []} ...
    {'artChRegress',[],{'EXG1' 'EXG2' 'EXG3' 'EXG4' 'AFz' 'AF3' 'FP1' 'FPz' 'FP2' 'AF4' ...
    'AF8' 'AF7' '1/f' 'EMG'}}});

perf = input('Performance percentage? ');

saveas(2, fullfile(pth, sprintf('ersp_RAcalib_buffer_%s%%.png',num2str(perf))));
saveas(3, fullfile(pth, sprintf('auc_RAcalib_buffer_%s%%.png',num2str(perf))));
saveas(4, fullfile(pth, sprintf('confusion_RAcalib_buffer_%s%%.png',num2str(perf))));
close all;

%Abduction vs Flexion
[clsfr_FlexvsAbd,res_FlexvsAbd,X_FlexvsAbd,Y_FlexvsAbd]=buffer_train_ersp_clsfr(data_FlexvsAbd,devents_FlexvsAbd,hdr_FlexvsAbd,...
    'capFile','cap_conf_ines64ch','overridechnms',1,...
    'badchrm',1,'badchthresh',3.5,'badtrrm',1,'badtrthresh',3,'visualize',1,...
    'detrend',1,'spatialfilter','car+wht','width_ms',250,'freqband',[8 30],...
    'adaptspatialfiltFn',{'filtPipeline' {'rmEMGFilt' []} ...
    {'artChRegress',[],{'EXG1' 'EXG2' 'EXG3' 'EXG4' 'AFz' 'AF3' 'FP1' 'FPz' 'FP2' 'AF4' ...
    'AF8' 'AF7' '1/f' 'EMG'}}});

perf = input('Performance percentage? ');

saveas(2, fullfile(pth, sprintf('ersp_FAcalib_buffer_%s%%.png',num2str(perf))));
saveas(3, fullfile(pth, sprintf('auc_FAcalib_buffer_%s%%.png',num2str(perf))));
saveas(4, fullfile(pth, sprintf('confusion_FAcalib_buffer_%s%%.png',num2str(perf))));
close all;

