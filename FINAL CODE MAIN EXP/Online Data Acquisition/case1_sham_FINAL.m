
%case 3 version 2
%new script to make it easier to modify each group

text(0,6,welcometxtII_3_1,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
press_button;
%waitforbuttonpress();
clf;

block0; %do example block

text(0,6,welcometxtII_5,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
press_button;
%waitforbuttonpress();
clf;

for i = 1:num_block
    
    %PAUSE between blocks
    text(5,5,sprintf('PAUSE \n\nPress button 1 to start...'),...
        'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
    axis([0 10 0 10]);
    set(gca,'visible','off');
    drawnow;
    
    sendEvent('relax','pause')
    press_button; %pause period
    %waitforbuttonpress();
    clf;
    
    points = 0; %counter for point system, starts with 0 for each block
    
    sendEvent('block','start');
    
    for j = 1:num_trial         %run trials for block i
        
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
        
        sendEvent('baseline','start');
        
        while(timeleft>0) %will run until baseline trial time is over
            
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
                    
                    pred=pred+randn(1)*.1;

                    % now do something with the prediction...
                    prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                    
                    fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                    
                end
            end
                        
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{2}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Current score is %0.1f.',points),...
                'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
            %random outcome
            % if baseline in robot conditions
            %outcome = rand();
            
            % feedback information...
            % change in points only if confident in right class
            
            if prob(1) >= thresh %outcome > rnd_thresh
                pause(dur_feedback); %give some time between point display,
                points = points + 1;
                sendEvent('feedback',pred(1)); %send event with the feedback and corresponding dv
                clf;
            end
            
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{2}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Current score is %0.1f.',points),...
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
        
        sendEvent('move','start');
        
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
                    
                    pred=pred+randn(1)*.1;
                    
                    % now do something with the prediction...
                    prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                    
                    fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{1}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Current score is %0.1f.',points),...
                'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            drawnow;
            
%             %random outcome
%             outcome = rand();
            
            % feedback information...
            % change in points only if confident in right class
            if prob(1) <= 1-thresh %outcome > rnd_thresh
                abductor_robot(angle,srl); %move to angle and return to init position
                points = points + 1;
                sendEvent('feedback',pred(1)); %send event with the feedback and corresponding dv
                clf;
            end
            
            text(5,8,sprintf('BLOCK %d',i),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,6,sprintf(cond_name{1}),'Color',txtColor,...
                'FontSize',txtSize_cue,'HorizontalAlignment','center');
            axis([0 10 0 10]);
            set(gca,'visible','off');
            
            text(5,4,sprintf('Current score is %0.1f.',points),...
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
    
    text(5,5,feedtxt,'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
    axis([0 10 0 10]);
    set(gca,'visible','off');
    drawnow;
    
    pause(dur_iti); %wait between blocks
    clf;
end
