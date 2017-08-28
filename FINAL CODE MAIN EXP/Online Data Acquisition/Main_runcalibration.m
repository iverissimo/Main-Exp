
% Calibration Phase
% script to run calibration part

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
    
    skipintro = -1; %just to run while loop
    while (skipintro < 0)
        skipintro = input('Skip instructions? \n1- Yes; 0 - No. \nAnswer: ');
        if (skipintro == 1 || skipintro == 0)
            break;
        else
            disp('Option not available.')
            skipintro = -1;
        end
    end
    
    sendEvent('startPhase.cmd','calibrate'); %start calibration phase processing in startSigProcBuffer
    
    % Welcome text
    fig = figure(2);
    set(fig,'units','pixels','MenuBar','none','color',[0 0 0]);
    
    text(0,6,welcometxt1,'Color',txtColor,'FontSize',txtSize_wlc);
    axis([0 10 0 10]);
    set(gca,'visible','off');
    
    %added this so I have time to maximize figure in subjects monitor,
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
    
    if skipintro ~= 1
        
        text(0,6,welcometxt2,'Color',txtColor,'FontSize',txtSize_wlc);
        axis([0 10 0 10]);
        set(gca,'visible','off');
        press_button;
        
        soundTest(dur_iti_cal);
        pause(1)
        
        clf;
        
        text(0,6,welcometxt3,'Color',txtColor,'FontSize',txtSize_wlc);
        axis([0 10 0 10]);
        set(gca,'visible','off');
        press_button;
        clf;
        
        %instructions loop
        for i = 1:cond_cal
            
            tsk = cond_name_cal{i}; %task for condition i
            cue = {sprintf('BLOCK %d',i),sprintf(tsk)};
            
            if i == 2  %toe flexion explanation
                
                text(0,6,welcometxt4,'Color',txtColor,'FontSize',txtSize_wlc);
                axis([0 10 0 10]);
                set(gca,'visible','off');
                press_button;
                clf;
                
            elseif i == 3 %rest explanation
                
                text(0,6,welcometxt5,'Color',txtColor,'FontSize',txtSize_wlc);
                axis([0 10 0 10]);
                set(gca,'visible','off');
                press_button;
                clf;
                
            end
            
            for t = 1:num_trial_cal
                %fixation cross
                plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','w');
                set(gca,'visible','off');
                
                %show block number
                text(5,6,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                
                soundTest(dur_iti_cal); %iti period (beeps)
                
                %fixation cross
                plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','g');
                set(gca,'visible','off');
                
                %show block number
                text(5,6,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                
                %show cue = task for the condition
                cue_move = text(5,4,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                
                sendEvent('example', evt_value_cal{i}) %event type example, to differ from type movement (of interest)
                pause(dur_trial_cal); %movement period
                
                sound_endtrl; % low beep to indicate end of trial
                delete(cue_move);
                %fixation cross
                plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','w');
                set(gca,'visible','off');
                
                %show block number
                text(5,6,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
                axis([0 10 0 10]);
                set(gca,'visible','off');
                pause(0.6) %to not overlap start and finish sounds
            end
            
            clf;
        end
        
        text(0,6,welcometxt6,'Color',txtColor,'FontSize',txtSize_wlc);
        axis([0 10 0 10]);
        set(gca,'visible','off');
        press_button;
        clf;
    else
        text(0,6,welcometxt7,'Color',txtColor,'FontSize',txtSize_wlc);
        axis([0 10 0 10]);
        set(gca,'visible','off');
        press_button;
        clf;
    end
    
    %%%%%%%%%%%%%%%%%%%%% start running blocks %%%%%%%%%%%%%%%%%%%%%
    
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
        cue = {sprintf('BLOCK %d',i),sprintf(tsk),sprintf('PAUSE \n\nIn the next block %s.\nPress button 1 to start...',tsk), ...
            sprintf('\n\nIn the next block %s.\n',tsk)};
        
        %PAUSE between blocks
        if mod(i,6) == 0 %do a pause period controled by the user every 6 blocks
            
            text(5,5,cue{3},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            sendEvent('relax','pause')
            press_button; %pause period
        else
            
            text(5,5,cue{4},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            sendEvent('relax','pause')
            pause(3); %smaller pause period
            
        end
        clf; %clear screen
        
        for j = 1:num_trial_cal         %run trials for block i
            
            %fixation cross
            plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','w');
            set(gca,'visible','off');
            
            %block number i
            text(5,6,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            soundTest(dur_iti_cal); %iti period (beeps)
            
            %fixation cross
            plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','g');
            set(gca,'visible','off');
            
            %block number i
            text(5,6,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            %show cue = task for the condition
            cue_move = text(5,4,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            sendEvent('movement',label)
            pause(dur_trial_cal); %movement period
            
            sound_endtrl; % low beep to indicate end of trial
            delete(cue_move);
            %fixation cross
            plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','w');
            set(gca,'visible','off');
            
            %block number i
            text(5,6,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
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
