%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %       auxiliar script with all useful variables and functions      % %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add path
addpath(genpath('/Users/s4831829/buffer_bci'));

%% Set-up a connection with the buffer
buffhost = 'localhost'; buffport = 1972;
% wait for the buffer to return valid header information
hdr=[];
while ( isempty(hdr) || ~isstruct(hdr) || (hdr.nchans==0) ) % wait for the buffer to contain valid data
    try
        hdr=buffer('get_hdr',[],buffhost,buffport);
    catch
        hdr=[];
        fprintf('Invalid header info... waiting.\n');
    end;
    pause(1);
end;

%% Buttonbox settings for lab3 (using the USB multiport)

bb.Device    = '/dev/tty.usbmodem141131';%'/dev/tty.usbmodem141121';
bb.BaudRate  = 115200;
bb.DataBits  = 8;
bb.StopBits  = 1;
bb.Parity    = 'none';

time2press = 10*60; % [s] wait a maximum of 10 minutes for a button press, or else continue

% (http://tsgdoc.socsci.ru.nl/index.php?title=ButtonBoxes#Matlab)
% to initialize connection: (omit 2nd argument if defaults apply)
% define settings as bb structure with abovementioned fields

%% Robot settings
%Serial port name for arduino connection
comport = '/dev/tty.usbmodem141141';%'/dev/tty.usbmodem141131';%'/dev/tty.usbmodem14111'; 
ang_max = 140; %max angle for robot movement
ang_min = 0; %min angle for robot movement

%% General experiment settings
% Training/Calibration
dur_trial_cal = 5;                              %trial duration [s]
dur_iti_cal = 3;                                % inter-trial-interval [s]
num_trial_cal = 3;                          % number of trials in one block
num_block_cal = 18;%3;                             % number of blocks
cond_cal = 3;                                   % number of conditions being tested
cond_name_cal = {'abduct your toe','flex your toes','do not move'};
evt_value_cal = {'toe_abd','toe_flex','rest'}; %event value for type 'movement'
num_total_cal = num_trial_cal*num_block_cal;            % total number of trials
type_cal = [1 2 3]; %type of condition, matrix of 1xcond
num_cal = zeros(1,length(type_cal)); %number of blocks per condition, matrix of 1xcond
end_cond_cal = round(num_block_cal/cond_cal); %max number of blocks per condition
group_type = {'sham' 'visual' 'active'};

% Testing
dur_trial = 12;                              % move trial duration[s]
dur_iti = 3;                            % inter-trial-interval [s]
dur_bl = 6;                                  % baseline trial duration [s]
dur_feedback = 1.5;                           % feedback duration (s)
num_trial = 3;                          % number of trials in one block
num_block = 30;%6;                             % number of blocks
cond = 2;                                   % number of conditions being tested
cond_name = {'abduct your toe','do not move'};
evt_value = {'toe_abd','rest'}; %event value for type 'movement'
num_total = num_trial*num_block;            % total number of trials
type = [1 2]; %type of condition, matrix of 1xcond
end_cond = round(num_block/cond); %max number of blocks per condition
points = 0; %performance feedback counter
curr_points = zeros(1,num_block); %points obtained in the end of each block
bl_points = zeros(num_block,num_trial);
abd_points = zeros(num_block,num_trial);

%% Classifier settings
% for training 
cfgcls.tot_trl = dur_trial_cal*1000; %total trial duration in calibration phase [ms]
cfgcls.train_wndow = 750; %window of data to use from calibration [ms]
cfgcls.init_offset = 500; %initial offset [ms]
cfgcls.ovrl = 0; %overlap windows? (0 - no)
cfgcls.ovrl_wndow = 0; %length of overlap [ms]
cfgcls.freqband = [8 30]; %frequency band to preprocess data
cfgcls.welch_width_ms = 250; % width of welch window => spectral resolution
cfgcls.badtrrm = 0; %remove bad trials
cfgcls.spatialfilter = 'car+wht'; %spatial filter used
cfgcls.adaptspatfchn = {'EXG1' 'EXG2' 'EXG3' 'EXG4' 'AFz' 'AF3' 'FP1' 'FPz' ...
   'FP2' 'AF4' 'AF8' 'AF7' '1/f' 'EMG'};% channels used for artefact removal 

cfgcls.trainOpts = {'width_ms',cfgcls.welch_width_ms,'badtrrm',cfgcls.badtrrm,'spatialfilter',cfgcls.spatialfilter,...
    'adaptspatialfiltFn',{'filtPipeline' {'rmEMGFilt' []} {'artChRegress',[],cfgcls.adaptspatfchn}},...
    'objFn','mlr_cg','binsp',0,'spMx','1vR'}; % (emg-removal->eog-removal) + direct multi-class training

thresh = []; % threshold to reach before giving feedback
rnd_thresh = []; %tresh for random outcome, biased to not giving feedback

%% Display settings
txtColor = [.8 .8 .8];                      %text color
txtSize_wlc = 50;%33;                        %welcome text size
txtSize_cue = 70;%50;                        %cue text size

% Training/Calibration
welcometxt1 = sprintf(['\n\nWelcome to this experiment!' ...
    '\n\nYou will be asked to perform certain movements on cue.' ...
    '\n\nIf you do not understand the task, or simply' ...
    '\nwant to stop, please inform the researcher.'...
    '\n\nThe experiment consists of %d blocks, '...
    '\nand from time to time you will have a small resting period.' ...
    '\n\n\nPress button 1 to continue...'],num_block_cal);

welcometxt2 = sprintf(['\n\nIn the first block you will have to abduct your right toe.' ...
    '\n\nYou will hear 3 low beeps, in order to get ready.' ...
    '\n\n\nPress button 1 to hear an example...']);

welcometxt3 = sprintf(['\n\nWhen you hear the high pitch, please start the movement.' ...
    '\nAfter a few seconds you will hear a low beep,'...
    '\nindicating that the trial is finished.'...
    '\n\nYou can move your toe as many times as you wish,'...
    '\nbetween these two cues.' ...
    '\n\nTry to keep your other toes still,'...
    '\nas well as the rest of your body.' ...
    '\nPlease DO NOT look at your feet. Stare at the screen in front of you.'...
    '\n\n\nPress button 1 to start...']);

welcometxt4 = sprintf(['\n\nIn the second block you will have to flex your toes.' ...
    '\n\nYou can move all your toes,' ...
    '\nbut keep your foot on the ground.' ...
    '\n\nTry to relax and not move the rest of your body.' ...
    '\n\nStare at the screen in front of you.'...
    '\n\n\nPress button 1 to start...']);

welcometxt5 = sprintf(['\n\nIn some blocks you will be asked not to move.' ...
    '\n\nIn these cases please keep still and relaxed.' ...
    '\n\nObserve the monitor in front of you.'...
    '\n\n\nPress button 1 to start...']);

welcometxt6 = sprintf(['\n\nSee? It''s simple.' ...
    '\n\nFor the following blocks you just have to abduct or flex' ...
    '\nyour toes when you hear the cue.' ...
    '\n\nRemember, try to keep still and relaxed.'...
    '\n\n\nPress button 1 to continue...']);

welcometxt7 = sprintf(['\n\nIn the following blocks you just have to abduct, flex,' ...
    '\nor not move your toes when you hear the cue.' ...
    '\n\nRemember, try to keep still and relaxed.'...
    '\n\nPlease DO NOT look at your feet. Stare at the screen in front of you.'...
    '\n\n\nPress button 1 to start...']);

goodbyetxt = sprintf('\nThank you! \n\nWait for more instructions regarding the second part.');

% Testing
welcometxtII_1 = sprintf(['\n\nWelcome to this experiment!' ...
    '\n\nYou will be asked to try to move your toe on cue.' ...
    '\n\nIf you do not understand the task, or simply' ...
    '\nwant to stop, please inform the researcher.'...
    '\n\nThe experiment consists of %d blocks, '...
    '\nwith a small resting period between them.' ...
    '\n\n\nPress button 1 to continue...'],num_block);

welcometxtII_2 = sprintf(['\n\nIn the beginning of the block, you will hear an audio cue.' ...
    '\nInstructions will appear on the screen, asking you to not move.'...
    '\nIf you remain still, you will gain points.'...
    '\n\n\nPress button 1 to continue...']);

welcometxtII_2_1 = sprintf(['\n\nAfter some seconds you will hear a second audio cue.'...
    '\nInstructions will appear on the screen, asking you to abduct your toe.'...
    '\n\nYou can move as many times as you which,'...
    '\nuntil the text on the screen disappears.'...
    '\n\n\nPress button 1 to continue...']);

welcometxtII_3_1 = sprintf(['\n\nDuring the trial you will see \nthe score of your performance on the screen.' ...
    '\n\nAdditionally, when trying to abduct,'...
    '\nyou will receive feedback from the robot.' ...
    '\n\nUse this information to correct your movement.'...
    '\n\nIf you stay relaxed and don''t move the rest of your body,'...
    '\nyour performance will be better.' ...
    '\n\n\nPress button 1 to continue...']);

welcometxtII_3_2 = sprintf(['\n\nDuring the trial you will see \nthe score of your performance on the screen.' ...
    '\n\nUse this information to correct your movement.'...
    '\n\nIf you stay relaxed and don''t move the rest of your body,'...
    '\nyour performance will be better.' ...
    '\n\n\nPress button 1 to continue...']);

welcometxtII_4 = sprintf(['\n\nPress button 1 to do an example block...']);

welcometxtII_5 = sprintf(['\n\nSee? It''s simple.' ...
    '\n\nRemember, try to keep still and relaxed.'...
    '\nAnd please DO NOT look at your feet. \n\nStare at the screen in front of you.'...
    '\n\n\nPress button 1 to start...']);

goodbyetxtII = sprintf('\nThank you for participating! \n\nHave a nice day :)');
