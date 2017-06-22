%function [feedtxt,points] = points_fdbck(i,u,t,points,label,dur_trial,num_trial )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

curr_points(i) = points;

if strcmp(label,'rest')==1
    points_rest(u) = curr_points(i);
    u = u+1;
else
    points_abd(t) = curr_points(i);
    t = t+1;
end

if i>1 % motivational text between blocks
    
    if u>2 && strcmp(label,'rest')==1 %rest blocks
        
        if  points_rest(u-1)>round(dur_trial*num_trial/2) && (points_rest(u-1)-points_rest(u-2)>=0)
            motivtxt = 'Good job!';
            
        elseif (points_rest(u-1)-points_rest(u-2)>=0)
            motivtxt = 'Getting there, you can do it!';
        else
            motivtxt = 'You can do better.';
        end
        
        feedtxt = sprintf('Your score is %0.1f.\n\n%s',points,motivtxt);
        
    elseif t>2 && strcmp(label,'rest')==0 %abd blocks
        
        if  points_abd(t-1)>round(dur_trial*num_trial/2) && (points_abd(t-1)-points_abd(t-2)>=0)
            motivtxt = 'Good job!';
            
        elseif (points_abd(t-1)-points_abd(t-2)>=0)
            motivtxt = 'Getting there, you can do it!';
        else
            motivtxt = 'You can do better.';
        end
        
        feedtxt = sprintf('Your score is %0.1f.\n\n%s',points,motivtxt);
    else
        feedtxt = sprintf('Your score is %0.1f.',points);
    end
    
else %for first block
    feedtxt = sprintf('Your score is %0.1f.',points);
end

%end

