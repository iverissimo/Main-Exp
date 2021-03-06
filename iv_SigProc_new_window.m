
%% script to run in separate MATLAB window
% pname=fullfile('/Users/s4831829/Main Exp','cfgcls.mat');
% load(pname);
addpath(fullfile('/Users/s4831829/Main Exp/'));
configureMain_exp_v2;
%load('cfgcls.mat') %struct with parameters defined in Main_exp

%startSigProcBuffer(varargin);
iv_startSigProcBuffer('phaseEventType','startPhase.cmd','capFile','cap_conf_ines64ch',...
    'epochEventType',{{'movement'} {'rest' 'toe_abd'}},'trlen_ms',cfgcls.tot_trl,...
    'clsfr_type','ersp','freqband',cfgcls.freqband,'contPredFilt',@(x,s,e) biasFilt(x,s,3*60*4),...
    'contFeedbackOpts',{'trlen_ms',cfgcls.train_wndow,'overlap',1/3},...
    'trainOpts',trainOpts);

%cont_applyClsfr
% bias adaptation filter, length 3 minutes
%  trlen_ms -- [float] length of trial to apply classifier to
%  overlap       -- [float] fraction of trlen_samp between successive classifier predictions, i.e.
%                    prediction at, t, t+trlen_samp*overlap, t+2*(trlen_samp*overlap), ...
%trainOpts      -- {cell} cell array of additional options to pass to the classifier trainer, e.g.
%                       'trainOpts',{'width_ms',1000} % sets the welch-window-width to 1000ms
%   adaptspatialfiltFn -- 'fname' or {fname args} function to call for adaptive spatial filtering, ...
%                           such as 'adaptWhitenFilt', or 'artChRegress'
%                           fname should be the name of a *filterfunction* to call.

