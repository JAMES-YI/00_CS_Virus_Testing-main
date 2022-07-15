function obj = supp_est(obj,Params)
% This function is to decode the infection status via decoding qualitative pooling
% results.
%
% Inputs
% - obj, instance of poolTest class
% - Params, return from config()
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

if strcmp(Params.suppEstMethod,'grpTest') % 
    fprintf('using group testing to estimate support set (without estimation for virus lower bound and upper bound)\n')
    for i = 1:obj.runNum
                
        if iscell(obj.MixMat) % the effective mixing matrices can be different for different runs if there is adaptive request for extra pooling results
            [MNeg,MPos,Pos] = suppEst_grpTest(obj.MixMat{i},obj.poolStatus{i},Params.posNumPrior);
        else % no adaptive request for extra pooling results, and the effective matrices are the same for all the runs
            [MNeg,MPos,Pos] = suppEst_grpTest(obj.MixMat,obj.poolStatus{i},Params.posNumPrior);
        end
        
        obj.sampMPos{i} = MPos;
        obj.sampMNeg{i} = MNeg;
        obj.sampPos{i} = Pos;
        
        tmpStatus = repmat('N',[obj.sampNum,1]);
        
        if ~isempty(MPos) tmpStatus(MPos,:) = repmat('P',[length(MPos),1]);
        end
        
        if ~isempty(Pos) tmpStatus(Pos,:) = repmat('U',[length(Pos),1]);
        end
        
        obj.sampStatus{i} = tmpStatus;
    
    end

elseif strcmp(Params.suppEstMethod,'oboMM') % via one-by-one minimization-maximization

    % - Solve one-by-one minimization-maximization to get
    %   virus load bound
    % - compute index sets of must-positive samples, must-negative
    %   samples, and potential positive samples; results from group
    %   testing are not used as priors;
    fprintf('using one-by-one minimization-maximization to estimate support set (with estimation for virus lower bound and upper bound)\n')
    
    [vloadLb,vloadUb] = obo_mm(obj,Params);

    for i=1:obj.runNum
            
        obj.VloadLb{i} = vloadLb{i};
        obj.VloadUb{i} = vloadUb{i};
        
        obj.sampMPos{i} = find(vloadLb{i} > Params.vloadMax);
        obj.sampMNeg{i} = find(vloadUb{i} < Params.vloadMin);
        dtmd = union(obj.sampMPos{i},obj.sampMNeg{i});
        obj.sampPos{i} = setdiff(1:obj.sampNum,dtmd);

        % determine status
        obj.sampStatus{i} = repmat('U',[obj.sampNum,1]);
        obj.sampStatus{i}(obj.sampMPos{i}) = 'P';
        obj.sampStatus{i}(obj.sampMNeg{i}) = 'N';
        
    end

end
    
   
end