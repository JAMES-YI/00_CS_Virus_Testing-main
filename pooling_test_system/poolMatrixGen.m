function poolMatrix = poolMatrixGen(nRow,nCol)
% This file is to generate binary matrix of size n by n(n-1)/2 with 
% each column has 2 ones.
% 
% Assume: nCol = nRow(nRow-1)/2
%
% Created by JYI, 08/29/2020
%
%% 

onesLoc = nchoosek(1:nRow,2);
poolMatrix = zeros(nRow,nCol);
onesLocNum = size(onesLoc,1);

for iLoc=1:onesLocNum
    
    poolMatrix(onesLoc(iLoc,:),iLoc) = 1;
    
end


end