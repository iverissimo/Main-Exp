function [data, info] = iv_removeArtifacts(data, amplitude_threshold, important_channels,num_ch,pc)
%   remove any remaining artifacts, by either locally repairing channels in problematic trials, or rejecting the trial outright 
%
%   [data, info] = removeArtifacts(data, amplitude_threshold, importantChannels)
%
% Inputs:
%   data -- fieldtrip datastructure with (any) trial data
%%%%%%%% INES ADDED: num_ch = number of channels considered in the data,
%%%%%%%% previous code only allowed for 64
%   optional inputs:
%       amplitude_threshold -- threshold in microVolt that is used to
%                       identify problematic trials (default: 50)
%       importantChannels -- cell of strings, channel labels of the channels that 
%                       should not be repaired if rejected in a given trial 
%                       (default: {'Fz', 'FCz', 'Cz'})
% Outputs:
%  data -- fieldtrip datastructure containing trials

if ~exist('amplitude_threshold','var') || isempty(amplitude_threshold)
    amplitude_threshold = 50; % in microV
end
if ~exist('important_channels','var') || isempty(important_channels)
    important_channels = {}; % in microV
end

cfg = [];
cfg.channel  = data.label;
cfg.layout = 'biosemi64.lay';
lay = ft_prepare_layout(cfg);

if pc == 1 nb = open('D:/Documents/FCUL/Est?gio Mestrado/MSc Project/Code/fieldtrip-20161107/template/neighbours/biosemi64_neighb.mat');
else nb = open('~/bci_code/external_toolboxes/fieldtrip/template/neighbours/biosemi64_neighb.mat'); end
neighbours = nb.neighbours;     % fix the format

% using a threshold (any trial in any electrode exceeds 50 microvolts)
badtrialChannelStats=cellfun(@(x) find(max(abs(x(1:num_ch,:)),[],2) > amplitude_threshold), data.trial, 'UniformOutput',false);

idx_badtrials=[];
for trialNum=1:length(badtrialChannelStats)
    if ~isempty(badtrialChannelStats{trialNum})
        
        ch_idx = badtrialChannelStats{trialNum}; % channel(s) to be repaired for this trial
        
        % if channels to be repaired in the given trial exceeds
        % threshold, then reject entire trial for all channels
        % or if one of the channels to be repaired is among the
        % important ones for this experiment, then also reject
        % entire trial for all channels
        importantChannelIdx = cellfun(@(x) find(strcmp(x,data.label)), important_channels,'UniformOutput',0);
        threshold_max_badCh = 30;
        
        if length(ch_idx) >= threshold_max_badCh || ~isempty(intersect([importantChannelIdx{:}],ch_idx))
            idx_badtrials=[idx_badtrials trialNum];
            
            
            % otherwise repair/ interpolate channels for the given
%             % trial
        else
            cfg = [];
            cfg.layout =                lay;
            cfg.badchannel =            data.label(ch_idx);
            cfg.trials =                trialNum;
            cfg.neighbours =            neighbours;
            trial_data = ft_channelrepair(cfg, data);
            data.trial{trialNum} = trial_data.trial{1,1};
            info.trial(trialNum).channelsRepaired = data.label(ch_idx);
       %        data.trial{trialNum}(ch_idx,:) = NaN(numel(ch_idx),numel(data.time{trialNum}));
        end
        
    end
end

info.rejectedTrials = idx_badtrials;

% actually remove bad trials from data
if ~isempty(idx_badtrials)
    cfg=[];
    cfg.trials        =setdiff([1:size(data.trial,2)],idx_badtrials);    % exclude trials labeled as bad
    data     = ft_preprocessing(cfg,data);
end

end
