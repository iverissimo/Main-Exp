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

%all events in the continuous feedback phase (removed 'start' and 'end' phase events)
test_events = all_events(ind_starttest(length(ind_starttest))+2:ind_endtest(length(ind_endtest))-1);

mi_extra = matchEvents(test_events,{'CMS_IN_RANGE' 'BATTERY'}); %find events not relevant for plotting
ind_extra = find(mi_extra);

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
    dv(k) = pred_events(k).value; %decision values
    smp(k) = pred_events(k).sample; %prediction samples
end

tmp = (smp - smp(1))./fs; %time, to plot - relative to beginning of prediction values

if subjnum == 1
    trl_events = ft_filter_event(test_devents,'type','movement'); %only events for trial start BUG IN MAIN
    
    for k = 1:length(trl_events)
        val{k} = trl_events(k).value;
        stmp(k) = (trl_events(k).sample - smp(1))./fs;
    end
    
else
    st_trl_events = ft_filter_event(test_devents,'type','trial','value','start'); %only events for trial start
    en_trl_events = ft_filter_event(test_devents,'type','trial','value','end'); %only events for trial end
    st_blk_events = ft_filter_event(test_devents,'type','block','value','start'); %only events for block start
    en_blk_events = ft_filter_event(test_devents,'type','block','value','end'); %only events for block end
    
end


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

if subjnum == 1
    ititmp = timepoints(iti_events,smp(1),fs);%iti timepoints
    
    for k = 2:length(pause_events) %removed 1st pause event smp
        ptmp(k-1) = (pause_events(k).sample - smp(1))./fs; %pause timepoints
    end
    
    k = 1;
    for j = 1:length(ptmp)
        
        st = stmp(k:k+2)
        it = ititmp(k:k+2)
        figure(1) %dv plot for block x
        plot(tmp(it(1):round(ptmp(j)*4)),dv(it(1):round(ptmp(j)*4)),'*')
        ylim([min(dv) max(dv)])
        xlim([tmp(find(round(it(1))==tmp)) tmp(round(ptmp(j)*4))])
        hold on
        r = plot([st(:) st(:)],get(gca,'ylim'),'r')
        hold on
        g = plot([it(:) it(:)],get(gca,'ylim'),'g--')
        hold on
        plot(get(gca,'xlim'), [0 0],'k');
        legend([r(1) g(1)],'trial start','iti');
        bl = sprintf('DV for Block %d',j);
        title(bl)
        xlabel('Time (s)')
        ylabel('Decision Values')
        saveas(gca, fullfile(pth, sprintf('dv_block_%d',j)), 'png');
        close all;
        k = k + 3;
    end
    
else
    
    % all timepoints relative to 1st block event - Real beginning of experiment
    st_blktmp = timepoints(st_blk_events,st_blk_events(1).sample,fs);%start block timepoints
    en_blktmp = timepoints(en_blk_events,st_blk_events(1).sample,fs);%end block timepoints
    st_trltmp = timepoints(st_trl_events,st_blk_events(1).sample,fs);%start trial timepoints
    en_trltmp = timepoints(en_trl_events,st_blk_events(1).sample,fs);%end trial timepoints
    ititmp = timepoints(iti_events,st_blk_events(1).sample,fs); %iti timepoints
    
    for k = 1:length(test_devents)
        test_smp(k) = test_devents(k).sample;
    end
    
    ind_st_test = find(test_smp == st_blk_events(1).sample); %index of start of real test
    ind_st_test = ind_st_test+2;%+2 to be real prediction
    ind_en_test = find(test_smp == en_blk_events(length(en_blk_events)).sample); %index of end of real test
    ind_en_test = ind_en_test(length(ind_en_test))-2%-2 to be real prediction
    pred_events = ft_filter_event(test_devents(ind_st_test:ind_en_test),'type','classifier.prediction'); %only prediction events
    
    for k = 1:length(pred_events) %with new window of pred events
        dv(k) = pred_events(k).value; %decision values
        smp(k) = pred_events(k).sample; %prediction samples
    end
    tmp = (smp - smp(1))./fs; %time, to plot
    
    k = 1;
    for j=1:length(en_blktmp)
        figure(1)
        st = st_trltmp(k:k+2);
        st_tm(j,1:3) =  st;%start trial vector (num blocks x num trials)
        it = ititmp(k:k+2);
        it_tm(j,1:3) =  it;%iti vector (num blocks x num iti)
        
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
            xlim([tmp(round(st_blktmp(j)*4)) tmp(round(en_blktmp(j)*4))])
            if subjnum == 4 && j == 50
                xlim([tmp(round(st_blktmp(j)*4)) tmp(round(st_blktmp(j)*4))+60]) %each block is 49.5s = 99 inc in tmp vector
            end
        end
        hold on
        r = plot([st(:) st(:)],get(gca,'ylim'),'r');
        hold on
        g = plot([it(:) it(:)],get(gca,'ylim'),'g--');
        legend([r(1) g(1)],'trial start','iti');
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


pth2 = sprintf('D:/Documents/FCUL/Estágio Mestrado/MSc Project/Code/Main Exp/troubleshooting/sub%d_main_%s',subjnum,type_tsk{w});
subvar = sprintf('sub%d_info.mat',subjnum); %variables saved from experiment
load(fullfile(pth2,subvar)); %loads points obtained in each block and order of tasks presented

if subjnum ~= 4
    task = task(1:length(task)-1);%take out last task, not real
end
class_abd = find(task == 1); %abduction index
class_rest = find(task == 2); %rest index

if strcmp(type_tsk{w},'visual') %plot points only in visual task
    k=1;
    for j = 1:length(curr_points)
        if  k <= length(class_abd) && j == class_abd(k)
            points_abd(j) = curr_points(j); %save points for abd blocks
            points_rest(j) = NaN; %empty position for other condition
            %             soma_abd(j) = sum(dv_bl(j,:)); %save sum of dv for abd blocks
            %             soma_rest(j) = NaN; %empty position for other condition
            k = k+1;
        else
            points_rest(j) = curr_points(j); %save points for rest blocks
            points_abd(j) = NaN; %empty position for other condition
            %             soma_rest(j) = sum(dv_bl(j,:)); %save sum of dv for rest blocks
            %             soma_abd(j) = NaN; %empty position for other condition
        end
    end
    
    figure
    ab = bar(points_abd,'r')
    hold on
    rst = bar(points_rest)
    legend([ab rst],'toe abd','rest');
    title('Points per Block')
    xlabel('Block Nº')
    ylabel('Points')
    if subjnum == 1 xlim([0 21]); else xlim([0 length(curr_points)]); end;
    saveas(gca, fullfile(pth,'points_block'),'png');
    close all;
    
    %     %plot sum of predictions per block per condition
    %     figure
    %     ab2 = bar(soma_abd,'r')
    %     hold on
    %     rst2 = bar(soma_rest)
    %     legend([ab2 rst2],'toe abd','rest');
    %     title('DV per Block')
    %     xlabel('Block Nº')
    %     ylabel('Sum of Decision Values')
    %     if subjnum == 1 xlim([0 21]); else xlim([0 length(curr_points)]); end;
    %     saveas(gca, fullfile(pth,'sum_dv_block'),'png');
    %     close all;
    
end

if subjnum ~= 1
    
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
            k = i;
            while(strcmp(test_devents(idx_strl(k)+1).type,'classifier.prediction') == 0)
                k = k+1;
            end
            smp_stprd(i) = test_devents(idx_strl(k)+1).sample; %sample for 1st pred in trial
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
            a(h) = pred_events(idx_st_pred(i)+k).value;
            k = k+1;
        end
        dv_per_trl(i) = sum(a); %sum of dvs for each trial
    end
    
    
    %save trial number per condition
    num_trl = 3; %number of trials per block
    [trl_abd] = bl2trl(class_abd,num_trl);
    [trl_rst] = bl2trl(class_rest,num_trl);
    
    %plot sum of predictions per trial per condition
    k = 1;
    for i = 1:length(dv_per_trl)
        
        if k <= length(trl_abd) && i == trl_abd(k)
            dv_per_trl_abd(i) = dv_per_trl(i);%start time for abduction trials
            dv_per_trl_rest(i) = NaN;%empty position for other condition
            k = k+1;
        else
            dv_per_trl_rest(i) = dv_per_trl(i);%start time for rest trials
            dv_per_trl_abd(i) = NaN;%empty position for other condition
        end
    end
    
    %plot sum of predictions per trial per condition
    figure
    ab3 = bar(dv_per_trl_abd,'r')
    hold on
    rst3 = bar(dv_per_trl_rest)
    legend([ab3 rst3],'toe abd','rest');
    title('DV per Trial')
    xlabel('Trial Nº')
    ylabel('Sum of Decision Values')
    xlim([0 length(st_trl_events)]);
    saveas(gca, fullfile(pth,'sum_dv_trial'),'png');
    close all;
    
    %get sum of dv per block, only counting with predictions within trial
    for i = 1:length(class_abd)
        id_abd(i) = class_abd(i)*num_trl-num_trl+1
    end
    
    for i = 1:length(class_rest)
        id_rest(i) = class_rest(i)*num_trl-num_trl+1
    end
    
    k=1;
    z=1;
    for j = 1:length(task)
        if  k <= length(class_abd) && j == class_abd(k)
            soma_abd(j)=sum(dv_per_trl_abd(id_abd(k):id_abd(k)+2)) %sum of abd trials per block
            soma_rest(j) = NaN; %empty position for other condition
            k = k+1;
        else
            soma_rest(j)=sum(dv_per_trl_rest(id_rest(z):id_rest(z)+2)) %sum of rest trials per block
            soma_abd(j) = NaN; %empty position for other condition
            z=z+1;
        end
    end
    
    
    %plot sum of predictions per block per condition [no itit or pause periods included]
    figure
    ab2 = bar(soma_abd,'r')
    hold on
    rst2 = bar(soma_rest)
    legend([ab2 rst2],'toe abd','rest');
    title('DV per Block')
    xlabel('Block Nº')
    ylabel('Sum of Decision Values')
    if subjnum == 1 xlim([0 21]); else xlim([0 length(task)]); end;
    saveas(gca, fullfile(pth,'sum_dv_block'),'png');
    close all;

end