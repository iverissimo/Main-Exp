
%function to plot ROC curve, based on Anne's calculateThreshold function
% for online analysis of calibration training results

function [thresholds,new_res] = ROCthresh_online(res,cfgcls,varargin)
tic
% INPUT
% res - struct with res.opt.tstf (dv values) and res.y (true labels)
% cfgcls - struct with subject specific information
%
% optional(varargin), but write them in this order
% % % doplot - [int] (1) plot hist and ROC curve
% % % calib - [int] (1) calibration phase
% % % num_pred - [int] number of predictions that are incremented at every run
% % % prev_thresh - [num] previous threshold value
% % % test - [int] (1) testing phase

% % % factor - [num] (0-1) factor to multiply the initial data, so we only
% % % % % % % % % save that amount for a next run

% OUTPUT
% thresholds - best decision value for the threshold
% new_res - res struct with the data used to plot the ROC curve

min_tn = min(res.opt.tstf); %smallest dv(most confident in -- class)
max_tp = max(res.opt.tstf); %greatest dv(most confident in ++ class)

num_tpl = sum(res.Y>0); % number of ++ labels
num_tnl = sum(res.Y<0);% number of -- labels

t = min_tn:(max_tp-min_tn)/1000:max_tp; %thresh values for # of test instances
tpr = zeros(1,length(t));
fpr = zeros(1,length(t));

for thres=1:length(t)
    idx_n = find(res.opt.tstf<t(thres)); % index for toe abd predictions (dv<thresh)
    idx_p = find(res.opt.tstf>t(thres)); % index for rest predictions (dv>thresh)
    tlp = res.Y(idx_p); % true labels of ++ predictions
    tln = res.Y(idx_n); % true labels of -- predictions
    
    tn = sum(tln<0); % true -- (dv<thresh & tl<0)
    tp = sum(tlp>0); % true ++ (dv>thresh & tl>0)
    fn = sum(tln>0); % false -- (dv<thresh & tl>0)
    fp = sum(tlp<0); % false ++ (dv>thresh & tl<0)
    
    tpr(thres) = tp/num_tpl; %true ++ rate (fraction of rest pred that was correct)
    fpr(thres) = fp/num_tnl; %false ++ rate (fraction of rest pred that was incorrect)
    
end

fpr_threshold=find(fpr <= 1/100); % == 0); % find the fpr closest to 
if numel(fpr_threshold) == 0
        if any(strcmp(varargin,'prev_thresh')) 
            prev_thresh = varargin{find(strcmp(varargin,'prev_thresh'))+1};
        else
            prev_thresh = 1.5; %default value for thresh
        end
        
    thresholds = prev_thresh; %if not possible to calculate new thresh. fpr = 0/0 = NaN
else
    fpr_threshold=fpr_threshold(1);
    thresholds=t(fpr_threshold); %find the matching threshold value t
end

for i =1:2:length(varargin)
    switch cell2mat(varargin(i))
        case 'doplot'
            if varargin{i+1} == 1 %do plots
                % plot histogram
                [n,x] = hist(res.opt.tstf(res.Y<0)); %dv of -- class
                [n2,x2]= hist(res.opt.tstf(res.Y>0));%dv of ++ class
                figure;
                h1=bar(x,n,'hist');
                hold on; h2=bar(x2,n2,'hist'); hold off
                set(h2, 'FaceColor', 'c', 'FaceAlpha', 0.5)
                title('Histogram of decision values')
                xlabel('DV')
                legend([h1 h2],'Toe Abd','Rest');
                
                %plot ROC curve
                figure
                plot(fpr,tpr)
                title('ROC curve');
                xlabel('False Positive Rate')
                ylabel('True Positive Rate')
                text(fpr(fpr_threshold),tpr(fpr_threshold),sprintf('%g',t(fpr_threshold)));
            end
        case 'calib'
            if varargin{i+1} == 1 % calibration
                new_res.opt.tstf = res.opt.tstf;
                new_res.Y = res.Y;
                
                if any(strcmp(varargin,'doplot')) %if plots were made
                    % save plots
                    plotdir = sprintf([cfgcls.pth_lab3 '/plots']);
                    mkdir(plotdir);
                    saveas(1, fullfile(plotdir,'Hist_DV'),'png');
                    saveas(2, fullfile(plotdir,sprintf('ROC_thresh_%s.png',mat2str(thresholds,3))));
                end
            end
            
        case 'num_pred'
            num_pred = varargin{i+1};
            
         case 'test'
            if varargin{i+1} == 1 % test
                if ~any(strcmp(varargin,'num_pred')) num_pred = 10; end %if no number was chosen, discard first 10 pred
                new_res.opt.tstf = res.opt.tstf(num_pred+1:end);
                new_res.Y = res.Y(num_pred+1:end);
            end   
            
    end
end

toc
end


