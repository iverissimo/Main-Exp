%% Author: Ines Verissimo
%% Visual display for main experiment
% 2 conditions (ABD,REST), randomized
% 3 groups: visual SMR feedback, active robot-control, sham robot-control
% 64ch EEG + 8EXT (4EOG + 4 EMG)
% before starting check values of txtSize_wlc,txtSize_cue,
% num_trial, num_block
clear all; close all;

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
            
            delete(cue_move);
            
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
        cue = {sprintf('BLOCK %d',i),sprintf(tsk),sprintf('PAUSE \n\nIn the next block %s.\nPress the spacebar to start...',tsk)};
        
        %PAUSE between blocks
        text(5,5,cue{3},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
        axis([0 10 0 10]);
        set(gca,'visible','off');
        drawnow;
        
        sendEvent('relax','pause')
        waitforbuttonpress(); %pause period
        clf;
        
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
            
            delete(cue_move);
            
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
    
%     [srl] = initSrlPort(comport); %open arduino serial port
%     robot_rest(srl); %run it once just so it goes to initial position
    
    ang_calib; %launch gui for to select best angle for participant
    
    % get the handle to the GUI and wait for it to be closed
    hGui = findobj('Tag','tformChoiceGui');
    waitfor(hGui);
    
     % continue with script
    while (angle < 0 )
        angle = input('Specify angle for robot movement (max 100): '); %angle for robot max position
        if (ang_min <= angle) && (angle <= ang_max)
            angle = 180 - angle; %Want it to move 100, but actual motor position is 80
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
            if (i > 2)&&(task(i) == task(i-1))&& (task(i-2) == task(i-1))  %to avoid 3xconsecutive tasks
                if task(i) == 1                   %when task = 1,1,1
                    task(i) = task(i)+1;
                else                              %when task = 2,2,2
                    task(i) = task(i)-1;
                end
            end
            
            
            if i >= end_cond && num(1) == end_cond
                % if condition reaches sufficient num of blocks, do alternative condition
                task(i)= type(2);
            end
            
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
                inc = 1;
                outcome = zeros(1,round(dur_trial/dur_feedback));
                
                sendEvent('trial','start');
                
                while(timeleft>0) %will run until trial time is over
                    
                    text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                    axis([0 10 0 10]);
                    set(gca,'visible','off'); %block number
                    
                    cue_move = text(5,6,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                    axis([0 10 0 10]);
                    set(gca,'visible','off'); %type of movement
                    
                    drawnow;
                    
                    %random outcome
                    outcome(inc) = randi(2);
                    
                    if (inc > 2)&&(outcome(inc) == outcome(inc-1))&& (outcome(inc-2) == outcome(inc-1))  %to avoid 3xconsecutive feedbacks
                        if outcome(inc) == 1                   %when task = 1,1,1
                            outcome(inc) = outcome(inc)+1;
                        else                              %when task = 2,2,2
                            outcome(inc) = outcome(inc)-1;
                        end
                    end
                    
                    if outcome(inc) == 1
                        %abductor_robot(angle,srl); %move to angle and return
                        robot_abd(srl,dur_feedback);
                    else
                        disp('No movement.') %no feedback but
                        pause(dur_feedback); %wait 1.5s anyway
                    end
                    
                    clf;
                    timeleft = dur_trial - (getwTime()-trial_StartTime);
                    
                    if timeleft < dur_feedback
                        break; %break while loop if no more time for new feedback
                    end        %to avoid longer trials than expected
                    inc = inc+1; %increment for outcome counter
                end
                sendEvent('trial','end');
            end
            
            sendEvent('block','end');
            
            pause(dur_iti); %wait 4.5s between blocks (to avoid corrupting classification of next block)
            
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
        curr_points = zeros(1,num_block);
        
        for i = 1:num_block
            if (i > 2)&&(task(i) == task(i-1))&& (task(i-2) == task(i-1))  %to avoid 3xconsecutive tasks
                if task(i) == 1                   %when task = 1,1,1
                    task(i) = task(i)+1;
                else                              %when task = 2,2,2
                    task(i) = task(i)-1;
                end
            end
            
            % if condition reaches sufficient num of blocks, do alternative condition
            if i >= end_cond && num(1) == end_cond
                task(i)= type(2);
            elseif i >= end_cond && num(2) == end_cond
                task(i)= type(1);
            end
            
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
                    % feedback information...
                    %points = points + 5*prob; % change in points is weighted by class probs
                    % change in points only if confident in right class
                    if prob >= thresh %%&& (mod(numel(events),4)==0)% if reach thresh and
                        points = points + 1; %number of events multiple of 4 (4Hz prediction rate) - give prediction every second
                        sendEvent('stimulus','feedback'); %need to send event?
                    end
                    
                    text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                    axis([0 10 0 10]);
                    set(gca,'visible','off');
                    
                    cue_move = text(5,6,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                    axis([0 10 0 10]);
                    set(gca,'visible','off');
                    
                    feedtxt = sprintf('Current score is %0.1f.',points);
                    text(5,4,feedtxt,'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                    axis([0 10 0 10]);
                    set(gca,'visible','off');
                    drawnow;
                    
                    clf;
                    timeleft = dur_trial - (getwTime()-trial_StartTime);
                    
                end
                sendEvent('trial','end');
            end
            
            sendEvent('block','end');
            
            curr_points(i) = points;
            
            if i>1 % motivational text between blocks
                if   curr_points(i)>round(dur_trial*num_trial/2) && (curr_points(i)-curr_points(i-1)>=0)
                    motivtxt = 'Good job!';
                    
                elseif (curr_points(i)-curr_points(i-1)>=0)
                    motivtxt = 'Getting there, you can do it!';
                else
                    motivtxt = 'You can do better.';
                end
                
                feedtxt = sprintf('Your score is %0.1f.\n\n%s',points,motivtxt);
            else
                feedtxt = sprintf('Your score is %0.1f.',points);
            end
            
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
            if (i > 2)&&(task(i) == task(i-1))&& (task(i-2) == task(i-1))  %to avoid 3xconsecutive tasks
                if task(i) == 1                   %when task = 1,1,1
                    task(i) = task(i)+1;
                else                              %when task = 2,2,2
                    task(i) = task(i)-1;
                end
            end
            
            
            if i >= end_cond && num(1) == end_cond
                % if condition reaches sufficient num of blocks, do alternative condition
                task(i)= type(2);
            end
            
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
            
            sendEvent('block','start');
            
            for j = 1:num_trial         %run trials for block i
                
                %block number i
                text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                drawnow;
                
                soundTest(dur_iti); %iti period (beeps)
                
                sendEvent('movement',label)
                
                initgetwTime; %start var getwTime
                timeleft = dur_trial; %each trial starts with 5s
                trial_StartTime = getwTime(); %get current time
                state  = []; %current state of the newevents
                
                sendEvent('trial','start');
                
                while(timeleft>0) %will run until trial time is over
                    
                    %%%%%%%%% receive classification outcome?? %%%%%%%%%%%%
                    %%% make a function that matchs events of interest %%%%
                    %%%(event from classifier) and returns a value that can
                    %%% be used to give feedback %%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                    axis([0 10 0 10]);
                    set(gca,'visible','off'); %block number
                    
                    cue_move = text(5,6,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                    axis([0 10 0 10]);
                    set(gca,'visible','off'); %type of movement
                    
                    drawnow;
                    
                    outcome = 3; X = 2; %just for code to run
                    if outcome >= X
                        abductor_robot(angle,srl); %move to angle and return to init position
                    else
                        disp('No movement.') %no feedback but
                        pause(dur_feedback); %wait 1.5s anyway
                    end
                    
                    clf;
                    timeleft = dur_trial - (getwTime()-trial_StartTime);
                    
                    if timeleft < dur_feedback
                        break; %break while loop if no more time for new feedback
                    end        %to avoid longer trials than expected
                end
                sendEvent('trial','end');
            end
            
            sendEvent('block','end');
            
            pause(dur_iti); %wait 3s between blocks (to avoid corrupting classification of next block)
            
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

if group == 1 || group == 3
    endSrlPort(srl); %close serial por communication
else
    sub = input('Subject: ','s');
    save([sub '_info.mat'], 'curr_points','task')
end

text(0,6,goodbyetxtII,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
drawnow;

pause(dur_iti);
close(fig)

