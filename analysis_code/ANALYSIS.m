
%%%%%%%%%%%% FIELDTRIP ANALYSIS SCRIPT %%%%%%%%%%%%
%to cut, process and plot main exp (piloting) data%

clear all; close all;

% % % Add path
mfiledir=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(mfiledir,'..','..','..')));

ft_defaults; % makes sure all fieldtrip paths are correct

% directory for header, events and samples files
datadir = {'D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/Main Exp/troubleshooting/subject1_test/1557/raw_buffer/0001',...
    'D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/Main Exp/troubleshooting/subject2_test/1445/raw_buffer/0001',...
    'D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/Main Exp/troubleshooting/subject3_test/1949/raw_buffer/0001',...
    'D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/Main Exp/troubleshooting/subject4_test/1920/raw_buffer/0001'};

load_data = {'training_data_test_170508','training_data_test_170512','training_data_test_170524',...
    'training_data_test_170531'};
type_tsk = {'visual','active','sham'};

subjnum = 3; %number of subject to be analised
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

pth = sprintf('D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/Main Exp/plots/sub%d',subjnum);
mkdir(pth) %folder to save plots for specific subject

% % % Load all events
hdrfname=fullfile(fdir,'header'); %path name
hdr = read_buffer_offline_header(hdrfname); %use this function to have right labels in channels
hdr.label = (hdr.label)'; %this way hdr has the same format as hdr from ft_read_header

[all_events] = ft_read_event(fullfile(fdir,'events')); %load all events from buffer
calib = 0;

%% CALIBRATION
% no need to run this everytime
analysis_calibration;

%% Actual experiment

analysis_mainpredvalues;

%% Analyse data
cfg = [];
cfg.headerfile = hdrfname;
cfg.datafile = fullfile(fdir,'samples');
if subjnum == 1
   cfg.trialdef.eventtype  = 'movement'; %'string' 
else
    cfg.trialdef.eventtype  = 'trial'; %'string'
    cfg.trialdef.eventvalue = 'start';%number, string or list with numbers or strings
end

cfg.trialdef.prestim = 3; %0; % in seconds
cfg.trialdef.poststim = 15; %5; % in seconds
cfg = ft_definetrial(cfg);

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
data_trials = ft_preprocessing(cfg,data_sliced);


%% Remove EOG
% EXT 1-4 are EOG
cfg = [];
eog_ch = {'EXG1','EXG2','EXG3','EXG4'}; %eog channels
data_trials = subtractEOG(data_trials,eog_ch);

%% preprocessing of only eeg channels
cfg.channel = ft_channelselection({'all','-EXG*'}, hdr.label);%s); %only eeg channels
cfg.dftfilter ='yes'; %line noise removal using discrete fourier transform
cfg.detrend = 'yes'; %remove linear trend from the data (done per trial)
data_trials = ft_preprocessing(cfg,data_trials);

%% Reject channels
% reject channels with std > 3
[data_trials,info,freq] = iv_rejectBadChannels(data_trials,[],0,1); %altered Karen's function

%% Filtering
%use CAR and BP filter (default type is butterworth)
%want to focus on mu [8 13] and beta [15 30] frequencies
cfg = [];
cfg.bpfilter = 'yes'; % bandpass filter
cfg.bpfreq = [8 30];%[8 30]; %bandpass frequency range, specified as [low high] in Hz
cfg.bpfiltord = 6; %bandpass filter order
data_trials = ft_preprocessing(cfg,data_trials);

%compute common average reference
cfg = [];
cfg.channel = 'all';
cfg.refmethod = 'avg'; % or 'median'
cfg.reref = 'yes';
cfg.refchannel = 'all'; %average over all EEG channels

data_trials = ft_preprocessing(cfg,data_trials);


%% Remove Artifacts (trial-rejection )
num_ch = length(data_trials.label);
[data_trials, info] = iv_removeArtifacts(data_trials,[],[],num_ch); %altered Karen's function

%% Redefine trials, according to class

%save trial number per condition
num_trl = 3; %number of trials per block
[trl_abd] = bl2trl(class_abd,num_trl);
[trl_rst] = bl2trl(class_rest,num_trl);

    if exist('info.rejectedTrials') == 0 || isempty(info.rejectedTrials) %if no trials were rejected
        
        cfg = [];
        cfg.trials = trl_abd; %selection given as a 1xN vector (default = 'all')
        data_abd = ft_redefinetrial(cfg, data_trials);
        
        cfg = [];
        cfg.trials = trl_rst; %selection given as a 1xN vector (default = 'all')
        data_rest = ft_redefinetrial(cfg, data_trials);
        
    else
        error('Not coded yet')
        %%%%%%%%%%%%%%% FALTA CÓDIGO PARA ESTES CASOS %%%%%%%%%%%%%%%%%%%%%%%%
    end



%% Visualize
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

cfg = [];
cfg.parameter = 'powspctrm';
cfg.layout = 'biosemi64.lay';
cfg.showlabels = 'yes';

figure
ft_multiplotER(cfg,datafreq_rest,datafreq_toeabd);
saveas(gca, fullfile(pth,'multiplotER_RA'),'png');
close all;

cfg = [];
cfg.parameter = 'powspctrm';
cfg.layout = 'biosemi_20ch.lay';%'biosemi64.lay';
cfg.showlabels = 'yes';

figure
ft_multiplotER(cfg,datafreq_rest,datafreq_toeabd);
saveas(gca, fullfile(pth,'multiplotER_20ch_RA'),'png');
close all;

%% Try to do a log transform of the power
% is this PSD then [dB]?
datafreq_rest_log = datafreq_rest;
datafreq_rest_log.powspctrm = 10*log10(datafreq_rest_log.powspctrm);
datafreq_toeabd_log = datafreq_toeabd;
datafreq_toeabd_log.powspctrm =10*log10(datafreq_toeabd_log.powspctrm);

ch_cent = {'FC3','FC1','FCz','FC2','FC4',...
    'C3','C1','Cz','C2','C4',...
    'CP3','CP1','CPz','CP2','CP4',...
    'P3','P1','Pz','P2','P4'}; %central/motorstrip chn
lbl = datafreq_rest.label(:) %all channel labels

for i = 1:length(ch_cent)
    for j = 1:length(datafreq_rest.label)
        if strcmp(lbl{j},ch_cent{i}) == 1
        ch_ind(i) = j; %save indexes of interest
        end
    end
end

figure
for i = 1:20
    subplot(4,5,i);
    if ch_ind(i)==0
    else
        a = plot(datafreq_toeabd_log.freq,datafreq_toeabd_log.powspctrm(ch_ind(i),:))
        hold on
        b = plot(datafreq_rest_log.freq,datafreq_rest_log.powspctrm(ch_ind(i),:))
        legend([a b],'abd','rest');
        title(sprintf('Power Spectrum for %s',ch_cent{i}))
        xlabel('Frequency [Hz]')
        ylabel('Log Power [dB]')
    end
end
warning(sprintf('Have to manually save fig!\n Save as "powerspectra_log_20ch"'));

%saveas(gca, fullfile(pth,'powerspectra_log_20ch'),'png'); %issue when saving, should expand image
%close all;

%% TIME- FREQUENCY
%MTMCONVOL performs time-frequency analysis on any time series trial
%data using the 'multitaper method'
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 8:1:30; % analysis 8 to 30 Hz in steps of 1 Hz
cfg.taper = 'hanning';
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5 %vector 1 x numfoi, length of time window (in seconds)
cfg.toi = -3:0.5:15;%-3:0.5:15; %-2:0.5:8;%0:0.5:5; % time window "slides" from 0 to 5 sec in steps of 0.5 sec (500 ms)

[datafreq_rest2] = ft_freqanalysis(cfg, data_rest);
[datafreq_toeabd2] = ft_freqanalysis(cfg, data_abd);

%plots the time-frequency representations of power
%in a topographical layout.
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.parameter = 'powspctrm'; %field to be represented as color 
%cfg.maskstyle = 'saturation';
cfg.baseline = [-3 -0.1]; %(default = 'no'), see FT_FREQBASELINE
cfg.baselinetype = 'absolute'; %'relative', 'relchange' or 'db' (default = 'absolute')
cfg.showlabels = 'yes';
cfg.box = 'yes';
cfg.colorbar = 'yes';
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);

figure
ft_multiplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'multiplotTFR_abd'),'png');
close all

figure
ft_multiplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'multiplotTFR_rest'),'png');
close all

%% try out with more central capfile
cfg = [];
cfg.layout = 'biosemi_20ch.lay';
cfg.parameter = 'powspctrm'; %field to be represented as color 
%cfg.maskstyle = 'saturation';
cfg.baseline = [-3 -0.1]; %(default = 'no'), see FT_FREQBASELINE
cfg.baselinetype = 'absolute'; %'relative', 'relchange' or 'db' (default = 'absolute')
cfg.showlabels = 'yes';
cfg.box = 'yes';
cfg.colorbar = 'yes';
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);

figure
ft_multiplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'multiplotTFR_20ch_abd'),'png');
close all

figure
ft_multiplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'multiplotTFR_20ch_rest'),'png');
close all

%% relevant channels in motor strip (for toe movement)
cfg = [];
cfg.baseline     = [-3 -0.1];
cfg.baselinetype = 'absolute';
cfg.maskstyle    = 'saturation'
cfg.showlabels = 'yes';
cfg.colorbar = 'yes';
cfg.channel = 'FCz';
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);
% Blue = ones(101,3);
% Red = ones(101,3);
% Blue(:,3) = 1:-0.01:0;
% Red(:,1) = 0:0.01:1;
% colormap = [Red(1:end-1,:); Blue];
% cfg.colormap     = colormap;

figure
ft_singleplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'TFR_FCz_abd'),'png');
close all

figure
ft_singleplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'TFR_FCz_rest'),'png');
close all

cfg.channel = 'Cz';
figure
ft_singleplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'TFR_Cz_abd'),'png');
close all

figure
ft_singleplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'TFR_Cz_rest'),'png');
close all

cfg.channel = 'CPz';
figure
ft_singleplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'TFR_CPz_abd'),'png');
close all

figure
ft_singleplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'TFR_CPz_rest'),'png');
close all

%% Topo distribution of powerspectra similar to Eliana's paper
%plot the topographic distribution of 2-Dimensional datatypes, for mu and
%beta bands

plot_topos;
