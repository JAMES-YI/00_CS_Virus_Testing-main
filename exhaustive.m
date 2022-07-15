function [vload,otptData] = exhaustive(data,Params)
% 
% This file perform exhaustive search for decoding by the following steps
% - set an upper bound for sparsity, i.e., MaxSpst; 
%   suggested to be no greater than 10% of total number of samples;
%   for each possible choice of sparsity spst, form all the possible support sets;
%   for each support set, reduce the problem to be an constrained least
%   square;
%   final solution will be the one achieving the smallest objective function value
% 
% Created by JYI, 10/27/2020
%
% Modified by JYI, 11/02/2020
% - use weighted least square for normalization purpose; 
%   associated with 'NORMALIZED'
% - use successively weighted least square for normalization purpose; 
%   associated with 'SUCCESSIVE'
% - the LSQ without normalization is associated with 'REGULAR'
% - change the maximal sparsity from 0.1*sampNum to length(suppSet)
% 
% Modified by JYI, 11/22/2020
% - fixed bugs when performing exhustive search in NORMALIZED mode; the
%   round(0.1*sampNum) can exceed the size of potential support set; bug is
%   fixed by using min(round(0.1*sampNum),length(suppSet))
% - for all possible solutions from exhaustive search, use the sparsest
%   solution rather than the one achieving smallest objective function value
%   as the final solution; elements greater than tauNonzero=1e-5 will be
%   treated as nonzero
% 
% Modified by JYI, 11/28/2020
% - add new component for encouraging sparse solution; start with the
%   sparset solution, and we stop if we get an acceptable solution.
%   Otherwise, we continue search for denser solution; early stopping is
%   recommended to be performed in ct value domain rather than the virus
%   load domain due to the large scale in virus load domain
% 
% Updated by JYI, 07/08/2022, jirong.yi@hologic.com
% - removed successive minimization component and its dependencies

%% 
tic

MixMat = data.MixMat;
poolVload = data.poolVload; poolCtVal = data.poolCtVal; poolStatus = data.poolStatus;
[poolNum,sampNum] = size(MixMat);
suppSet = data.suppSet;
exhaustMode = Params.exhaustMode;
exhaustMaxIterSucc = Params.exhaustMaxIterSucc; 

vloadThreshold = 1; % viral load threshold for determining positive and negatives; 
ctValThreshold = 40; % ct value threshold for determining positive
tauNonzero = 1e-5;
earlyTol = 1e-3; % as long as we find a solution with relative residual less than this, we terminate the searching
earlyTolCtVal = Params.earlyTolCtVal; 

switch exhaustMode
    case 'REGULAR'
        maxSpst = min(round(0.1*sampNum),length(suppSet));
    case 'NORMALIZED'
        maxSpst = min(round(0.1*sampNum),length(suppSet));
    case 'SUCCESSIVE'
        maxSpst = length(suppSet);
    case 'MINPOS'
        maxSpst = length(suppSet);
end

priorSpst = 2; % if you know the prior sparsity
epsilon = 1e-16;
tol = 1e-3; % tolerance for stopping successive LSQ 
objVal = Inf;
spstBest = Inf;
vloadList =[]; % store each possible load solutions
objValList = []; % store objective function value for each possible solution
ctValList = []; % store the estimated pool ct values
poolCtValResL2List = []; % store the L1 norm of all the residuals in pool ct values for all solutions
poolCtValResL1List = []; % store the L2 norm of all the residuals in pool ct values for all solutions

for spst = 1:maxSpst
    
%     if spst>priorSpst
%         break;
%     end
    
    suppCombs = nchoosek(suppSet,spst);
    suppCombsNum = size(suppCombs,1);
    fprintf('Sparsity: %d/%d\n',spst,maxSpst);
    
    for iSupp=1:suppCombsNum
        
        % fprintf('Combination: %d/%d\n',iSupp,suppCombsNum);
        supp = suppCombs(iSupp,:);
        
        %% pattern consistance check
        % - skip the support set if the positive pattern of the pools can not be covered by that of the resultant
        %   columns of the mixing matrix OR if the negative pattern of the pools has index in the positive
        %   pattern of the resultant columns of the mixing matrix
        
%         posPoolPatt = find(poolStatus==1);
%         negPoolPatt = find(poolStatus==0);
%                 posMatPatt = [];
%                 
%                 for suppInd=1:length(supp)
%                     posMatPatt = union(posMatPatt, find(MixMat(:,supp(suppInd))>0));
%                 end
%                 % negMatPatt = setdiff(1:poolNum,posMatPatt);
%                 
%                 skip = ~all(ismember(posPoolPatt,posMatPatt)) || sum(ismember(negPoolPatt,posMatPatt));

        poolStatusEst = sum(MixMat(:,supp),2)>0;
        skip = ~all(poolStatusEst==poolStatus);
        if skip
                   continue; 
        else
            
            Patt = [poolStatus';poolStatusEst'];
            fmt = [repmat('%4d ', 1, size(Patt,2)-1), '%4d\n'];
            fprintf('Support set matched\n')
            fprintf(fmt, Patt.');
            
            
        end
        
        %% Search for solution
        switch exhaustMode
            case 'REGULAR'
                % data is not normalized
                cvx_begin quiet
                    variable vloadSub(spst,1)
                    minimize(norm(MixMat(:,supp)*vloadSub-poolVload,2))
                    subject to
                        -vloadSub <= 0
                cvx_end
                
            case 'NORMALIZED'
                % data is normalized
                cvx_begin quiet
                    variable vloadSub(spst,1)
                    minimize(norm( diag(1 ./ (sqrt(poolVload)+epsilon)) * (MixMat(:,supp)*vloadSub-poolVload),2))
                    subject to
                        -vloadSub <= 0
                cvx_end
          
                
            case 'MINPOS'
                % - minimize over only positive pools; negative pools are used as constraints
                
                posPoolPatt = find(poolStatus==1);
                negPoolPatt = find(poolStatus==0);
                
                vloadSub = MixMat(:,supp)'*poolVload; % initialization
                w = poolVload;
                
                for iter=1:exhaustMaxIterSucc
                    
                    vloadSubPre = vloadSub;
                    cvx_begin quiet
                        variable vloadSub(spst,1)
                        minimize(norm( diag(1 ./ sqrt(w(posPoolPatt,1))) * (MixMat(posPoolPatt,supp)*vloadSub-poolVload(posPoolPatt,1)),2))
                        subject to
                            -vloadSub <= 0
                            MixMat(negPoolPatt,supp)*vloadSub == 0
                    cvx_end
                    
                    if norm(vloadSubPre-vloadSub,2)< tol
                        break;
                    end
                    
                    w = MixMat(:,supp)*vloadSub;
                    
                end
                
                
        end
        
        if cvx_optval<objVal
            objVal = cvx_optval;
            vload = zeros(sampNum,1);
            vload(supp,:) = vloadSub;
            bestID = size(vloadList,2)+1;
            % spstBest = spst;
%             fprintf('Best solution found so far has sparsity: %d\n',spstBest);
        end
        
        % calculate ct Value of pools
        vloadTmp = zeros(sampNum,1);
        vloadTmp(supp,:) = vloadSub;

        convertor = vload2ct(Params.virusID,Params);
        convertor = convertor.datafit();
        ctVal = convertor.ctVal_prd(MixMat*vloadTmp);

        % calculate L1 & L2 residual for each solution
        ctValResL1 = norm(ctVal-poolCtVal,1);
        ctValResL2 = norm(ctVal-poolCtVal,2);
        
        % save all the data
        vloadList = [vloadList,vloadTmp];
        objValList = [objValList,cvx_optval];
        ctValList = [ctValList,ctVal];
        poolCtValResL1List = [poolCtValResL1List,ctValResL1];
        poolCtValResL2List = [poolCtValResL2List,ctValResL2]; 
        
        
        %% early stopping
        % - if for every pool, the residual between the observed ct value and the predicted ct value is less than
        %   earlyTolCtVal, then we stop the exhaustive search and use the solution we have found as the final solution
        
        ctValResEle = abs(ctVal-poolCtVal) < earlyTolCtVal;
        if prod(ctValResEle)==1
            break;
        end
%         res = norm(MixMat(:,supp)*vloadSub-poolVload,2);
%         resRel = res / norm(poolVload,2);
%         if resRel<earlyTol
%             break;
%         end
    end
    
    if exist('ctValResEle','var')
        if prod(ctValResEle)==1
                break;
        end
    end
    
end

% spstSolu = sum(find(vloadList>tauNonzero),1); % compute the sparsity of each solution;
% [~,indMin] = min(spstSolu);
% vload = vloadList(:,indMin);
% try
% 
%     
% catch
%     keyboard
% end

toc

%% Save intermediate data as suggested by WXU, modified by JYI, 11/04/2020
% - sampVloadList: (1) set of recovered sample virus load; (2) each
%   column represents a recovered solution;
% - sampSignPatternList: (1) set of sign patterns of the estimated
%   sample virus load; (2) each column represent the pattern of a
%   particular recovered solution; (3) a sample will be claimed as
%   positive if it has a virus load greater than 1; 
% - poolCtValList: (1) set of the pool ct values corresponding to each
%   recovered solution; (2) each column represents the pool
%   corresponding for one recovered solution; (3) a ct value of 50
%   means negative;
% - poolCtValResL1List: (1) L1 norm between the estimated pool ct
%   values and the ground truth ct values; (2) each element
%   corresponding to the L1 norm between a particular estimated pool ct value
%   and the ground truth ct values; 
% - poolCtValResL2List: (1) L2 norm between the estimated pool ct
%   values and the ground truth ct values; (2) each element
%   corresponding to the L2 norm between a particular estimated pool ct value
%   and the ground truth ct values; 
% - poolCtVal: (1) ground truth of the pool ct values provided by Kody;
% - poolCtValDiff: (1) absolute value of the difference between the estimated pool ct values
%   and the ground truth ct values; (2) each column represents the
%   absolute value of the difference between the a particular estimated
%   pool ct value and the ground truth pool ct values; (3) within each
%   column, each element represents the absolute value of the
%   difference between a particular estimated ct value of a pool and
%   the ground truth ct value of the same pool; 
% - poolSignPatternList: (1) set of sign patterns of the estimated
%   sample virus load; (2) each column represent the pattern of a
%   particular recovered solution; (3) a sample will be claimed as
%   positive if it has a ct value less than 40; 
% - objValList: (1) objective function values achieved by possible
%   solutions; (2) each element represent the optimal objective
%   function value achieved by a particular solution;
% - bestID: (1) the index of the solution which achieves the smallest
%   objective function value; 
% 
% - 

% sample data
otptData.sampVloadList = vloadList;
% otptData.sampSignPatternList = vloadList > vloadThreshold; % for COVID-19
% only

% pool data
otptData.poolCtValList = ctValList;
otptData.poolCtValResL1List = poolCtValResL1List;
otptData.poolCtValResL2List = poolCtValResL2List;
otptData.poolCtVal = poolCtVal;
otptData.poolCtValDiff = abs(ctValList - poolCtVal);
% otptData.poolVloadTruth = poolVload;
otptData.poolSignPatternList = ctValList< ctValThreshold;

% other data
otptData.objValList = objValList;
otptData.bestID = bestID;


end