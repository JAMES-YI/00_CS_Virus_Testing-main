function [MNeg,MPos,PPos] = suppEst_grpTest(A,poolVal,posNum)
% This function is to decode the infection status via decoding qualitative pooling
% results using traditional group testing approaches.
%
% Inputs
% - A, 2d array; effective binary mixing matrix after combining the mixing matrices
% from all different stages due to adaptive requests; single virus type,
% and single trial, and single run only;
% - poolVal, 1d array; qualitative values of pool tests from all the different stages in one trial and one virus type; binary vector with element being 1 if
%   the corresponding pool is positive, and 0 if negative; 
% - posNum, number of positive samples. Either 0 (number of positives is not specified) or 1 (only one positive).
% 
% Returns
% - MNeg, index set of samples which must be negative
% - MPos, index set of samples which must be positive
% - PPos, index set of samples which are potentially positive
% 
% Created by JYI, 08/24/2020
% Updated by JYI, 06/24/2022
% 
%%  

[poolNum,sampNum] = size(A); 
poolPos = find(poolVal==1); poolNeg = find(poolVal==0); 

%% Decoding pool results

% Get participants in each pool

for i=1:poolNum parpInd{i} = find(A(i,:)==1);  
end

% Get negative index set from all the negative pools

MNeg = [];
for i = poolNeg' MNeg = union(MNeg,parpInd{i}); 
end

% Get potential positive index set from all the positive pools
for i = poolPos' parpInd{i} = setdiff(parpInd{i},MNeg);
end

%% Report results

if posNum==0 % The number of positives not specified
    
    % get all potential positive sample
    if length(poolPos)==0 % no positive pools
        fprintf("All the samples are negative.")
        quit

    elseif length(poolPos)==1 % only one positive pool
        PPos = parpInd{poolPos(1)};
    else
        
        PPos = [];
        for i = poolPos' PPos = union(PPos,parpInd{i});
        end
        
    end
    
    % verify existence of must-positive sample
    if length(PPos)==1
        MPos = PPos;
        PPos = [];
    else
        MPos = [];

        for i = poolPos'

            tmpInd = find(A(i,:)==1);

            if length(tmpInd)==1 % positive pool with only one sample
                if ~ismember(tmpInd,MPos)
                    MPos = [MPos,tmpInd];
                end
                rmvInd = find(PPos==tmpInd);
                PPos(rmvInd) = [];
            end

        end
    end
    
    
elseif posNum==1 % prior knowledge is available: only single positive sample
    
    PPos = parpInd{poolPos(1)};
    if length(poolPos)>1
        for i = poolPos(2:end)'
            PPos = intersect(PPos,parpInd{i}); % the sample which appears in all the positive pools is positive
        end
    end
    
    MNeg = 1:sampNum;
    MNeg = MNeg([1:PPos-1,PPos+1:end]);
    MPos = PPos;
    PPos = [];
    
end
    
   
end