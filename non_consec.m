function [d] = non_consec(i,task,end_cond,type,num)

% function to avoid 3 consecutive tasks of the same type
% and to change type of condition if the initial randomly chosen type 
% already has enough examples

if (i > 2)&&(task(i) == task(i-1))&& (task(i-2) == task(i-1))  %to avoid 3xconsecutive tasks
    if task(i) == 1                   %when task = 1,1,1
        task(i) = task(i)+1;
    else                              %when task = 2,2,2
        task(i) = task(i)-1;
    end
end

% if condition reaches sufficient num of blocks, do alternative condition
if i >= end_cond && num(1) == end_cond
    task(i)= type(2);
elseif i >= end_cond && num(2) == end_cond
    task(i)= type(1);
end

d = task(i);

end

