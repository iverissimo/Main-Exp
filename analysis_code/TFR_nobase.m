
% TIME FREQUENCY PLOTS without baseline subtraction
% obtain plots for baseline and toe abduction separately

%MTMCONVOL performs time-frequency analysis on any time series trial
%data using the 'multitaper method'
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 8:1:30; % analysis 8 to 30 Hz in steps of 1 Hz
cfg.taper = 'hanning';
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5 %vector 1 x numfoi, length of time window (in seconds)
cfg.toi = 0:0.5:6; % time window "slides" from 0 to 6 sec in steps of 0.5 sec (500 ms)

[datafreq_rest2] = ft_freqanalysis(cfg, data_rest);
datafreq_rest2.time = datafreq_rest2.time(2:end-1); % do this to remove first&last column of values 
datafreq_rest2.powspctrm = datafreq_rest2.powspctrm(:,:,2:end-1); % that were NaN

cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 8:1:30; % analysis 8 to 30 Hz in steps of 1 Hz
cfg.taper = 'hanning';
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5 %vector 1 x numfoi, length of time window (in seconds)
cfg.toi = 7.5:0.5:19.5;% time window "slides" from 7.5 to 19.5 sec in steps of 0.5 sec (500 ms)

[datafreq_toeabd2] = ft_freqanalysis(cfg, data_abd);
datafreq_toeabd2.time = datafreq_toeabd2.time(2:end-1); % do this to remove first&last column of values 
datafreq_toeabd2.powspctrm = datafreq_toeabd2.powspctrm(:,:,2:end-1); % that were NaN

%plots the time-frequency representations of power
%in a topographical layout.
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.parameter = 'powspctrm'; %field to be represented as color
%cfg.maskstyle = 'saturation';
% cfg.baseline = [-3 -0.1]; %(default = 'no'), see FT_FREQBASELINE
% cfg.baselinetype = 'absolute'; %'relative', 'relchange' or 'db' (default = 'absolute')
cfg.showlabels = 'yes';
cfg.box = 'yes';
cfg.colorbar = 'yes';
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);

figure
ft_multiplotTFR(cfg, datafreq_toeabd2);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotTFR_abd_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotTFR_abd'),'png'); end
close all

figure
ft_multiplotTFR(cfg, datafreq_rest2);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotTFR_rest_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotTFR_rest'),'png'); end
close all

%% try out with more central capfile
cfg = [];
cfg.layout = 'biosemi_20ch.lay';
cfg.parameter = 'powspctrm'; %field to be represented as color
%cfg.maskstyle = 'saturation';
% cfg.baseline = [-3 -0.1]; %(default = 'no'), see FT_FREQBASELINE
% cfg.baselinetype = 'absolute'; %'relative', 'relchange' or 'db' (default = 'absolute')
cfg.showlabels = 'yes';
cfg.box = 'yes';
cfg.colorbar = 'yes';
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);

figure
ft_multiplotTFR(cfg, datafreq_toeabd2);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotTFR_20ch_abd_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotTFR_20ch_abd'),'png'); end
close all

figure
ft_multiplotTFR(cfg, datafreq_rest2);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotTFR_20ch_rest_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotTFR_20ch_rest'),'png'); end

close all

%% relevant channels in motor strip (for toe movement)
cfg = [];
% cfg.baseline     = [-3 -0.1];
% cfg.baselinetype = 'absolute';
cfg.maskstyle    = 'saturation'
cfg.showlabels = 'yes';
cfg.colorbar = 'yes';
cfg.channel = 'FCz';
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);
% Blue = ones(101,3);
% Red = ones(101,3);
% Blue(:,3) = 1:-0.01:0;
% Red(:,1) = 0:0.01:1;
% colormap = [Red(1:end-1,:); Blue];
% cfg.colormap     = colormap;

figure
ft_singleplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'TFR_FCz_abd'),'png');
close all

figure
ft_singleplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'TFR_FCz_rest'),'png');
close all

cfg.channel = 'Cz';
figure
ft_singleplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'TFR_Cz_abd'),'png');
close all

figure
ft_singleplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'TFR_Cz_rest'),'png');
close all

cfg.channel = 'CPz';
figure
ft_singleplotTFR(cfg, datafreq_toeabd2);
saveas(gca, fullfile(pth,'TFR_CPz_abd'),'png');
close all

figure
ft_singleplotTFR(cfg, datafreq_rest2);
saveas(gca, fullfile(pth,'TFR_CPz_rest'),'png');
close all
