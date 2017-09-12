
%%%%%%%%%%%% FIELDTRIP ANALYSIS SCRIPT %%%%%%%%%%%%
%to cut, process and plot main exp (piloting) data%

clear all; close all;

%%%%%%%%%% intial parameters%%%%%%%%%%%%
doplot = 1; %plot prediction values (1)
keepch = 0; % keep central channels (1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pc = -1; %just to run while loop
while (pc < 0)
    pc = input('Laptop(1) or Lab3 computer(2)? \nAnswer:');
    if (pc == 1 || pc == 2)
        break;
    else
        disp('Option not available.')
        pc = -1;
    end
end

subjnum = input('Subject number: '); %number of subject to be analised
sessnum = input('Session number: '); %number of subject to be analised

if pc == 1 %laptop
    % % % Add path
    addpath(genpath('C:/Users/Inês/Desktop/FINAL CODE MAIN EXP'));
    addpath(genpath('D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/buffer_bci'));
    addpath(genpath('D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/fieldtrip-20161107'));
    addpath(genpath('D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/bci_code'));
    
    ft_defaults; % makes sure all fieldtrip paths are correct
    
    % directory for header, events and samples files
    pth0 = ['C:/Users/Inês/Desktop/FINAL CODE MAIN EXP/Subjects/' ...
        sprintf('troubleshooting subjects/subject%s/session%s',num2str(subjnum),num2str(sessnum))];
    
    datadir = [pth0 '/' sprintf('test_data_sub%s_session%s',num2str(subjnum),num2str(sessnum))];
    
    fname = datadir;
    % get the directory which contains the files
    if (isdir(fname))
        fdir=fname;
    else % strip the file-name part out
        [fdir,fname,fext]=fileparts(fname);
        if (~isdir(fdir))
            error('Couldnt find output directory!');
        end
    end
    
    pth = [pth0 '/plots'];
    mkdir(pth) %folder to save plots for specific subject
    
else %%% NOT CHANGED, NEED TO CHECK CORRECT PATHS IN LAB3
    
    % % % Add path
    addpath(genpath('/Users/s4831829/Main Exp'));
    addpath(genpath('/Users/s4831829/buffer_bci'));
    addpath(genpath('/Users/s4831829/bci_code/external_toolboxes/fieldtrip'));
    addpath(genpath('/Users/s4831829/bci_code/toolboxes'));
    rmpath(genpath('/Users/s4831829/bci_code/toolboxes/brainstream'));
    addpath(genpath('/Users/s4831829/output'));
    
    ft_defaults; % makes sure all fieldtrip paths are correct
    
    % directory for header, events and samples files
    datadir = {'[]','[]','[]','[]',...
        '/Users/s4831829/output/test/170612/1951/raw_buffer/0001',...
        '/Users/s4831829/output/test/170614/1535/raw_buffer/0001',...
        '[]','[]','[]','[]','[]','[]',...
        '/Users/s4831829/output/test/170622/1336/raw_buffer/0001'}; %sub13
    
    load_data = sprintf('training_data_test_sub%s',num2str(subjnum));
    
    fname = datadir{subjnum};
    % get the directory which contains the files
    if (isdir(fname))
        fdir=fname;
    else % strip the file-name part out
        [fdir,fname,fext]=fileparts(fname);
        if (~isdir(fdir))
            error('Couldnt find output directory!');
        end
    end
    
    pth = sprintf('/Users/s4831829/Main Exp/analysis_code/analysis_plots/sub%s',num2str(subjnum));
    mkdir(pth) %folder to save plots for specific subject
    
end


% % % Load all events
hdrfname=fullfile(fdir,'header'); %path name
hdr = read_buffer_offline_header(hdrfname); %use this function to have right labels in channels
hdr.label = (hdr.label)'; %this way hdr has the same format as hdr from ft_read_header

if pc == 2 lbl = textread('labels.txt', '%s', 'delimiter', '\n'); hdr.label = lbl; end;

[all_events] = ft_read_event(fullfile(fdir,'events')); %load all events from buffer
calib = 0;

%% CALIBRATION
% no need to run this everytime
analysis_calibration_FINAL;

%% ROC curve obtained for calibration data

res = load([pth0 '/' sprintf('res_test_sub%s_session%s',num2str(subjnum),num2str(sessnum))]); %struct with results from calib (train clsfr)
[thresholds] = ROCthresh_calib_offline(res,pth);
close all;

%% Actual experiment
% some plots regarding dv, points and roc threshold evolution
if subjnum == 9 && sessnum == 1
    
    if calib == 1
        fs = hdr.fsample;
        hdr.label = hdr.labels;
    else %sample frequency, because hdr.Fs/FSample changes names when running calib data
        fs = hdr.Fs;
    end
    
    mi_starttest = matchEvents(all_events,{'startPhase.cmd'},{'contfeedback'}); %find beginnig of testing phase
    ind_starttest = find(mi_starttest); %find index
    mi_endtest = matchEvents(all_events,{'testing' 'test'},{'end'}); %find end of testing phase
    ind_endtest = find(mi_endtest); %find index
else
    [somestruct,hdr] = analysis_mainpredvalues_FINAL(all_events,hdr,calib,doplot,pc,pth0,pth);
end

if doplot == 1
  save([pth0 '/' sprintf('eventstruct_sub%s_session%s.mat',num2str(subjnum),num2str(sessnum))],'somestruct')
end

ind_starttest = somestruct.ind_starttest;

%% Get dv matrix to use for sham cases

if ((subjnum == 9 && sessnum == 1) || (subjnum == 7 && sessnum == 1) || (subjnum == 2 && (sessnum == 2 || sessnum == 3)))
    % exceptions because num blocks less than 30
    warning('Subject session is not valid for sham use, not enough blocks')
else
    shamDV(subjnum,sessnum,pth0);
end

%% Analyse data
cfg = [];
cfg.headerfile = hdrfname;
cfg.datafile = fullfile(fdir,'samples');
cfg.trialdef.eventtype  = 'trial'; %'string'
cfg.trialdef.eventvalue = 'start';%number, string or list with numbers or strings
cfg.trialdef.prestim = 0; % in seconds
cfg.trialdef.poststim = 19.5; % in seconds
cfg = ft_definetrial(cfg);

if subjnum == 9 && sessnum == 1 %only look at real experiment data, exception for subject 9 that went wrong
    ev1 = cfg.event(ind_starttest(1):ind_endtest(1)-1);
    ev2 = cfg.event(ind_starttest(2)-1:ind_endtest(2));
    cfg.event = [ev1; ev2];
else
    cfg.event = cfg.event(ind_starttest(end):end); %only look at real experiment data
    fst_smp = all_events(ind_starttest(end)).sample;
    
    k=1;
    if fst_smp>cfg.trl(1)
        for i = 1:length(cfg.trl)
            if fst_smp<cfg.trl(i)
                mtx(k,1:3) = cfg.trl(i,:);
                k = k+1;
            end
        end
        cfg.trl = mtx;
        clear k fst_smp mtx
    end
end

% % % Preprocessing
% If you are calling FT_PREPROCESSING with only the configuration as first
% input argument and the data still has to be read from file, you should specify

cfg.dataset = cfg.datafile; % string with the filename
cfg.trl = cfg.trl; % Nx3 matrix with the trial definition

cfg.continuous   = 'no'; %whether the file contains continuous data
data_sliced = ft_preprocessing(cfg);

data_sliced.label = hdr.label;%labels; % had to do this because fieldtrip creates
data_sliced.hdr.label = hdr.label;%labels; %fake channels with wrong labels

% % % % do this after 1st preprocessing, not sure why but works, maybe
% related to fake labels

%% Remove EMG channels
% EXT 5-8 are EMG
cfg.channel = ft_channelselection({'all','-EXG5','-EXG6','-EXG7','-EXG8'}, hdr.label);%s); %only eeg+eog channels
data = ft_preprocessing(cfg,data_sliced);


%% Remove EOG
% EXT 1-4 are EOG
if pc == 2; rmpath(genpath('/Users/s4831829/buffer_bci'));
else rmpath(genpath('D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/buffer_bci')); end; %remove buffer bci from path in lab3, to avoid artChRegress confusion
cfg = [];
eog_ch = {'EXG1','EXG2','EXG3','EXG4'}; %eog channels
data1 = subtractEOG(data,eog_ch);

%% preprocessing of only eeg channels
cfg.channel = ft_channelselection({'all','-EXG*'}, hdr.label);%s); %only eeg channels
cfg.dftfilter ='yes'; %line noise removal using discrete fourier transform
cfg.detrend = 'yes'; %remove linear trend from the data (done per trial)
data2 = ft_preprocessing(cfg,data1);

%% Reject channels
% reject channels with std > 3
[data3,info,freq] = iv_rejectBadChannels(data2,[],0,keepch);

%% Filtering
%use CAR and BP filter (default type is butterworth)
%want to focus on mu [8 13] and beta [15 30] frequencies
cfg = [];
cfg.bpfilter = 'yes'; % bandpass filter
cfg.bpfreq = [8 40];%[8 30]; %bandpass frequency range, specified as [low high] in Hz
cfg.bpfiltord = 6; %bandpass filter order
data4 = ft_preprocessing(cfg,data3);

%compute common average reference
cfg = [];
cfg.channel = 'all';
cfg.refmethod = 'avg'; % or 'median'
cfg.reref = 'yes';
cfg.refchannel = 'all'; %average over all EEG channels

data4 = ft_preprocessing(cfg,data4);


%% Remove Artifacts (trial-rejection )
num_ch = length(data4.label);
[data5, info] = iv_removeArtifacts(data4,[],[],num_ch,pc);

%% Redefine trials, according to class

cfg = [];
cfg.toilim = [7.5 19.5] %cut out a time window of interest in seconds
data_abd = ft_redefinetrial(cfg, data5); %that is common in all trials

cfg = [];
cfg.toilim = [0 6] %cut out a time window of interest in seconds
data_rest = ft_redefinetrial(cfg, data5);%that is common in all trials

% % % % % % % % % % % % % % % % % % % % %
%%              VISUALIZE DATA
% % % % % % % % % % % % % % % % % % % % %
%% plot the event-related potentials, event-related fields
%  or oscillatory activity (power or coherence) versus frequency. Multiple
%  datasets can be overlayed.

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';    % return the power-spectra, jason said to use log/dB but not possible in fieldtrip
cfg.taper  = 'hanning';
cfg.foilim = [8 30]; % [begin end] frequency band of interest

[datafreq_rest] = ft_freqanalysis(cfg, data_rest);
[datafreq_toeabd] = ft_freqanalysis(cfg, data_abd);

%% Powerspectra
%can't do multiplotER, data has different lengths
%plot for 20 chnls like in log transform

ch_cent = {'FC3','FC1','FCz','FC2','FC4',...
    'C3','C1','Cz','C2','C4',...
    'CP3','CP1','CPz','CP2','CP4',...
    'P3','P1','Pz','P2','P4'}; %central/motorstrip chn

lbls = datafreq_rest.label(:) %all channel labels (after preproc, so can be < 64)

for i = 1:length(ch_cent)
    for j = 1:length(lbls)
        if strcmp(lbls{j},ch_cent{i}) == 1
            ch_ind(i) = j; %save indexes of interest
        end
    end
end
mxpow = max([max(max(datafreq_toeabd.powspctrm)) max(max(datafreq_rest.powspctrm))]); %max power

figure
for i = 1:20
    subplot(4,5,i);
    if ch_ind(i)~= 0
        a = plot(datafreq_toeabd.freq,datafreq_toeabd.powspctrm(ch_ind(i),:))
        hold on
        b = plot(datafreq_rest.freq,datafreq_rest.powspctrm(ch_ind(i),:))
        legend([a b],'abd','rest');
        title(sprintf('Power Spectrum for %s',ch_cent{i}))
        xlabel('Frequency [Hz]')
        ylabel('Power')
        ylim([0 mxpow])
    end
end

warning(sprintf('Have to manually save fig!'));
if keepch == 1 nam = 'powerspectra_20ch_allch';
else  nam = 'powerspectra_20ch'; end;

stahp = -1; %just to run while loop
while (stahp < 0)
    
    stahp = input('Please maximize fig. \nEnter 1 to continue: ');
    if stahp == 1
        break;
    else
        disp('Option not available.')
        stahp = -1;
    end
end

%saveas(gca, fullfile(pth,nam),'png'); %issue when saving, should expand image
%close all;

%% Try to do a log transform of the power
% is this PSD then [dB]?
datafreq_rest_log = datafreq_rest;
datafreq_rest_log.powspctrm = 10*log10(datafreq_rest_log.powspctrm);
datafreq_toeabd_log = datafreq_toeabd;
datafreq_toeabd_log.powspctrm =10*log10(datafreq_toeabd_log.powspctrm);

mxpow_log = max([max(max(datafreq_toeabd_log.powspctrm)) max(max(datafreq_rest_log.powspctrm))]); %max power
mnpow_log = min([min(min(datafreq_toeabd_log.powspctrm)) min(min(datafreq_rest_log.powspctrm))]); %max power

figure
for i = 1:20
    subplot(4,5,i);
    if ch_ind(i)~= 0
        a = plot(datafreq_toeabd_log.freq,datafreq_toeabd_log.powspctrm(ch_ind(i),:))
        hold on
        b = plot(datafreq_rest_log.freq,datafreq_rest_log.powspctrm(ch_ind(i),:))
        legend([a b],'abd','rest');
        title(sprintf('Power Spectrum for %s',ch_cent{i}))
        xlabel('Frequency [Hz]')
        ylabel('Log Power [dB]')
        ylim([mnpow_log mxpow_log])
    end
end

warning(sprintf('Have to manually save fig!'));
if keepch == 1 nam = 'powerspectra_log_20ch_allch';
else  nam = 'powerspectra_log_20ch'; end;

stahp = -1; %just to run while loop
while (stahp < 0)
    
    stahp = input('Please maximize fig. \nEnter 1 to continue: ');
    if stahp == 1
        break;
    else
        disp('Option not available.')
        stahp = -1;
    end
end

%saveas(gca, fullfile(pth,nam),'png'); %issue when saving, should expand image
%close all;


%% Topo distribution of powerspectra similar to Eliana's paper
%plot the topographic distribution of 2-Dimensional datatypes, for mu and beta bands

plot_topos;

%% multiplotER of the ERD?
% powerspectra of abdduction after normalizing by baseline
cfg = [];
cfg.parameter = 'powspctrm';
cfg.layout = 'biosemi64.lay';
cfg.showlabels = 'yes';

figure
ft_multiplotER(cfg,ERD);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotER_ERD_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotER_ERD'),'png'); end
close all;

cfg = [];
cfg.parameter = 'powspctrm';
cfg.layout = 'biosemi_20ch.lay';%'biosemi64.lay';
cfg.showlabels = 'yes';

figure
ft_multiplotER(cfg,ERD);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotER_20ch_ERD_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotER_20ch_ERD'),'png'); end
close all;


%% TIME- FREQUENCY

TFR_nobase; %TFR plots without baseline subtraction, for both conditions

TFR_basesubtraction; %TFR plots with baseline subtraction, only for movement



