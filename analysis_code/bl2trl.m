function [trls] = bl2trl(blks,numtrl)
%function to transform block numbers to trial numbers
%then we can obtain a vector with the trial numbers for a certain class

%INPUT
%   blks - 1xN vector with the specific block numbers
%   numtrl - number of trials per block
%OUTPUT
%   trls - 1xM vector with the specific trial numbers

k=1;
for j = 1:length(blks)
    trls(k) = blks(j)*numtrl - numtrl+1;
    trls(k+1) = trls(k)+1;
    trls(k+2) = blks(j)*numtrl;
    k = k+3;
end

end

