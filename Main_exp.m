%% Author: Ines Verissimo
%% Visual display for main experiment
% 2 conditions (ABD,REST), randomized
% 3 groups: visual SMR feedback, active robot-control, sham robot-control
% 64ch EEG + 8EXT (4EOG + 4 EMG)
% before starting check values of txtSize_wlc,txtSize_cue,
% num_trial, num_block
clear all; close all;

cfgcls.sub = input('Subject (eg. "sub1"): ','s');
cfgcls.pth_lab3 = sprintf('/Users/s4831829/output/plots&&others/%s',cfgcls.sub);
mkdir(cfgcls.pth_lab3);

configureMain_exp;

%% Part I, training/calibration phase
% similar to design used in first pilot

calibrate = -1; %just to run while loop
while (calibrate < 0)
    calibrate = input('Do calibration phase? \n1- Yes; 0 - No. \nAnswer: ');
    if (calibrate == 1 || calibrate == 0)
        break;
    else
        disp('Option not available.')
        calibrate = -1;
    end
end

if calibrate == 1
    sendEvent('startPhase.cmd','calibrate'); %start calibration phase processing in startSigProcBuffer
    % Welcome text
    fig = figure(2);
    set(fig,'units','pixels','MenuBar','none','color',[0 0 0]);
    
    text(0,6,welcometxt1,'Color',txtColor,'FontSize',txtSize_wlc);
    axis([0 10 0 10]);
    set(gca,'visible','off');
    waitforbuttonpress();
    clf;
    
    text(0,6,welcometxt2,'Color',txtColor,'FontSize',txtSize_wlc);
    axis([0 10 0 10]);
    set(gca,'visible','off');
    waitforbuttonpress();
    
    soundTest(dur_iti_cal);
    pause(1)
    
    clf;
    
    text(0,6,welcometxt3,'Color',txtColor,'FontSize',txtSize_wlc);
    axis([0 10 0 10]);
    set(gca,'visible','off');
    waitforbuttonpress();
    clf;
    
    %instructions loop
    for i = 1:cond_cal
        
        tsk = cond_name_cal{i}; %task for condition i
        cue = {sprintf('BLOCK %d',i),sprintf(tsk)};
        
        if i == 2
            %toe flexion explanation
            
            text(0,6,welcometxt4,'Color',txtColor,'FontSize',txtSize_wlc);
            axis([0 10 0 10]);
            set(gca,'visible','off');
            waitforbuttonpress();
            clf;
            
        elseif i == 3
            %rest explanation
            
            text(0,6,welcometxt5,'Color',txtColor,'FontSize',txtSize_wlc);
            axis([0 10 0 10]);
            set(gca,'visible','off');
            waitforbuttonpress();
            clf;
            
        end
        
        for t = 1:num_trial_cal
            %show block number
            text(5,5,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            soundTest(dur_iti_cal); %iti period (beeps)
            
            %show cue = task for the condition
            cue_move = text(5,3,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            sendEvent('example', evt_value_cal{i}) %event type example, to differ from type movement (of interest)
            pause(dur_trial_cal); %movement period
            
            sound_endtrl; % low beep to indicate end of trial
            delete(cue_move);
            pause(0.6) %to not overlap start and finish sounds
        end
        
        clf;
    end
    
    text(0,6,welcometxt6,'Color',txtColor,'FontSize',txtSize_wlc);
    axis([0 10 0 10]);
    set(gca,'visible','off');
    waitforbuttonpress();
    clf;
    
    %%%% start running blocks %%%%
    
    i = 1; %restart counter
    task(i) = randi(cond_cal); %Uniformly distributed pseudorandom integers between 1 and number of conditions
    
    for i = 1:num_block_cal
        
        if ((i > 1)&&(task(i) == task(i-1))) %to avoid same consecutive tasks
            if task(i) == 1                   %when task = 1,1
                task(i) = task(i)+1;
            else                              %when task = 2,2 || 3,3
                task(i) = task(i)-1;
            end
        end
        
        if i >= end_cond_cal %so it runs for all blocks
            % if condition reaches sufficient num of blocks, do alternative condition
            if num_cal(1) == end_cond_cal
                if num_cal(2)== end_cond_cal
                    task(i)= type_cal(3);
                else
                    task(i)= type_cal(2);
                end
            elseif num_cal(2) == end_cond_cal
                if num_cal(1)== end_cond_cal
                    task(i)= type_cal(3);
                else
                    task(i)= type_cal(1);
                end
            elseif num_cal(3) == end_cond_cal
                if num_cal(1)== end_cond_cal
                    task(i)= type_cal(2);
                else
                    task(i)= type_cal(1);
                end
            end
        end
        
        label = evt_value_cal{task(i)};
        tsk = cond_name_cal{task(i)};
        cue = {sprintf('BLOCK %d',i),sprintf(tsk),sprintf('PAUSE \n\nIn the next block %s.\nPress the spacebar to start...',tsk), ...
            sprintf('\n\nIn the next block %s.\n',tsk)};
        
        %PAUSE between blocks
        if mod(i,6) == 0 %do a pause period controled by the user every 6 blocks
            
            text(5,5,cue{3},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            sendEvent('relax','pause')
            waitforbuttonpress(); %pause period
            
        else
            
            text(5,5,cue{4},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            sendEvent('relax','pause')
            pause(2); %smaller pause period
            
        end
        clf; %clear screen
        
        for j = 1:num_trial_cal         %run trials for block i
            
            %block number i
            text(5,5,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            soundTest(dur_iti_cal); %iti period (beeps)
            
            cue_move = text(5,3,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            sendEvent('movement',label)
            pause(dur_trial_cal); %movement period
            
            sound_endtrl; % low beep to indicate end of trial
            delete(cue_move);
            pause(0.6) %to not overlap start and finish sounds
            
        end
        
        clf;
        % count number of blocks per condition
        if task(i)==type_cal(1)
            num_cal(1)=num_cal(1)+1;
        elseif task(i)==type_cal(2)
            num_cal(2)=num_cal(2)+1;
        else
            num_cal(3)=num_cal(3)+1;
        end
        
        task(i+1) = randi(cond_cal); %Uniformly distributed pseudorandom integers between 1 and number of conditions
        
    end
    
    text(0,6,goodbyetxt,'Color',txtColor,'FontSize',txtSize_wlc);
    axis([0 10 0 10]);
    set(gca,'visible','off');
    
    sendEvent('calibrate','end'); %end calibration phase
    
    pause(dur_trial_cal);
    close(fig)
    
end

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
waitforbuttonpress();
clf;

text(0,6,welcometxtII_2,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
waitforbuttonpress();
clf;

i = 1; %restart counter (used in part I)
task(i) = randi(cond); %Uniformly distributed pseudorandom integers between 1 and number of conditions

switch group
    
    case 1 %%%%%%%%%%%%%%%%%%%  sham robot control  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        text(0,6,welcometxtII_3_1,'Color',txtColor,'FontSize',txtSize_wlc);
        axis([0 10 0 10]);
        set(gca,'visible','off');
        waitforbuttonpress();
        clf;
        
        for i = 1:num_block
            
            task(i) = non_consec(i,task,end_cond,type,num);
            
            label = evt_value{task(i)};
            tsk = cond_name{task(i)};
            cue = {sprintf('BLOCK %d',i),sprintf(tsk),sprintf('PAUSE \n\nIn the next block %s.\nPress the spacebar to start...',tsk)};
            
            %PAUSE between blocks
            text(5,5,cue{3},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            sendEvent('relax','pause')
            waitforbuttonpress(); %pause period
            clf;
            
            points = 0; %counter for point system
            
            sendEvent('block','start');
            
            for j = 1:num_trial         %run trials for block i
                
                %block number i
                text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                drawnow;
                
                soundTest(dur_iti); %iti period (beeps)
                
                initgetwTime; %start var getwTime
                timeleft = dur_trial; %each trial starts with 5s
                trial_StartTime = getwTime(); %get current time
                state  = []; %current state of the newevents, empty between whiles to avoid processing incorrect events
                pred = 0; %reset decision values between trials
                prob = 0;
                
                sendEvent('trial','start');
                
                while(timeleft>0) %will run until trial time is over
                    
                    %%%%%%%%% receive classification outcome %%%%%%%%%%%%
                    
                    % wait for new prediction events to process *or* end of trial time
                    [events,state,nsamples,nevents] = buffer_newevents(buffhost,buffport,state,'classifier.prediction',[],timeleft*1000);
                    if ( isempty(events) )
                        fprintf('%d) no predictions!\n',nsamples);
                    else % if events to process
                        [ans,si]=sort([events.sample],'ascend'); % proc in *temporal* order, ans = the event; si = index in original matrix
                        % loop over received prediction events.
                        for ei=1:numel(events); %loop for size of events
                            ev=events(si(ei));% event to process
                            
                            pred = pred + ev.value; %accumulate decision values
                            
                            % now do something with the prediction...
                            prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                            %prob=prob./sum(prob); % convert to normalised probability (multinomial case)
                            
                            %if ( verb>=0 )
                            fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                            %end;
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    text_display; %display block number, type of task and current points
                    
                    %random outcome
                    outcome = randi(2);
                    
                    if strcmp(label,'rest') %in rest trials only give visual feed
                        if outcome == 1
                            pause(dur_feedback); %give some time between point display,
                            points = points + 1; %to avoid that rest receives much more feedback than abd
                            sendEvent('stimulus','feedback'); %need to send event?
                            clf;
                        end
                    else    %in abd trials also give feedback with robot
                        if outcome == 1
                            abductor_robot(angle,srl); %move to angle and return
                            points = points + 1;
                            sendEvent('stimulus','feedback'); %need to send event?
                            clf;
                        end
                    end
                    
                    text_display; %display block number, type of task and current points
                    
                    timeleft = dur_trial - (getwTime()-trial_StartTime);
                end
                sound_endtrl; %trial end beep
                clf;
                sendEvent('trial','end');
            end
            
            sendEvent('block','end');
            
            points_fdbck; %script to give motivational text in end of block
            
            text(5,5,feedtxt,'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            pause(dur_iti); %wait between blocks
            clf;
            
            % count number of blocks per condition
            if task(i)==type(1)
                num(1)=num(1)+1;
            elseif task(i)==type(2)
                num(2)=num(2)+1;
            end
            
            task(i+1) = randi(cond); %Uniformly distributed pseudorandom integers between 1 and number of conditions
        end
        
    case 2 %%%%%%%%%%%%%%%%%%%  visual SMR feedback  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        text(0,6,welcometxtII_3_2,'Color',txtColor,'FontSize',txtSize_wlc);
        axis([0 10 0 10]);
        set(gca,'visible','off');
        waitforbuttonpress();
        clf;
        
        for i = 1:num_block
            
            task(i) = non_consec(i,task,end_cond,type,num);
            
            label = evt_value{task(i)};
            tsk = cond_name{task(i)};
            cue = {sprintf('BLOCK %d',i),sprintf(tsk),sprintf('PAUSE \n\nIn the next block %s.\nPress the spacebar to start...',tsk)};
            
            %PAUSE between blocks
            text(5,5,cue{3},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            sendEvent('relax','pause')
            waitforbuttonpress(); %pause period
            clf;
            
            points = 0; %counter for point system
            
            sendEvent('block','start');
            
            for j = 1:num_trial         %run trials for block i
                
                %block number i
                text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                drawnow;
                
                soundTest(dur_iti); %iti period (beeps)
                
                initgetwTime; %start var getwTime
                timeleft = dur_trial; %each trial starts with 12s
                trial_StartTime = getwTime(); %get current time
                state  = []; %current state of the newevents, empty between whiles to avoid processing incorrect events
                pred = 0; %reset decision values between trials
                prob = 0;
                
                sendEvent('trial','start');
                
                while(timeleft>0) %will run until trial time is over
                    
                    %%%%%%%%% receive classification outcome %%%%%%%%%%%%
                    
                    % wait for new prediction events to process *or* end of trial time
                    [events,state,nsamples,nevents] = buffer_newevents(buffhost,buffport,state,'classifier.prediction',[],timeleft*1000);
                    if ( isempty(events) )
                        fprintf('%d) no predictions!\n',nsamples);
                    else % if events to process
                        [ans,si]=sort([events.sample],'ascend'); % proc in *temporal* order, ans = the event; si = index in original matrix
                        % loop over received prediction events.
                        for ei=1:numel(events); %loop for size of events
                            ev=events(si(ei));% event to process
                            
                            pred = pred + ev.value; %accumulate decision values
                            
                            % now do something with the prediction...
                            prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                            %prob=prob./sum(prob); % convert to normalised probability (multinomial case)
                            
                            %if ( verb>=0 )
                            fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                            %end;
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    text_display; %display block number, type of task and current points
                    
                    % feedback information...
                    % change in points only if confident in right class
                    if strcmp(label,'rest')==1
                        if prob >= thresh % 90% confident in positive class
                            points = points + 1;
                            sendEvent('stimulus','feedback'); %need to send event?
                            clf;
                        end
                    else
                        if prob <= 1-thresh % 90% confident in negative class
                            points = points + 1;
                            sendEvent('stimulus','feedback'); %need to send event?
                            clf;
                        end
                    end
                    
                    text_display; %display block number, type of task and current points
                    
                    timeleft = dur_trial - (getwTime()-trial_StartTime);
                    
                end
                sound_endtrl; %trial end beep
                clf;
                sendEvent('trial','end');
            end
            
            sendEvent('block','end');
            
            points_fdbck; %script to give motivational text in end of block
            
            text(5,5,feedtxt,'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            pause(dur_iti); %wait between blocks
            clf;
            
            % count number of blocks per condition
            if task(i)==type(1)
                num(1)=num(1)+1;
            elseif task(i)==type(2)
                num(2)=num(2)+1;
            end
            
            task(i+1) = randi(cond); %Uniformly distributed pseudorandom integers between 1 and number of conditions
        end
        
        
    case 3 %%%%%%%%%%%%%%%%%%%  active robot control  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        text(0,6,welcometxtII_3_1,'Color',txtColor,'FontSize',txtSize_wlc);
        axis([0 10 0 10]);
        set(gca,'visible','off');
        waitforbuttonpress();
        clf;
        
        for i = 1:num_block
            
            task(i) = non_consec(i,task,end_cond,type,num);
            
            label = evt_value{task(i)};
            tsk = cond_name{task(i)};
            cue = {sprintf('BLOCK %d',i),sprintf(tsk),sprintf('PAUSE \n\nIn the next block %s.\nPress the spacebar to start...',tsk)};
            
            %PAUSE between blocks
            text(5,5,cue{3},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            sendEvent('relax','pause')
            waitforbuttonpress(); %pause period
            clf;
            
            points = 0; %counter for point system
            
            sendEvent('block','start');
            
            for j = 1:num_trial         %run trials for block i
                
                %block number i
                text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                drawnow;
                
                soundTest(dur_iti); %iti period (beeps)
                
                initgetwTime; %start var getwTime
                timeleft = dur_trial; %each trial starts with 12s
                trial_StartTime = getwTime(); %get current time
                state  = []; %current state of the newevents, empty between whiles to avoid processing incorrect events
                pred = 0; %reset decision values between trials
                prob = 0;
                
                sendEvent('trial','start');
                
                while(timeleft>0) %will run until trial time is over
                    
                    %%%%%%%%% receive classification outcome?? %%%%%%%%%%%%
                    % wait for new prediction events to process *or* end of trial time
                    [events,state,nsamples,nevents] = buffer_newevents(buffhost,buffport,state,'classifier.prediction',[],timeleft*1000);
                    if ( isempty(events) )
                        fprintf('%d) no predictions!\n',nsamples);
                    else % if events to process
                        [ans,si]=sort([events.sample],'ascend'); % proc in *temporal* order, ans = the event; si = index in original matrix
                        % loop over received prediction events.
                        for ei=1:numel(events); %loop for size of events
                            ev=events(si(ei));% event to process
                            
                            pred = pred + ev.value; %accumulate decision values
                            
                            % now do something with the prediction...
                            prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                            %prob=prob./sum(prob); % convert to normalised probability (multinomial case)
                            
                            %if ( verb>=0 )
                            fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                            %end;
                        end
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    text_display; %display block number, type of task and current points
                    
                    % feedback information...
                    % change in points only if confident in right class
                    if strcmp(label,'rest')==1
                        if prob >= thresh % 90% confident in positive class(rest)
                            points = points + 1;
                            sendEvent('stimulus','feedback'); %need to send event?
                            clf;
                        end
                    else
                        if prob <= 1-thresh % 90% confident in negative class(abd)
                            abductor_robot(angle,srl); %move to angle and return to init position
                            points = points + 1;
                            sendEvent('stimulus','feedback'); %need to send event?
                            clf;
                        end
                    end
                    
                    text_display; %display block number, type of task and current points
                    
                    timeleft = dur_trial - (getwTime()-trial_StartTime);
                    
                end
                sound_endtrl; %trial end beep
                clf;
                sendEvent('trial','end');
            end
            
            sendEvent('block','end');
            
            points_fdbck; %script to give motivational text in end of block
            
            text(5,5,feedtxt,'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            pause(dur_iti); %wait between blocks
            clf;
            
            % count number of blocks per condition
            if task(i)==type(1)
                num(1)=num(1)+1;
            elseif task(i)==type(2)
                num(2)=num(2)+1;
            end
            
            task(i+1) = randi(cond); %Uniformly distributed pseudorandom integers between 1 and number of conditions
        end
        
end

sendEvent('testing','end'); % start continuous feedback phase

%save interesting variables
if group == 1 || group == 3
    endSrlPort(srl); %close serial por communication
    save(fullfile(cfgcls.pth_lab3,[cfgcls.sub '_info.mat']),'curr_points','points_abd','points_rest','task','angle')
else
    save(fullfile(cfgcls.pth_lab3,[cfgcls.sub '_info.mat']),'curr_points','points_abd','points_rest','task')
end

text(0,6,goodbyetxtII,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
drawnow;

pause(dur_iti);
close(fig)

