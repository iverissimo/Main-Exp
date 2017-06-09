
% script to wait for button box press (1)
% before continuing with experiment

initgetwTime; %start var getwTime
timeleft = time2press; %time to wait [s]
tempo = getwTime(); %get current time
state  = []; %current state of the newevents, empty between whiles to avoid processing incorrect events

while(timeleft>0) 
    [bevents, state] = buffer_newevents(buffhost,buffport,state,'response',[],timeleft*1000); %works for any button
    
    if strcmp(bevents.type,'response')
        timeleft = 0; %leaves loop
    else
        timeleft = time2press - (getwTime()-tempo);
    end
    
end