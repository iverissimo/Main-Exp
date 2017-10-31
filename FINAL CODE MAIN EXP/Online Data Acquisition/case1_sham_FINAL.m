
%case 1 version 2
%new script to make it easier to modify each group

text(0,6,welcometxtII_3_1,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
press_button;
clf;

block0; %do example block

text(0,6,welcometxtII_5,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
press_button;
clf;

num = 1; %counter for incrementing ROC vector
p = 1; % counter for seeing timming for changing ROC value

for i = 1:num_block
    
    %PAUSE between blocks
    text(5,5,sprintf('PAUSE \n\nPress button 1 to start...'),...
        'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
    axis([0 10 0 10]);
    set(gca,'visible','off');
    drawnow;
    
    sendEvent('relax','pause')
    press_button; %pause period
    clf;
    
    points = 0; %counter for point system, starts with 0 for each block
    
    sendEvent('block','start');
    
    for j = 1:num_trial         %run trials for block i
        
        %fixation cross
        plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','w');
        axis([0 10 0 10]);
        set(gca,'visible','off');
        
        %block number i
        text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
            'FontSize',txtSize_cue,'HorizontalAlignment','center');
        axis([0 10 0 10]);
        set(gca,'visible','off');
        
        drawnow;
        
        soundTest(dur_iti); %iti period (beeps)
        
        sendEvent('trial','start');
        
        %%%%%% Baseline period %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        initgetwTime; %start var getwTime
        timeleft = dur_bl; %BL trial duration
        trial_StartTime = getwTime(); %get current time
        state  = []; %current state of the newevents, empty between whiles to avoid processing incorrect events
        pred = 0; %reset decision values between trials
        prob = 0;
        num_dv = 1; %only initialize in beggining of trial!!!!
        givefeed_time = getwTime(); %get current time
        
        sendEvent('baseline','start');
        
        while(timeleft>0) %will run until baseline trial time is over
            
            %%%%%%%%% receive classification outcome %%%%%%%%%%%%
            
            if (getwTime()-givefeed_time >= 1/4) %give predictions at 4Hz rate
                
                if num_dv > size(cfgcls.sham.dv_base{i,j},1)
                    warning('Max dv vector value was surpassed')
                else
                    pred = pred + cfgcls.sham.dv_base{i,j}(num_dv,1); %accumulate decision values
                    num_dv = num_dv +1;
                end
                
                % now do something with the prediction...
                prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                
                fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                
                %%%%%%% put recalc ROC threshold here %%%%%%%%%%%%%%%%%%%%%%%%%%
                p = p + 1; %increment position
                
                if p >= num_pred
                    if num > numel(cfgcls.sham.dv_ROCthresh)
                        thresh_dv = cfgcls.sham.dv_ROCthresh(numel(cfgcls.sham.dv_ROCthresh));
                        warning('Max ROC dv vector value was surpassed')
                    else
                        thresh_dv = cfgcls.sham.dv_ROCthresh(num);
                    end
                    
                    thresh = 1./(1+exp(-thresh_dv)); % convert from dv to probability (logistic transformation)
                    fprintf('The selected threshold is dv: %s or prob: %s\n',mat2str(thresh_dv,3),mat2str(thresh,3));
                    
                    p = 1;
                    num = num + 1;
                end
                
                givefeed_time = getwTime(); %restart time counter
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %fixation cross
            plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','g');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{2}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Score %0.1f',points),...
                'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            % feedback information...
            % change in points only if confident in right class
            
            if prob(1) >= thresh
                pause(dur_feedback); %give some time between point display,
                points = points + 1;
                sendEvent('feedback',pred(1)); %send event with the feedback and corresponding dv
                clf;
            end
            
            %fixation cross
            plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','g');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{2}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Score %0.1f',points),...
                'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            timeleft = dur_bl - (getwTime()-trial_StartTime);
            
        end
        
        if j>1
            bl_points(i,j) = points - (bl_points(i,j-1)+abd_points(i,j-1));
        else
            bl_points(i,j) = points; %baseline points for block i
        end
        
        sendEvent('baseline','end');
        sound_endtrl; %trial end beep
        clf;
        
        %fixation cross
        plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','w');
        axis([0 10 0 10]);
        set(gca,'visible','off');
        
        text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
            'FontSize',txtSize_cue,'HorizontalAlignment','center');
        axis([0 10 0 10]);
        set(gca,'visible','off');
        drawnow;
        
        pause(dur_feedback); %pause 1.5 second between non move and move
        
        %%%%%%%%%%%%%%%% Move period %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        initgetwTime; %start var getwTime
        timeleft = dur_trial; %each trial starts with 12s
        trial_StartTime = getwTime(); %get current time
        state  = []; %current state of the newevents, empty between whiles to avoid processing incorrect events
        pred = 0; %reset decision values between trials
        prob = 0;
        givefeed_time = getwTime(); %get current time
        
        sendEvent('move','start');
        
        while(timeleft>0) %will run until trial time is over
            
            %%%%%%%%% receive classification outcome %%%%%%%%%%%%
            
            % wait for new prediction events to process *or* end of trial time
            if (getwTime()-givefeed_time >= 1/4) %give predictions at 4Hz rate
                
                if num_dv > size(cfgcls.sham.dv_move{i,j},1)
                    warning('Max dv vector value was surpassed')
                else
                    pred = pred + cfgcls.sham.dv_move{i,j}(num_dv,1); %accumulate decision values
                    num_dv = num_dv +1;
                end
                
                % now do something with the prediction...
                prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                
                fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                
                %%%%%%% put recalc ROC threshold here %%%%%%%%%%%%%%%%%%%%%%%%%%
                p = p + 1; %increment position
                
                if p >= num_pred
                    if num > numel(cfgcls.sham.dv_ROCthresh)
                        thresh_dv = cfgcls.sham.dv_ROCthresh(numel(cfgcls.sham.dv_ROCthresh));
                        warning('Max ROC dv vector value was surpassed')
                    else
                        thresh_dv = cfgcls.sham.dv_ROCthresh(num);
                    end
                    
                    thresh = 1./(1+exp(-thresh_dv)); % convert from dv to probability (logistic transformation)
                    fprintf('The selected threshold is dv: %s or prob: %s\n',mat2str(thresh_dv,3),mat2str(thresh,3));
                    
                    p = 1;
                    num = num + 1;
                end
                
                givefeed_time = getwTime(); %restart time counter
            end
            
            %fixation cross
            plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','g');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{1}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Score %0.1f',points),...
                'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            % feedback information...
            % change in points only if confident in right class
            if prob(1) <= 1-thresh
                abductor_robot(angle,srl); %move to angle and return to init position
                points = points + 1;
                sendEvent('feedback',pred(1)); %send event with the feedback and corresponding dv
                clf;
            end
            
            %fixation cross
            plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','g');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{1}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Score %0.1f',points),...
                'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            timeleft = dur_trial - (getwTime()-trial_StartTime);
            
        end
        
        abd_points(i,j) = points - bl_points(i,j);
        
        sound_endtrl; %trial end beep
        clf;
        sendEvent('move','end');
        sendEvent('trial','end');
        %fixation cross
        plot(5,5,'+','MarkerSize',45,'LineWidth',5,'Color','w');
        axis([0 10 0 10]);
        set(gca,'visible','off');
        %block number i
        text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
            'FontSize',txtSize_cue,'HorizontalAlignment','center');
        axis([0 10 0 10]);
        set(gca,'visible','off');
        pause(dur_feedback); %pause 1.5 second so beeps don't overlap
    end
    
    sendEvent('block','end');
    
    curr_points(i) = points;
    
    if i>1 % motivational text between blocks
        if   curr_points(i)>round((dur_trial+dur_bl)*num_trial/2) && (curr_points(i)-curr_points(i-1)>=0)
            motivtxt = 'Good job!'; %if more than 1/2 the total amount of points && more than previous block
            
        elseif (curr_points(i)-curr_points(i-1)>=0) %if more points than previous block
            motivtxt = 'Getting there, you can do it!';
        else
            motivtxt = 'You can do better.';
        end
        
        feedtxt = sprintf('Your score is %0.1f.\n\n%s',points,motivtxt);
    else
        feedtxt = sprintf('Your score is %0.1f.',points);
    end
    
    clf;
    pause(1);
    
    text(5,5,feedtxt,'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
    axis([0 10 0 10]);
    set(gca,'visible','off');
    drawnow;
    
    pause(dur_iti); %wait between blocks
    clf;
end
