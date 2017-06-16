
% TIME FREQUENCY PLOTS with baseline subtraction
% obtain plots for toe abduction, using whole data window


%MTMCONVOL performs time-frequency analysis on any time series trial
%data using the 'multitaper method'
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 8:1:40; % analysis 8 to 30 Hz in steps of 1 Hz
cfg.taper = 'hanning';
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5 %vector 1 x numfoi, length of time window (in seconds)
cfg.toi = 0:0.5:19.5; % time window "slides" from 0 to 6 sec in steps of 0.5 sec (500 ms)

[data5freq] = ft_freqanalysis(cfg, data5);
data5freq.time = data5freq.time(2:end-1); % do this to remove first&last column of values 
data5freq.powspctrm = data5freq.powspctrm(:,:,2:end-1); % that were NaN


%plots the time-frequency representations of power
%in a topographical layout.
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.parameter = 'powspctrm'; %field to be represented as color
cfg.maskstyle = 'saturation';
cfg.baseline = [data5freq.time(1) 6]; %(default = 'no'), see FT_FREQBASELINE
cfg.baselinetype = 'absolute'; %'relative', 'relchange' or 'db' (default = 'absolute')
cfg.showlabels = 'yes';
cfg.box = 'yes';
cfg.colorbar = 'yes';
cfg.xlim = [5 19.5];
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);

figure
ft_multiplotTFR(cfg, data5freq);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotTFR_abd_subbase_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotTFR_abd_subbase'),'png'); end
close all;


%% try out with more central capfile
cfg = [];
cfg.layout = 'biosemi_20ch.lay';
cfg.parameter = 'powspctrm'; %field to be represented as color
cfg.maskstyle = 'saturation';
cfg.baseline = [data5freq.time(1) 6]; %(default = 'no'), see FT_FREQBASELINE
cfg.baselinetype = 'absolute'; %'relative', 'relchange' or 'db' (default = 'absolute')
cfg.showlabels = 'yes';
cfg.box = 'yes';
cfg.colorbar = 'yes';
cfg.xlim = [5 19.5];
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);

figure
ft_multiplotTFR(cfg, data5freq);
if keepch == 1 saveas(gca, fullfile(pth,'multiplotTFR_20ch_abd_subbase_allch'),'png');
else saveas(gca, fullfile(pth,'multiplotTFR_20ch_abd_subbase'),'png'); end

close all

%% relevant channels in motor strip (for toe movement)
cfg = [];
cfg.maskstyle = 'saturation';
cfg.baseline = [data5freq.time(1) 6]; %(default = 'no'), see FT_FREQBASELINE
cfg.baselinetype = 'absolute'; %'relative', 'relchange' or 'db' (default = 'absolute')
cfg.showlabels = 'yes';
cfg.colorbar = 'yes';
cfg.channel = 'FCz';
cfg.xlim = [5 19.5];
cfg.zlim = [-1 1];
cfg.colormap = ikelvin(256);
% Blue = ones(101,3);
% Red = ones(101,3);
% Blue(:,3) = 1:-0.01:0;
% Red(:,1) = 0:0.01:1;
% colormap = [Red(1:end-1,:); Blue];
% cfg.colormap     = colormap;

figure
ft_singleplotTFR(cfg, data5freq);
saveas(gca, fullfile(pth,'TFR_FCz_abd_subbase'),'png');
close all

cfg.channel = 'Cz';
figure
ft_singleplotTFR(cfg, data5freq);
saveas(gca, fullfile(pth,'TFR_Cz_abd_subbase'),'png');
close all

cfg.channel = 'CPz';
figure
ft_singleplotTFR(cfg, data5freq);
saveas(gca, fullfile(pth,'TFR_CPz_abd_subbase'),'png');
close all

