
%function to plot ROC curve, based on Anne's calculateThreshold function

function ROCthresh_testdata(deval_basel,deval_move,num_blk,num_trl,pth)

% INPUT

% OUTPUT
% thresholds - best value for the threshold

%roc curve per trial, for each block
siz_pred_base = size(deval_basel,2);
plotdir = sprintf([pth '/ROCplots']);
mkdir(plotdir);
for m = 1:num_blk
    for j = 1:num_trl
        dv_trl_both = cat(2,deval_basel(j,:,m),deval_move(j,:,m)); %for 1st trial
        min_tn_trl = min(dv_trl_both); %smallest dv(most confident in -- class)
        max_tp_trl = max(dv_trl_both); %greatest dv(most confident in ++ class)
        
        num_tlp = sum(~isnan(deval_basel(j,:,m))); % sum of true label baseline
        num_tln = sum(~isnan(deval_move(j,:,m))); % sum of true label move
        
        t(j,:) = min_tn_trl:(max_tp_trl-min_tn_trl)/1000:max_tp_trl; %thresh values for # of test instances
        
        for thres=1:length(t)
            idx_n = find(dv_trl_both<t(j,thres)); % index for toe abd predictions (dv<thresh)
            idx_p = find(dv_trl_both>t(j,thres)); % index for rest predictions (dv>thresh)
            
            tp = sum(idx_p(:)<siz_pred_base+1); % true ++ (dv>thresh & tl base)
            tn = sum(idx_n(:)>siz_pred_base); % true -- (dv<thresh & tl move)
            fn = sum(idx_n(:)<siz_pred_base+1); % false -- (dv<thresh & tl base)
            fp = sum(idx_p(:)>siz_pred_base); % false ++ (dv>thresh & tl move)
            
            tpr(j,thres) = tp/num_tlp; %true ++ rate (fraction of rest pred that was correct)
            fpr(j,thres) = fp/num_tln; %false ++ rate (fraction of rest pred that was incorrect)
            
        end
        
        fpr_thresh=find(fpr(j,:) <= 1/100);%<= 1/72); %1/20); % find the fpr closest to 1/70
        fpr_threshold(j)=fpr_thresh(1);
        thresholds(j)=t(fpr_threshold(j)); %find the matching threshold value t
        
    end
    
    %plot ROC curve
    figure
    h1 = plot(fpr(1,:),tpr(1,:));
    text(fpr(1,fpr_threshold(1)),tpr(1,fpr_threshold(1)),sprintf('%g',t(fpr_threshold(1))));
    hold on
    h2 = plot(fpr(2,:),tpr(2,:));
    text(fpr(2,fpr_threshold(2)),tpr(2,fpr_threshold(2)),sprintf('%g',t(fpr_threshold(2))));
    hold on
    h3 = plot(fpr(3,:),tpr(3,:));
    text(fpr(3,fpr_threshold(3)),tpr(3,fpr_threshold(3)),sprintf('%g',t(fpr_threshold(3))));
    legend([h1 h2 h3],'1st trl','2nd trl', '3rd trl');
    title(sprintf('ROC curve for Block %d',m));
    xlabel('False Positive Rate')
    ylabel('True Positive Rate')
    saveas(gca, fullfile(plotdir, sprintf('ROCcurve_block_%d',m)), 'png');
    close all;
end
end
