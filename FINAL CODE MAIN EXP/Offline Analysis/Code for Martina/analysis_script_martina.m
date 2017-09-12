
% 5/09/2017
% Author: Inês V.
%
% Script for Martina, for loading and processing subject data
% from the "new motor skill acquisition (toe abduction)" project
%

clear all; close all;

subjnum = input('Subject number: '); %number of subject to be analised
sessnum = input('Session number: '); %number of session to be analised

% % % Add path (replace the XXX with path from your computer)
addpath(genpath('XXXXXXXX')); %insert path to folder where you have this code and the subject data
addpath(genpath('XXXXXXXXX/buffer_bci')); %insert path to folder where you have the buffer bci toolbox
addpath(genpath('XXXXXXXXX/fieldtrip')); %insert path to folder where you have the fieldtrip toolbox
addpath(genpath('XXXXXXXXX/bci_code')); %insert path to folder where you have the bci code toolbox

ft_defaults; % makes sure all fieldtrip paths are correct

% directory for header, events and samples files
pth0 = ['XXXXX/Subjects/' ... %path to folder where the subject data is stored
    sprintf('subject%s/session%s',num2str(subjnum),num2str(sessnum))];

datadir = [pth0 '/' sprintf('test_data_sub%s_session%s',num2str(subjnum),num2str(sessnum))]; %path to folder where the subject data is stored

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

pth = [pth0 '/plots']; %path to folder where the plots will be stored
mkdir(pth) %folder to save plots for specific subject

% % % Load all events
hdrfname=fullfile(fdir,'header'); %path name
hdr = read_buffer_offline_header(hdrfname); %use this function to have right labels in channels
hdr.label = (hdr.label)'; %this way hdr has the same format as hdr from ft_read_header

[all_events] = ft_read_event(fullfile(fdir,'events')); %load all events from buffer

%% Analyse data
cfg = [];
cfg.headerfile = hdrfname;
cfg.datafile = fullfile(fdir,'samples');
cfg.trialdef.eventtype  = 'trial'; %'string'
cfg.trialdef.eventvalue = 'start';%number, string or list with numbers or strings
cfg.trialdef.prestim = 0; % in seconds
cfg.trialdef.poststim = 19.5; % in seconds
cfg = ft_definetrial(cfg);

mi_starttest = matchEvents(all_events,{'startPhase.cmd'},{'contfeedback'}); %find beginnig of testing phase
ind_starttest = find(mi_starttest); %find index
% only look at real experiment data (sometimes something goes wrong, 
% so I have to restart the experiment. this way only the last marker counts)
cfg.event = cfg.event(ind_starttest(end):end); % events from actual experiment
fst_smp = all_events(ind_starttest(end)).sample;% samples from actual experiment

k=1; % this is also for the cases where I had to restart the experiment, in 
if fst_smp>cfg.trl(1) % normal cases this part is skipped
    for i = 1:length(cfg.trl)
        if fst_smp<cfg.trl(i)
            mtx(k,1:3) = cfg.trl(i,:);
            k = k+1;
        end
    end
    cfg.trl = mtx;
    clear k fst_smp mtx
end

% % % Preprocessing
cfg.dataset = cfg.datafile; % string with the filename
cfg.trl = cfg.trl; % Nx3 matrix with the trial definition

cfg.continuous = 'no'; %whether the file contains continuous data
data_sliced = ft_preprocessing(cfg);

data_sliced.label = hdr.label; % had to do this because fieldtrip creates
data_sliced.hdr.label = hdr.label; % fake channels with wrong labels


%% Remove EMG channels
% EXT 5-8 are EMG
cfg.channel = ft_channelselection({'all','-EXG5','-EXG6','-EXG7','-EXG8'}, hdr.label); %only eeg+eog channels
data = ft_preprocessing(cfg,data_sliced);

%% Remove EOG
% EXT 1-4 are EOG
rmpath(genpath('XXXXXX/buffer_bci')); %remove buffer bci from path, to avoid confusion with artChRegress function
cfg = [];
eog_ch = {'EXG1','EXG2','EXG3','EXG4'}; %eog channels
data1 = subtractEOG(data,eog_ch);

%% preprocessing of only eeg channels
cfg.channel = ft_channelselection({'all','-EXG*'}, hdr.label); %only eeg channels
cfg.dftfilter ='yes'; %line noise removal using discrete fourier transform
cfg.detrend = 'yes'; %remove linear trend from the data (done per trial)
data2 = ft_preprocessing(cfg,data1);

%% Reject channels
% reject channels with std > 3
[data3,info,freq] = iv_rejectBadChannels(data2,[],0,0);

%% Filtering
%use CAR and BP filter (default type is butterworth)
%want to focus on mu [8 13] and beta [15 30] frequencies
cfg = [];
cfg.bpfilter = 'yes'; % bandpass filter
cfg.bpfreq = [8 40]; % bandpass frequency range, specified as [low high] in Hz
cfg.bpfiltord = 6; % bandpass filter order
data4 = ft_preprocessing(cfg,data3);

%compute common average reference
cfg = [];
cfg.channel = 'all';
cfg.refmethod = 'avg';
cfg.reref = 'yes';
cfg.refchannel = 'all'; %average over all EEG channels

data4 = ft_preprocessing(cfg,data4);

%% Remove Artifacts (trial-rejection )
num_ch = length(data4.label);
[data5, info] = iv_removeArtifacts_v2(data4,[],[],num_ch); % VERY IMPORTANT! change name of path in line 31 
% to your specific fieldtrip folder path

%% Redefine trials, according to class

cfg = [];
cfg.toilim = [0 6] %cut out a time window of interest in seconds
data_rest = ft_redefinetrial(cfg, data5);%that is common in all trials

cfg = [];
cfg.toilim = [7.5 19.5] %cut out a time window of interest in seconds
data_abd = ft_redefinetrial(cfg, data5); %that is common in all trials

%% Visualize the data!

% Topo distribution of powerspectra similar to Eliana's paper
% plot the topographic distribution of 2-Dimensional datatypes, for mu and beta bands
% also calculates the ERD
plot_topos;



% the rest is up to you :) 
% try to look at the data with different representations, specifically in
% time-frequency plots


