function [ind_starttest,hdr] = analysis_mainpredvalues_v2(all_events,hdr,calib,doplot,pc,subjnum,pth)

% script to select actual test data (from main phase)
% define start of trial, block, iti, etc
% and plot decision values obtained by the classifier

if calib == 1
    fs = hdr.fsample;
    hdr.label = hdr.labels;
else %sample frequency, because hdr.Fs/FSample changes names when running calib data
    fs = hdr.Fs;
end

mi_starttest = matchEvents(all_events,{'startPhase.cmd'},{'contfeedback'}); %find beginnig of testing phase
ind_starttest = find(mi_starttest); %find index
mi_endtest = matchEvents(all_events,{'testing'},{'end'}); %find end of testing phase
ind_endtest = find(mi_endtest); %find index
%clear mi_starttest mi_endtest; %free up system memory

if doplot == 1 %do plots
    
    %all events in the continuous feedback phase (removed 'start' and 'end' phase events)
    test_events = all_events(ind_starttest(length(ind_starttest))+2:ind_endtest(length(ind_endtest))-1);
    
    mi_extra = matchEvents(test_events,{'CMS_IN_RANGE' 'BATTERY' 'response'}); %find events not relevant for plotting
    ind_extra = find(mi_extra); %clear mi_extra;
    
    k = 1;
    h = 1;
    %remove battery and cms events, leave rest
    for j = 1:length(test_events)
        if  k <= length(ind_extra) && ind_extra(k) == j %skip these
            k = k+1;
        else
            test_devents(h) = test_events(j); %save
            h = h+1;
        end
    end
    
    % now test_devents has the relevant markers for the experiment duration
    pred_events = ft_filter_event(test_devents,'type','classifier.prediction'); %only prediction events
    
    for k = 1:length(pred_events)
        dv(k) = pred_events(k).value(1); %decision values
        smp(k) = pred_events(k).sample; %prediction samples
    end
    
    tmp = (smp - smp(1))./fs; %time, to plot - relative to beginning of prediction values
    
    st_trl_events = ft_filter_event(test_devents,'type','trial','value','start'); %only events for trial start
    en_trl_events = ft_filter_event(test_devents,'type','trial','value','end'); %only events for trial end
    st_blk_events = ft_filter_event(test_devents,'type','block','value','start'); %only events for block start
    en_blk_events = ft_filter_event(test_devents,'type','block','value','end'); %only events for block end
    st_bl_events = ft_filter_event(test_devents,'type','baseline','value','start'); %only events for baseline start
    en_bl_events = ft_filter_event(test_devents,'type','baseline','value','end'); %only events for baseline end
    st_mov_events = ft_filter_event(test_devents,'type','move','value','start'); %only events for move start
    en_mov_events = ft_filter_event(test_devents,'type','move','value','end'); %only events for move end
    
    figure %decision value plot, marking the moments where trial started
    plot(tmp,dv)
    title('DV - whole window')
    xlabel('Time (s)')
    ylabel('Decision Values')
    xlim([0 tmp(length(tmp))]);
    saveas(1, fullfile(pth, sprintf('all_dv')), 'png');
    close all;
    
    iti_events = ft_filter_event(test_devents,'type','relax','value','iti'); %only ITI events for main phase
    pause_events = ft_filter_event(test_devents,'type','relax','value', 'pause'); %only ITI events for main phase
    
    % all timepoints relative to 1st block event - Real beginning of experiment
    st_blktmp = timepoints(st_blk_events,st_blk_events(1).sample,fs);%start block timepoints
    en_blktmp = timepoints(en_blk_events,st_blk_events(1).sample,fs);%end block timepoints
    st_trltmp = timepoints(st_trl_events,st_blk_events(1).sample,fs);%start trial timepoints
    en_trltmp = timepoints(en_trl_events,st_blk_events(1).sample,fs);%end trial timepoints
    st_bltmp = timepoints(st_bl_events,st_blk_events(1).sample,fs);%start trial timepoints
    en_bltmp = timepoints(en_bl_events,st_blk_events(1).sample,fs);%end trial timepoints
    st_movtmp = timepoints(st_mov_events,st_blk_events(1).sample,fs);%start trial timepoints
    en_movtmp = timepoints(en_mov_events,st_blk_events(1).sample,fs);%end trial timepoints
    ititmp = timepoints(iti_events,st_blk_events(1).sample,fs); %iti timepoints
    ititmp = ititmp(4:end); %remove first 3 events, from example part (block0)
    
    for k = 1:length(test_devents)
        test_smp(k) = test_devents(k).sample; %all samples for test phase
    end
    
    ind_st_test = find(test_smp == st_blk_events(1).sample); %index of start of real test
    ind_st_test = ind_st_test+2;%+2 to be real prediction
    ind_en_test = find(test_smp == en_blk_events(length(en_blk_events)).sample); %index of end of real test
    ind_en_test = ind_en_test(length(ind_en_test))-2;%-2 to be real prediction
    pred_events = ft_filter_event(test_devents(ind_st_test:ind_en_test),'type','classifier.prediction'); %only prediction events
    
    for k = 1:length(pred_events) %with new window of pred events
        dv(k) = pred_events(k).value(1); %decision values
        smp(k) = pred_events(k).sample; %prediction samples
    end
    tmp = (smp - smp(1))./fs; %time, to plot
    
    k = 1;
    for j=1:length(en_blktmp)
        figure(1)
        st = st_trltmp(k:k+2); st_tm(j,1:3) =  st;%start trial vector (num blocks x num trials)
        it = ititmp(k:k+2); it_tm(j,1:3) =  it;%iti vector (num blocks x num iti)
        stbl = st_bltmp(k:k+2); stbl_tm(j,1:3) = stbl;%start baseline vector (num blocks x num trials)
        stmov = st_movtmp(k:k+2); stmov_tm(j,1:3) = stmov;%start baseline vector (num blocks x num trials)
        
        if j == 1
            siz = round(en_blktmp(1)*4);
            tmp_bl(j,1:siz)= tmp(1:round(en_blktmp(1)*4)); %all time values in one block, relative to beginning of 1st block
            dv_bl(j,1:siz) = dv(1:round(en_blktmp(1)*4)); %all dv in one block, relative to beginning of 1st block
            plot(tmp_bl(j,:),dv_bl(j,:),'*')
            %plot(tmp(1:round(en_blktmp(1)*4)),dv(1:round(en_blktmp(1)*4)),'*')
            ylim([min(dv) max(dv)])
            xlim([tmp(1) tmp(round(en_blktmp(1)*4))])
        else
            siz = round(en_blktmp(j)*4)-round(st_blktmp(j)*4)+1;
            tmp_bl(j,1:siz)= tmp(round(st_blktmp(j)*4):round(en_blktmp(j)*4));%all time values in one block, relative to beginning of 1st block
            dv_bl(j,1:siz) = dv(round(st_blktmp(j)*4):round(en_blktmp(j)*4));%all dv values in one block, relative to beginning of 1st block
            plot(tmp_bl(j,:),dv_bl(j,:),'*')
            ylim([min(dv) max(dv)])
            %plot(tmp(round(st_blktmp(j)*4):round(en_blktmp(j)*4)),dv(round(st_blktmp(j)*4):round(en_blktmp(j)*4)),'*')
            if j == size(dv_bl,1)
                xlim([tmp(round(st_blktmp(j)*4)) tmp(round(st_blktmp(j)*4))+85]) %each block is 49.5s = 99 inc in tmp vector
            else
                xlim([tmp(round(st_blktmp(j)*4)) tmp(round(en_blktmp(j)*4))])
            end
        end
        hold on
        %r = plot([st(:) st(:)],get(gca,'ylim'),'r'); %trial start
        r = plot([stbl(:) stbl(:)],get(gca,'ylim'),'r'); %baseline start
        hold on
        g = plot([it(:) it(:)],get(gca,'ylim'),'c--'); %iti
        hold on
        mv = plot([stmov(:) stmov(:)],get(gca,'ylim'),'m');%move start
        legend([r(1) g(1) mv(1)],'baseline start','iti','move start');
        hold on
        plot(get(gca,'xlim'), [0 0],'k');
        bl = sprintf('DV for Block %d',j);
        title(bl)
        xlabel('Time (s)')
        ylabel('Decision Values')
        saveas(gca, fullfile(pth, sprintf('dv_block_%d',j)), 'png');
        close all;
        k = k + 3;
    end
    
    %plot points per class
    w = -1; %just to run while loop
    while (w < 0)
        w = input('1-Visual, 2-Active, 3-Sham \nWhat type of task? ');
        if (w == 1 || w == 2 || w == 3)
            break;
        else
            disp('Option not available.')
            w = -1;
        end
    end
    
    
    if pc == 1
        pth2 = sprintf('D:/Documents/FCUL/Est?gio Mestrado/MSc Project/Code/Main Exp/troubleshooting/sub%d_main_%s',subjnum,type_tsk{w});
    else
        pth2 = sprintf('/Users/s4831829/output/plots&&others/sub%d',subjnum);
    end
    
    subvar = sprintf('sub%d_info.mat',subjnum); %variables saved from experiment
    load(fullfile(pth2,subvar)); %loads points obtained in each block and order of tasks presented
    
    % get sample number for 1st prediction in each trial
    for i = 1:length(st_trl_events)
        for j = 1:length(test_devents)
            if test_devents(j).sample == st_trl_events(i).sample;
                idx_strl(i) = j; %index for trial start in test_devents
                %break;
            end
        end
        
        if strcmp(test_devents(idx_strl(i)+1).type,'classifier.prediction') == 1
            smp_stprd(i) = test_devents(idx_strl(i)+1).sample; %sample for 1st pred in trial
        else %for cases where pred value is not the first to appear after trial star event
            k = 1;
            while(strcmp(test_devents(idx_strl(i)+k).type,'classifier.prediction') == 0)
                k = k+1;
            end
            smp_stprd(i) = test_devents(idx_strl(i)+k).sample; %sample for 1st pred in trial
        end
    end
    
    %get sample number for last prediction in each trial
    for i = 1:length(en_trl_events)
        for j = 1:length(test_devents)
            if test_devents(j).sample == en_trl_events(i).sample;
                idx_endtrl(i) = j; %index for trial end in test_devents
                break;
            end
        end
        
        if strcmp(test_devents(idx_endtrl(i)-1).type,'classifier.prediction') == 1
            smp_endprd(i) = test_devents(idx_endtrl(i)-1).sample; %sample for last pred in trial
        else %for cases where pred value is not the first to appear before trial end event
            k = idx_endtrl(i)-1;
            while(strcmp(test_devents(k).type,'classifier.prediction') == 0)
                k = k-1;
            end
            smp_endprd(i) = test_devents(k).sample; %sample for last pred in trial
        end
    end
    
    %find 1st and last prediction index to use afterwards for plotting
    for j = 1:length(smp_endprd)
        for i = 1:length(pred_events) %loop to find the index of the 1st pred of each trial
            if pred_events(i).sample == smp_stprd(j) % in the pred_events struct
                idx_st_pred(j) = i;
                break;
            end
        end
        
        for i = 1:length(pred_events) %loop to find the index of the last pred of each trial
            if pred_events(i).sample == smp_endprd(j) % in the pred_events struct
                idx_end_pred(j) = i;
                break;
            end
        end
    end
    
    %save sum of classifier predictions for each trial
    for i = 1:length(idx_st_pred)
        k = 0;
        for h = 1:(idx_end_pred(i)-idx_st_pred(i)+1)
            a(h) = pred_events(idx_st_pred(i)+k).value(1);
            k = k+1;
        end
        dv_per_trl(i) = sum(a); %sum of dvs for each trial
    end
    
    %plot sum of predictions per trial
    figure
    bar(dv_per_trl)
    title('DV per Trial')
    xlabel('Trial Number')
    ylabel('Sum of Decision Values')
    xlim([0 length(st_trl_events)+1]);
    saveas(gca, fullfile(pth,'sum_dv_trial'),'png');
    close all;
    
    k = 0;
    for j = 1:size(dv_bl,1)
        dv_per_blk(j) = sum(dv_per_trl(j+k:j+k+2)) %sum of trials per block
        k = k+2;
    end
    
    %plot sum of predictions per block per condition [no itit or pause periods included]
    figure
    bar(dv_per_blk)
    title('DV per Block')
    xlabel('Block Number')
    ylabel('Sum of Decision Values')
    xlim([0 size(dv_bl,1)+1]);
    saveas(gca, fullfile(pth,'sum_dv_block'),'png');
    close all;
    
    %% compare sum of DV for move and baseline within same trial
    % get sample number for 1st prediction of baseline for each trial
    for i = 1:length(st_bl_events)
        for j = 1:length(test_devents)
            if test_devents(j).sample == st_bl_events(i).sample;
                idx_stbl(i) = j; %index for trial start in test_devents
                %break;
            end
        end
        
        if strcmp(test_devents(idx_stbl(i)+1).type,'classifier.prediction') == 1
            smp_stblprd(i) = test_devents(idx_stbl(i)+1).sample; %sample for 1st pred in trial
        else %for cases where pred value is not the first to appear after trial star event
            k = 1;
            while(strcmp(test_devents(idx_stbl(i)+k).type,'classifier.prediction') == 0)
                k = k+1;
            end
            smp_stblprd(i) = test_devents(idx_stbl(i)+k).sample; %sample for 1st pred in trial
        end
    end
    
    %get sample number for last prediction of baseline in each trial
    for i = 1:length(en_bl_events)
        for j = 1:length(test_devents)
            if test_devents(j).sample == en_bl_events(i).sample;
                idx_endbl(i) = j; %index for trial end in test_devents
                break;
            end
        end
        
        if strcmp(test_devents(idx_endbl(i)-1).type,'classifier.prediction') == 1
            smp_endblprd(i) = test_devents(idx_endbl(i)-1).sample; %sample for last pred in trial
        else %for cases where pred value is not the first to appear before trial end event
            k = idx_endbl(i)-1;
            while(strcmp(test_devents(k).type,'classifier.prediction') == 0)
                k = k-1;
            end
            smp_endblprd(i) = test_devents(k).sample; %sample for last pred in trial
        end
    end
    
    %find 1st and last prediction index to use afterwards for plotting
    for j = 1:length(smp_endblprd)
        for i = 1:length(pred_events) %loop to find the index of the 1st pred of each trial
            if pred_events(i).sample == smp_stblprd(j) % in the pred_events struct
                idx_st_bl_pred(j) = i;
                break;
            end
        end
        
        for i = 1:length(pred_events) %loop to find the index of the last pred of each trial
            if pred_events(i).sample == smp_endblprd(j) % in the pred_events struct
                idx_end_bl_pred(j) = i;
                break;
            end
        end
    end
    
    %save sum of classifier predictions for each trial
    clear a;
    for i = 1:length(idx_st_bl_pred)
        k = 0;
        for h = 1:(idx_end_bl_pred(i)-idx_st_bl_pred(i)+1)
            a(h) = pred_events(idx_st_bl_pred(i)+k).value(1);
            k = k+1;
        end
        dv_bl_per_trl(i) = sum(a); %sum of dvs for each trial
    end
    
    % get sample number for 1st prediction of move for each trial
    for i = 1:length(st_mov_events)
        for j = 1:length(test_devents)
            if test_devents(j).sample == st_mov_events(i).sample;
                idx_stmov(i) = j; %index for trial start in test_devents
                %break;
            end
        end
        
        if strcmp(test_devents(idx_stmov(i)+1).type,'classifier.prediction') == 1
            smp_stmovprd(i) = test_devents(idx_stmov(i)+1).sample; %sample for 1st pred in trial
        else %for cases where pred value is not the first to appear after trial star event
            k = 1;
            while(strcmp(test_devents(idx_stmov(i)+k).type,'classifier.prediction') == 0)
                k = k+1;
            end
            smp_stmovprd(i) = test_devents(idx_stmov(i)+k).sample; %sample for 1st pred in trial
        end
    end
    
    %get sample number for last prediction of move in each trial
    for i = 1:length(en_mov_events)
        for j = 1:length(test_devents)
            if test_devents(j).sample == en_mov_events(i).sample;
                idx_endmov(i) = j; %index for trial end in test_devents
                break;
            end
        end
        
        if strcmp(test_devents(idx_endmov(i)-1).type,'classifier.prediction') == 1
            smp_endmovprd(i) = test_devents(idx_endmov(i)-1).sample; %sample for last pred in trial
        else %for cases where pred value is not the first to appear before trial end event
            k = idx_endmov(i)-1;
            while(strcmp(test_devents(k).type,'classifier.prediction') == 0)
                k = k-1;
            end
            smp_endmovprd(i) = test_devents(k).sample; %sample for last pred in trial
        end
    end
    
    %find 1st and last prediction index to use afterwards for plotting
    for j = 1:length(smp_endmovprd)
        for i = 1:length(pred_events) %loop to find the index of the 1st pred of each trial
            if pred_events(i).sample == smp_stmovprd(j) % in the pred_events struct
                idx_st_mov_pred(j) = i;
                break;
            end
        end
        
        for i = 1:length(pred_events) %loop to find the index of the last pred of each trial
            if pred_events(i).sample == smp_endmovprd(j) % in the pred_events struct
                idx_end_mov_pred(j) = i;
                break;
            end
        end
    end
    
    %save sum of classifier predictions for each trial
    clear a;
    for i = 1:length(idx_st_mov_pred)
        k = 0;
        for h = 1:(idx_end_mov_pred(i)-idx_st_mov_pred(i)+1)
            a(h) = pred_events(idx_st_mov_pred(i)+k).value(1);
            k = k+1;
        end
        dv_mov_per_trl(i) = sum(a); %sum of dvs for each trial
    end
    
    %plot sum of predictions per trial
    figure
    bar(dv_bl_per_trl)
    title('DV per Trial for baseline')
    xlabel('Trial Number')
    ylabel('Sum of Decision Values')
    xlim([0 length(st_trl_events)+1]);
    saveas(gca, fullfile(pth,'sum_dv_baseline_trial'),'png');
    close all;
    
    %plot sum of predictions per trial
    figure
    bar(dv_mov_per_trl,'r')
    title('DV per Trial for move')
    xlabel('Trial Number')
    ylabel('Sum of Decision Values')
    xlim([0 length(st_trl_events)+1]);
    saveas(gca, fullfile(pth,'sum_dv_move_trial'),'png');
    close all
    
    %plot together
    figure
    ab = bar(dv_bl_per_trl)
    hold on
    bc = bar(dv_mov_per_trl,'r')
    title('DV per Trial')
    xlabel('Trial Number')
    ylabel('Sum of Decision Values')
    xlim([0 length(st_trl_events)+1]);
    legend([ab bc],'rest','toe abd');
    saveas(gca, fullfile(pth,'sum_dv_BaselinevsMove_trial'),'png');
    close all;
    
    k = 0;
    for j = 1:size(dv_bl,1)
        dv_bl_per_blk(j) = sum(dv_bl_per_trl(j+k:j+k+2)); %sum of trials per block
        dv_mov_per_blk(j) = sum(dv_mov_per_trl(j+k:j+k+2)); %sum of trials per block
        k = k+2;
    end
    
    %plot sum of predictions per block per condition [no itit or pause periods included]
    figure
    bar(dv_bl_per_blk)
    title('DV per Block')
    xlabel('Block Number')
    ylabel('Sum of Decision Values')
    xlim([0 size(dv_bl,1)+1]);
    saveas(gca, fullfile(pth,'sum_dv_bl_block'),'png');
    close all;
    
    figure
    bar(dv_mov_per_blk,'r')
    title('DV per Block')
    xlabel('Block Number')
    ylabel('Sum of Decision Values')
    xlim([0 size(dv_bl,1)+1]);
    saveas(gca, fullfile(pth,'sum_dv_mov_block'),'png');
    close all;
    
    %plot together
    figure
    ab = bar(dv_bl_per_blk)
    hold on
    bc = bar(dv_mov_per_blk,'r')
    title('DV per Block')
    xlabel('Block Number')
    ylabel('Sum of Decision Values')
    xlim([0 size(dv_bl,1)+1]);
    legend([ab bc],'rest','toe abd');
    saveas(gca, fullfile(pth,'sum_dv_BaselinevsMove_block'),'png');
    close all;
    
end
end