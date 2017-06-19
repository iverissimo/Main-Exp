% bad trials: automatic artifact removal (based on toolbox by jason
% farquhar
function data = subtractEOG(data,refchannels)
% convert to jason's toolbox, remove EOG artifacts from trials and convert
% back to fieldtrip

if ~exist('refchannels','var') || isempty(refchannels)
    refchannels = {'EXG3' 'EXG4' 'EXG5' 'EXG6'};
end


% First class
% adding information regarding events for transforming to jason's code
[X,di,fs,summary,opts,info]=readraw_fieldtrip(data,'Y',ones(size(data.time))');
clear z
z.X=X;
z.di=di;
z.fs=fs;
z.summary=summary;
z.opts=opts;
z.info=info;

eog_idx = cellfun(@(channel) find(strcmp(z.di(1).vals,channel)),refchannels);
z.EOG = z.X(eog_idx,:,:); %retain the 'original' EOG data

% EOG substraction
z=jf_artChRm(z,'vals',refchannels);

z.X(eog_idx,:,:) = z.EOG;   %re-insert the 'original' EOG data
% opts.freqRatio= 1.3;
% % EMG substraction (Eliana's tip: in case of significant muscle activity
% z=ms_rmEMG(z,'dim',{'ch','time'},'freqRatio',opts.freqRatio,...
%         'rmEMGfreq',[1 25 25 45],'mkPlot',0);

data.trial = shiftdim(num2cell(double(z.X(:,:,:)), [1 2]))'; % back to fieldtrip

end