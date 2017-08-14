
% script for block0
% example block, to try out task before actual experiment starts

text(0,6,welcometxtII_4,'Color',txtColor,'FontSize',txtSize_wlc);
axis([0 10 0 10]);
set(gca,'visible','off');
press_button;
clf;

%PAUSE between blocks
text(5,5,sprintf('PAUSE \n\nPress button 1 to start...'),...
    'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
axis([0 10 0 10]);
set(gca,'visible','off');
drawnow;

sendEvent('relax','pause')
press_button;
clf;

points = 0; %counter for point system, starts with 0 for each block

sendEvent('example','start');

for j = 1:num_trial         %run trials for block i
    
    %block number i
    text(5,8,sprintf('BLOCK 0'),'Color',txtColor,...
        'FontSize',txtSize_cue,'HorizontalAlignment','center');
    axis([0 10 0 10]);
    set(gca,'visible','off');
    drawnow;
    
    soundTest(dur_iti); %iti period (beeps)
        
    %%%%%% Baseline period %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    initgetwTime; %start var getwTime
    timeleft = dur_bl; %BL trial duration
    trial_StartTime = getwTime(); %get current time
    state  = []; %current state of the newevents, empty between whiles to avoid processing incorrect events
    pred = 0; %reset decision values between trials
    prob = 0;
        
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
                
                % now do something with the prediction...
                prob = 1./(1+exp(-pred)); % convert from dv to probability (logistic transformation)
                
                fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
                
            end
        end
        
        text(5,8,sprintf('BLOCK 0'),'Color',txtColor,...
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
        
        % feedback information...
        % change in points only if confident in right class
        if group == 1 %sham
            outcome = prob(1)+ randn(1)*.1; %random outcome
            if outcome >= thresh
                pause(dur_feedback); %give some time between point display,
                points = points + 1;
                clf;
            end
        else % active || visual
            if prob(1) >= thresh % 90% confident in positive class [rest]
                pause(dur_feedback); %give some time between point display,
                points = points + 1;
                clf;
            end
        end
        
        text(5,8,sprintf('BLOCK 0'),'Color',txtColor,...
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
    
    sound_endtrl; %trial end beep
    clf;
    
    text(5,8,sprintf('BLOCK 0'),'Color',txtColor,...
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
                
                fprintf('dv:');fprintf('%5.4f ',pred);fprintf('\t\tProb:');fprintf('%5.4f ',prob);fprintf('\n');
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        text(5,8,sprintf('BLOCK 0'),'Color',txtColor,...
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
        
        % feedback information...
        % change in points only if confident in right class
        if group == 1 %sham
            outcome = prob(1)+ randn(1)*.1; %random outcome
            if outcome <= 1-thresh  % 90% confident in negative class [abd]
                abductor_robot(angle,srl); %move to angle and return to init position
                points = points + 1;
                clf;
            end
        else %active || visual
            if prob(1) <= 1-thresh % 90% confident in negative class [abd]
                if group == 3 %active
                    abductor_robot(angle,srl); %move to angle and return to init position
                else %visual
                    pause(dur_feedback); %give some time between point display
                end
                points = points + 1;
                clf;
            end
        end
        
        text(5,8,sprintf('BLOCK 0'),'Color',txtColor,...
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
    sound_endtrl; %trial end beep
    clf;
    pause(dur_feedback); %pause 1.5 second so beeps don't overlap
    
end

sendEvent('example','end');

text(5,5,sprintf('Your score is %0.1f.',points),...
    'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
axis([0 10 0 10]);
set(gca,'visible','off');
drawnow;

pause(dur_iti); %wait between blocks
clf;
