%script for topoplots (ERD)

%calculate rest powerspectrum, movement powerspectrum and baseline (-3 to -0.1)
%to calculate according to the equation
% ERD = (condition - baseline)/baseline * 100

%baseline
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 8:1:40;%30; % analysis 8 to 30 Hz in steps of 1 Hz
cfg.taper = 'hanning';
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5 %vector 1 x numfoi, length of time window (in seconds)
cfg.toi = 0:0.5:6; % time window "slides" from 0 to 5 sec in steps of 0.5 sec (500 ms)

[baseline] = ft_freqanalysis(cfg, data_rest);
baseline.time = baseline.time(2:end-1); % do this to remove first&last column of values 
baseline.powspctrm = baseline.powspctrm(:,:,2:end-1); % that were NaN

%toe abd
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 8:1:40;%30; % analysis 8 to 30 Hz in steps of 1 Hz
cfg.taper = 'hanning';
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5 %vector 1 x numfoi, length of time window (in seconds)
cfg.toi = 7.5:0.5:19.5;% time window "slides" from 0 to 5 sec in steps of 0.5 sec (500 ms)

[move_abd] = ft_freqanalysis(cfg, data_abd);
move_abd.time = move_abd.time(2:end-1); % do this to remove first&last column of values 
move_abd.powspctrm = move_abd.powspctrm(:,:,2:end-1); % that were NaN


cfg = [];
cfg.avgovertime = 'yes'; %average the data along time dimension
[new_baseline] = ft_selectdata(cfg, baseline);
[new_move_abd] = ft_selectdata(cfg, move_abd);

ERD = new_move_abd;
ERD = rmfield(ERD,'time'); %remove non relevant field
ERD.dimord = 'chan_freq';
ERD.powspctrm = ((new_move_abd.powspctrm - new_baseline.powspctrm)./new_baseline.powspctrm)*100;


%plot the topographic distribution of 2-Dimensional datatypes
cfg = [];
cfg.parameter = 'powspctrm';
cfg.layout = 'biosemi64.lay';
cfg.showlabels = 'yes';
cfg.colorbar = 'yes';
cfg.zlim = [-30 30];

figure(1)
ft_topoplotER(cfg, ERD);

saveas(1, fullfile(pth,'topoplotER_abd'),'png');
close all;

ERD_mu = ERD;
mu_idx = [find(ERD.freq == 8) find(ERD.freq == 12)];
ERD_mu.freq = ERD.freq(mu_idx(1):mu_idx(2));
ERD_mu.powspctrm = ERD.powspctrm(:,mu_idx(1):mu_idx(2))

ERD_beta = ERD;
beta_idx = [find(ERD.freq == 15) find(ERD.freq == 30)];
ERD_beta.freq = ERD.freq(beta_idx(1):beta_idx(2));
ERD_beta.powspctrm = ERD.powspctrm(:,beta_idx(1):beta_idx(2))

ERD_gamma = ERD;
gamma_idx = [find(ERD.freq == 30) find(ERD.freq == 40)];
ERD_gamma.freq = ERD.freq(gamma_idx(1):gamma_idx(2));
ERD_gamma.powspctrm = ERD.powspctrm(:,gamma_idx(1):gamma_idx(2))

cfg = [];
cfg.parameter = 'powspctrm';
cfg.layout = 'biosemi64.lay';
cfg.showlabels = 'yes';
cfg.colorbar = 'yes';
cfg.zlim = [-30 30];
%cfg.colormap = ikelvin(256);

figure(1)
ft_topoplotER(cfg, ERD_mu);
figure(2)
ft_topoplotER(cfg, ERD_beta);
figure(3)
ft_topoplotER(cfg, ERD_gamma);

saveas(1, fullfile(pth,'topoplotER_abd_mu'),'png');
saveas(2, fullfile(pth,'topoplotER_abd_beta'),'png');
saveas(3, fullfile(pth,'topoplotER_abd_gamma'),'png');
close all;

% ratio_ERDS = ERD; 
% ratio_ERDS.powspctrm = ERD.powspctrm./ERS.powspctrm;
% 
% ratio_ERDS_mu = ERD_mu; 
% ratio_ERDS_mu.powspctrm = ERD_mu.powspctrm./ERS_mu.powspctrm;
% 
% ratio_ERDS_beta = ERD_beta; 
% ratio_ERDS_beta.powspctrm = ERD_beta.powspctrm./ERS_beta.powspctrm;
% 
% cfg = [];
% cfg.parameter = 'powspctrm';
% cfg.layout = 'biosemi64.lay';
% cfg.showlabels = 'yes';
% 
% figure(1)
% ft_topoplotER(cfg, ratio_ERDS);
% figure(2)
% ft_topoplotER(cfg, ratio_ERDS_mu);
% figure(3)
% ft_topoplotER(cfg, ratio_ERDS_beta);
