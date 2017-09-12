
% function to plot ROC curves that were obtained online

function ROCplot_offline(rocval,pth)

% INPUT
% rocval - struct
for j = 1:numel(rocval)
    
    min_tn = min(rocval(j).dvs); %smallest dv(most confident in -- class)
    max_tp = max(rocval(j).dvs); %greatest dv(most confident in ++ class)
    
    num_tpl = sum(rocval(j).labels>0); % number of ++ labels
    num_tnl = sum(rocval(j).labels<0);% number of -- labels
    
    t = min_tn:(max_tp-min_tn)/1000:max_tp; %thresh values for # of test instances
    tpr = zeros(1,length(t));
    fpr = zeros(1,length(t));
    
    for thres=1:length(t)
        idx_n = find(rocval(j).dvs<t(thres)); % index for toe abd predictions (dv<thresh)
        idx_p = find(rocval(j).dvs>t(thres)); % index for rest predictions (dv>thresh)
        tlp = rocval(j).labels(idx_p); % true labels of ++ predictions
        tln = rocval(j).labels(idx_n); % true labels of -- predictions
        
        tn = sum(tln<0); % true -- (dv<thresh & tl<0)
        tp = sum(tlp>0); % true ++ (dv>thresh & tl>0)
        fn = sum(tln>0); % false -- (dv<thresh & tl>0)
        fp = sum(tlp<0); % false ++ (dv>thresh & tl<0)
        
        tpr(thres) = tp/num_tpl; %true ++ rate (fraction of rest pred that was correct)
        fpr(thres) = fp/num_tnl; %false ++ rate (fraction of rest pred that was incorrect)
        
    end
    
    fpr_threshold=find(fpr <= 1/100); %== 0); %<= 1/72); % find the fpr closest to 1/(18*4)
    
    if ~isempty(fpr_threshold) % only plot if not empty, ie., fpr =/= NaN
        
    fpr_threshold=fpr_threshold(1);
    thresholds=t(fpr_threshold); %find the matching threshold value t
    
    % plot histogram
    [n,x] = hist(rocval(j).dvs(rocval(j).labels<0)); %dv of -- class
    [n2,x2]= hist(rocval(j).dvs(rocval(j).labels>0));%dv of ++ class
    figure;
    h1=bar(x,n,'hist');
    hold on; h2=bar(x2,n2,'hist'); hold off
    set(h2, 'FaceColor', 'c', 'FaceAlpha', 0.5)
    title('Histogram of decision values')
    xlabel('DV')
    legend([h1 h2],'Toe Abd','Rest');
    plotdir = sprintf([pth '/ROCplots']);
    mkdir(plotdir);
    saveas(gca, fullfile(plotdir, sprintf('Hist_%d',j)), 'png');
    close all;

    %plot ROC curve
    figure
    plot(fpr,tpr)
    title('ROC curve');
    xlabel('False Positive Rate')
    ylabel('True Positive Rate')
    text(fpr(fpr_threshold),tpr(fpr_threshold),sprintf('%g',t(fpr_threshold)));
    plotdir = sprintf([pth '/ROCplots']);
    mkdir(plotdir);
    saveas(gca, fullfile(plotdir, sprintf('ROCcurve_%d',j)), 'png');
    close all;
    end
    
end
end


