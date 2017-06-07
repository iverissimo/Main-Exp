function [data,info, freq] = iv_rejectBadChannels(data, outlier_threshold, plot_topo50Hz,keepch) %label, preproc_info)
% identify, reject and interpolate bad channels (based on neighbours)
%
%       [data_dev, data_std, info, freq_dev, freq_std] = rejectBadChannels(data_dev, data_std, outlier_threshold, plot_noise)
%
%
% Inputs:
%   data_dev -- fieldtrip datastructure with deviant trial data
%   data_std -- fieldtrip datastructure with standard trial data
%   optional inputs:
%       outlier_threshold --  threshold defining outliers, in of number of standard deviants  (default: 3)
%       plot_topo50Hz -- whether or not a topoplot of 50Hz strenght across
%                       electrodes should be generated (default: 0)
% Outputs:
%  data_dev -- fieldtrip datastructure containing deviant trials
%  data_std -- fieldtrip datastructure containing standard trials
%  info -- struct containing:
%          threshold -- double, recording the threshold in microV
%          badchannels -- cell string, containing the bad channels that
%                       were repaired


if ~exist('outlier_threshold','var') || isempty(outlier_threshold)
    outlier_threshold = 3; % in units of standard deviation
end
if ~exist('plot_topo50Hz','var') || isempty(plot_topo50Hz)
    plot_topo50Hz = 0;
end

% frequency analysis for DEVIANT trials
cfg=[];
cfg.method='mtmfft';
cfg.output='pow';
cfg.taper='hanning';
cfg.channel = 'eeg';
cfg.foi= [50];          % for display of 50 Hz influence/ artifacts
freq=ft_freqanalysis(cfg,data);


% layout preparation with channel map
cfg = [];
cfg.channel  = data.label;
cfg.layout = 'biosemi64.lay';
lay = ft_prepare_layout(cfg);

% plot to visually check influence of 50 Hz
if plot_topo50Hz
    figure
    cfg = [];
    cfg.layout = lay;
    cfg.marker = 'labels';
    cfg.interactive ='yes';
    cfg.colorbar = 'yes';
    
    subplot(1,2,2)
    ft_topoplotER(cfg, freq)
end

% find outlier channels
threshold = std(freq.powspctrm) * outlier_threshold + mean(freq.powspctrm);


% save for output info
info.threshold = threshold; % outlier threshold in mV depending on standard deviation

bad_idx = find(freq.powspctrm>threshold);
bad_idx = bad_idx(bad_idx(:) < 65);           % exclude EXGs

if keepch == 1
    ch_cent = {'FC3','FC1','FCz','FC2','FC4',...
        'C3','C1','Cz','C2','C4',...
        'CP3','CP1','CPz','CP2','CP4',...
        'P3','P1','Pz','P2','P4'}; %central/motorstrip chn
    lbl = data.label(:) %all channel labels
    
    for i = 1:length(ch_cent)
        for j = 1:length(data.label)
            if strcmp(lbl{j},ch_cent{i}) == 1
                ch_ind(i) = j; %save indexes of interest
            end
        end
    end
    
    %don't remove central channels even if >thresh
    k = 1;
    new_idx = [];
    for i = 1:length(bad_idx)
        good_ch = ch_ind == bad_idx(i);
        good_ch = ch_ind(good_ch);
        
        if isempty(good_ch) %only save index if is not one of the central chn
            new_idx(k) = bad_idx(i);
            k = k+1;
        end
    end
    bad_idx = new_idx;
end
% return and allocate badchannel labels
badchannels=cell(numel(bad_idx),1);
[badchannels{1:numel(bad_idx),1}] = deal(freq.label{bad_idx});

% display info
fprintf('Threshold for rejecting channels based on 50 Hz influence is: %.3f mV \n',threshold )

fprintf('%i bad channel(s) found.\n', length(badchannels));
fprintf('Channel with strong 50 Hz influence: %s \n',badchannels{:});

info.badchannels = badchannels;


channels = cellfun(@(x) ['-' x],badchannels,'UniformOutput',0);
cfg_channel.channel = {'all' channels{:}};
data = ft_preprocessing(cfg_channel,data);

% for i=1:length(data.trial)
%     data.trial{i}(bad_idx,:) = nan;
% end

% % load neighbour information for interpolation
% neighbours=open('~/bci_code/external_toolboxes/fieldtrip/template/neighbours/biosemi64_neighb.mat');
% neighbours=neighbours.neighbours;       % convert into right format with .label and .neighblabel as subfields
%
% % interpolate bad channels, if any
% if ~isempty(badchannels)
%     % deviant
%     cfg = [];
%     cfg.layout=lay;
%     cfg.badchannel = badchannels;
%     cfg.neighbours = neighbours;
%     data = ft_channelrepair(cfg, data);
% end

end