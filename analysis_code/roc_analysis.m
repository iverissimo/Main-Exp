
%script to plot ROC curve

res = load(sprintf('res_test_sub%s',num2str(subjnum))); %struct with results from calib (train clsfr)

plot(res.opt.tstf)

prob = 1./(1+exp(-res.opt.tstf)); % convert from dv to probability (logistic transformation)

plot(prob)