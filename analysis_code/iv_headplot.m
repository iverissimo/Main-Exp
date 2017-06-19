

addpath(genpath('/Users/s4831829/buffer_bci/matlab/plotting'));

[idxch, xpos,ypos,chlbl] = textread('pos64.txt','%d%f%f%s');
poslayout = [xpos,ypos];

%[hdls]=topohead(poslayout);

[h]=plotCapMontage('cap_conf_ines64ch') ;

h(1) = plot(datafreq_toeabd.freq,datafreq_toeabd.powspctrm(1,:));