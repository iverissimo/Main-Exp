function shamDV(subjnum,sessnum,pth0)

% get decision values from specific subject and session, to use for sham
% cases later on. Saves values in mat file in the subjects folder

load([pth0 '/' sprintf('eventstruct_sub%s_session%s.mat',num2str(subjnum),num2str(sessnum))]);
somestruct.all_events = somestruct.all_events(somestruct.ind_starttest(end):end); %all events from actual test phase

for i = 1:numel(somestruct.all_events)
    allevents_samp(i) = somestruct.all_events(i).sample;  % samples from all events
end
allevents_samp = allevents_samp'; %correct format

for i = 1:numel(somestruct.st_bl_events)
    start_baseline_samp(i,1) = somestruct.st_bl_events(i).sample; %save beginning of baseline samples
    end_baseline_samp(i,1) = somestruct.en_bl_events(i).sample; %save end of baseline samples
    start_move_samp(i,1) = somestruct.st_mov_events(i).sample; %save beginning of move samples
    end_move_samp(i,1) = somestruct.en_mov_events(i).sample; %save end of move samples
    
    % turn it all into indexes to find it in allevents
    ind = allevents_samp == start_baseline_samp(i,1);
    a = find(ind); ind_stbase(i,1) = a(1); %do this to avoid cases where there is more than 1 sample
    ind = allevents_samp == end_baseline_samp(i,1);
    a = find(ind); ind_endbase(i,1) = a(1);
    
    ind = allevents_samp == start_move_samp(i,1);
    a = find(ind); ind_stmove(i,1) = a(1);
    ind = allevents_samp == end_move_samp(i,1);
    a = find(ind); ind_endmove(i,1) = a(1);
    
    base_clean_events = somestruct.all_events(ind_stbase(i,1):ind_endbase(i,1)); %only baseline events for this trial
    base_clean_events = ft_filter_event(base_clean_events,'type','classifier.prediction'); %only prediction events
    
    for m = 1:numel(base_clean_events)
        b = base_clean_events(m).value;
        temp_matrx(m,1) = b(1); %temporary matrix to store dvs
    end
    
    dv_baseline{:,i} = temp_matrx;    
    clear temp_matrx
    
    move_clean_events = somestruct.all_events(ind_stmove(i,1):ind_endmove(i,1)); %only move events for this trial
    move_clean_events = ft_filter_event(move_clean_events,'type','classifier.prediction'); %only prediction events
    
    for n = 1:numel(move_clean_events)
        c = move_clean_events(n).value;
        temp_matrx(n,1) = c(1); %temporary matrix to store dvs
    end
    
    dv_move{:,i} = temp_matrx;    
    clear temp_matrx
    
end

k = 0;
for d = 1:30
    for h = 1:3
        new_dv_baseline{d,h} = dv_baseline{1,k+h};
        new_dv_move{d,h} = dv_move{1,k+h};
    end
    k = k+3;
end

save([pth0 '/' sprintf('dv_move_sub%s_session%s.mat',num2str(subjnum),num2str(sessnum))],'new_dv_move');
save([pth0 '/' sprintf('dv_baseline_sub%s_session%s.mat',num2str(subjnum),num2str(sessnum))],'new_dv_baseline');

end