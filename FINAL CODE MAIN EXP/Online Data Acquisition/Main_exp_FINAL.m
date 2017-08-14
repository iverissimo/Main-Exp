
%% Author: Ines Verissimo
%% Visual display for main experiment
% 2 conditions (ABD,REST)
% 3 groups: visual SMR feedback, active robot-control, sham robot-control
% 64ch EEG + 8EXT (4EOG + 4 EMG)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                       before starting check values of
%               txtSize_wlc,txtSize_cue, num_trial, num_block
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear all; close all;

cfgcls.sub = input('Write subject number: ','s');
cfgcls.session = input('Write session number: ','s');
cfgcls.pth_lab3 = sprintf('/Users/s4831829/output/troubleshooting subjects/subject%s/session%s',cfgcls.sub,cfgcls.session);
%cfgcls.pth_lab3 = sprintf('/Users/s4831829/output/real test subjects/subject%s/session%s',cfgcls.sub,cfgcls.session);
mkdir(cfgcls.pth_lab3);

configureMain_exp_FINAL; % call all variables that are needed to run the code

save([cfgcls.pth_lab3 '/cfgcls.mat'],'cfgcls');

%% Part I, training/calibration phase
% similar to design used in first pilot

Main_runcalibration;

%% Train classifier

comd = -1; %just to run while loop
while (comd < 0)
    comd = input('Train classifier? yes - 1, no - 0: ');
    if (comd == 1)
        sendEvent('startPhase.cmd','trainersp');
    elseif (comd == 0)
        warning('Classifier was not trained, using previously trained classifier');
        break;
    else
        disp('Option not available.')
        comd = -1;
    end
end

%% Plot ROC curve

rocplot = -1; %just to run while loop
while (comd < 0)
    rocplot = input('Plot ROC curve ? (yes = 1): ');
    
    if (rocplot == 1)
        resname = sprintf('res_test_sub%s_session%s',cfgcls.sub,cfgcls.session);
        res = load([cfgcls.pth_lab3 '/' resname]); %struct with results from calib (train clsfr)
        thresh = ROCthresh_online(res,1,cfgcls.pth_lab3);
        thresh = 1./(1+exp(-thresh)); % convert from dv to probability (logistic transformation)
        
    else
        disp('Option not available.')
        rocplot = -1;
    end
end


%% Part II, With Feedback

group = -1; %just to run while loop
while (group < 0)
    group = input('Participant belongs to which group?\n 1-Sham; 2-Visual; 3-Active\n Answer: ');
    if (group == 1 || group == 2 || group == 3)
        break;
    else
        disp('Option not available.')
        group = -1;
    end
end

cfgcls.subinfo.group = group_type{group}; %save subject group type in cfgclsr struct

sendEvent('startPhase.cmd','contfeedback'); % start continuous feedback phase
angle = -1;

if group == 1 || group == 3
    
    [srl] = initSrlPort(comport); %open arduino serial port
    save('srl','srl');
    robot_rest(srl); %run it once just so it goes to initial position
    
    ang_calib; %launch gui for to select best angle for participant
    
    % get the handle to the GUI and wait for it to be closed
    hGui = findobj('Tag','tformChoiceGui');
    waitfor(hGui);
    
    % continue with script
    while (angle < 0 )
        angle = input('Specify angle for robot movement (max 140): '); %angle for robot max position
        if (ang_min <= angle) && (angle <= ang_max)
            angle = 180 - angle; %Eg: Want it to move 100, but actual motor position is 80
            break;
        else
            disp('Option not available.')
            angle = -1;
        end
    end
    
end

% Welcome text
fig = figure(3);
set(fig,'units','pixels','MenuBar','none','color',[0 0 0]);

text(0,6,welcometxtII_1,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');

%added this so I have time to maximize figure in subjects computer,
%before buffernewevents freezes my figure
mx = -1; %just to run while loop
while (mx < 0)
    mx = input('Maximize figure in subject''s computer screen! If ready to start enter 1: ');
    if mx == 1
        break;
    else
        disp('Option not available.')
        mx = -1;
    end
end

press_button;
clf;

text(0,6,welcometxtII_2,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
press_button;
clf;

text(0,6,welcometxtII_2_1,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
press_button;
clf;

switch group
    
    case 1 %%%%%%%%%%%%%%%%%%%  sham robot control  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        case1_sham_FINAL;
        
    case 2 %%%%%%%%%%%%%%%%%%%  visual SMR feedback  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        case2_visual_FINAL;
        
    case 3 %%%%%%%%%%%%%%%%%%%  active robot control  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        case3_active_FINAL;
        
end

sendEvent('testing','end'); % start continuous feedback phase

cfgcls.subinfo.curr_points = curr_points; % points by the end of each block
cfgcls.subinfo.bl_points = bl_points; % baseline points [num block x num trial]
cfgcls.subinfo.abd_points = abd_points; % toe abduction points [num block x num trial]

%save interesting variables
if group == 1 || group == 3
    endSrlPort(srl); % close serial por communication
    cfgcls.subinfo.robotang = 180-angle; % real angle value
end

save([cfgcls.pth_lab3 '/cfgcls.mat'],'cfgcls'); % save structure again, now with all relevant sub info

text(0,6,goodbyetxtII,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
drawnow;

pause(dur_iti);
close(fig)

