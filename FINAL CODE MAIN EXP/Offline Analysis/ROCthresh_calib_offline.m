
%function to plot ROC curve, based on Anne's calculateThreshold function
% for offline analysis of calibration training results

function [thresholds]=ROCthresh_calib_offline(res,pth)

% INPUT
% res - struct with res.opt.tstf (dv values) and res.y (true labels)

% OUTPUT
% thresholds - best value for the threshold

min_tn = min(res.opt.tstf); %smallest dv(most confident in -- class)
max_tp = max(res.opt.tstf); %greatest dv(most confident in ++ class)

[n,x] = hist(res.opt.tstf(res.Y<0)); %dv of -- class
[n2,x2]= hist(res.opt.tstf(res.Y>0));%dv of ++ class
figure;
h1=bar(x,n,'hist');
hold on; h2=bar(x2,n2,'hist'); hold off
set(h2, 'FaceColor', 'c', 'FaceAlpha', 0.5)
title('Histogram of decision values')
xlabel('DV')
legend([h1 h2],'Toe Abd','Rest');

t = min_tn:(max_tp-min_tn)/1000:max_tp; %thresh values for # of test instances
tpr = zeros(1,length(t));
fpr = zeros(1,length(t));
% tnr = zeros(1,length(t));
% fnr = zeros(1,length(t));

for thres=1:length(t)
    idx_n = find(res.opt.tstf<t(thres)); % index for toe abd predictions (dv<thresh)
    idx_p = find(res.opt.tstf>t(thres)); % index for rest predictions (dv>thresh)
    tlp = res.Y(idx_p); % true labels of ++ predictions
    tln = res.Y(idx_n); % true labels of -- predictions
    
    tn = sum(tln<0); % true -- (dv<thresh & tl<0)
    tp = sum(tlp>0); % true ++ (dv>thresh & tl>0)
    fn = sum(tln>0); % false -- (dv<thresh & tl>0)
    fp = sum(tlp<0); % false ++ (dv>thresh & tl<0)
    
    tpr(thres) = tp/sum(res.Y>0); %true ++ rate (fraction of rest pred that was correct)
    fpr(thres) = fp/sum(res.Y<0); %false ++ rate (fraction of rest pred that was incorrect)
    
    %     tnr(thres) = tn/sum(res.Y<0); %true -- rate (fraction of toe abd pred that was correct)
    %     fnr(thres) = fn/sum(res.Y>0); %false -- rate (fraction of toe abd pred that was incorrect)
end

fpr_threshold=find(fpr <= 1/100); %<= 1/72); % find the fpr closest to 1/(18*4) (1/20?)
fpr_threshold=fpr_threshold(1);
thresholds=t(fpr_threshold); %find the matching threshold value t

%plot ROC curve
figure
plot(fpr,tpr)
title('ROC curve');
xlabel('False Positive Rate')
ylabel('True Positive Rate')
text(fpr(fpr_threshold),tpr(fpr_threshold),sprintf('%g',t(fpr_threshold)));

saveas(1, fullfile(pth,'Hist_DV'),'png');
saveas(2, fullfile(pth,sprintf('ROC_thresh_%s.png',mat2str(thresholds,3))));

end

