% display text with block number, type of task and current points
% used several times in main, this way avoid repetition

text(5,8,cue{1},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
axis([0 10 0 10]);
set(gca,'visible','off');

cue_move = text(5,6,cue{2},'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
axis([0 10 0 10]);
set(gca,'visible','off');

feedtxt = sprintf('Current score is %0.1f.',points);
text(5,4,feedtxt,'Color',txtColor,'FontSize',txtSize_cue,'HorizontalAlignment','center');
axis([0 10 0 10]);
set(gca,'visible','off');
drawnow;