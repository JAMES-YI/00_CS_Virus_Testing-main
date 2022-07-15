function [MNeg,MPos,Pos] = pool_dec_spb(A,poolStatus,Params)
% This function is to decode the infection status via qualitative pooling
% results.
%
% - A, mixing matrix
% - poolStatus, qualitative values of pool tests; binary vector; 1 if
%   positive, and 0 if negative; 
% - posNum, number of positive samples. Either 0 (number of positives is not specified) or 1 (only one positive).
% 
% The group testing algorithm is based on the sample-based group testing
% decoding algorithm.
% 
% returns
% - MNeg, index set of samples which must be negative
% - MPos, index set of samples which must be positive
% - Pos, index set of samples which can be positive and need extra tests
% 
% Created by JYI, 09/15/2020.
% 
%% Decoding configurations and parameter setup

posNum = Params.posNum;
[~,nSamp] = size(A);
posInd = find(poolStatus==1);

%% 
Pos = [];
MPos = [];
unionPtcp = [];

% get all potential positive samples
for iSamp=1:nSamp

    posIndTmp = find(A(:,iSamp)==1);

    if all(ismember(posIndTmp,posInd))==1

        Pos = [Pos,iSamp];
        posNumTmp = length(Pos);
        sampPtcp{posNumTmp} = posIndTmp;
        unionPtcp = union(unionPtcp,posIndTmp);
    end

end

if posNum~=1
    
    % check existence of errors in pooling results
    if all(ismember(unionPtcp,posInd)) && all(ismember(posInd,unionPtcp)) % nonexistence of errors
        
        % check the existence of must postive
        nPos = length(Pos);
        
        for iPos=1:nPos
            
            % the union of the participation of other potential positive samles
            unionPtcpTmp = [];
            for q=1:nPos
                if q~=iPos
                    unionPtcpTmp = union(unionPtcpTmp,sampPtcp{q});
                end
            end
            
            % check capability of linear representation for determining
            % must-positive samples
            if all(ismember(sampPtcp{iPos},unionPtcpTmp))~=1
                MPos = union(MPos,Pos(iPos));
            end
        end
        
        % update the index set of potential positive samples
        Pos = setdiff(Pos,MPos);
        
    else % existence of error
        
        posIndNum = length(posInd);
        for iPos=1:posIndNum
            Pos = union(Pos,find(A(posInd(iPos),:)==1));
        end
        
    end
    
    % report results
    MNeg = setdiff((1:nSamp),union(Pos,MPos));
    
else
    % only one positive sample
%     nPos = length(Pos);
%     for iPos = 1:nPos
%         if all(ismember(sampPtcp{iPos},posInd)) && all(ismember(posInd,sampPtcp{iPos}))
%             MPos = Pos(iPos);
%             Pos = setdiff(Pos,Pos(iPos));
%             break;
%         end
%     end
%     MNeg = setdiff((1:nSamp)',union(MPos,Pos));
end


end