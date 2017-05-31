
%% script to run in separate MATLAB window
pname=fullfile('/Users/s4831829/Main Exp','cfgcls.mat');
load(pname);

%load('cfgcls.mat') %struct with parameters defined in Main_exp

%startSigProcBuffer(varargin);
iv_startSigProcBuffer('phaseEventType','startPhase.cmd',...
    'epochEventType',{{'movement'} {'rest' 'toe_abd'}},'trlen_ms',cfgcls.tot_trl,...
            'clsfr_type','ersp','freqband',cfgcls.freqband,'contPredFilt',@(x,s) biasFilt(x,s,3*60*4),...
            'contFeedbackOpts',{'trlen_ms',cfgcls.train_wndow,'overlap',1/3});

%cont_applyClsfr
% bias adaptation filter, length 3 minutes 
%  trlen_ms -- [float] length of trial to apply classifier to
%  overlap       -- [float] fraction of trlen_samp between successive classifier predictions, i.e.
%                    prediction at, t, t+trlen_samp*overlap, t+2*(trlen_samp*overlap), ...

