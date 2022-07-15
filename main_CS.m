% function main_CS(MatInfo)
% This file perform compressed sensing using synthesized sample data for the mixing matrix
% 
% 
% - The following data is required
%   bp_A_25_100_1InCol_5.mat
%   A16_40_from_main.mat
%   'BestBetakBipartitle16x40.mat'
% - The range of the ground truth is set to be [0,3000] which corresponds
%   the virus load range in practice of virus testing. Though it is used
%   for generating data, only the nonnegativity will be used as a prior for
%   recovery.
% - No noise or outlier appeared
% 
% Created by JYI, 10/08/2020
%
clc; close all; rng(0)
%% Load data and parameters setup

MatSize = '24 by 60'; % '16 by 40', '25 by 100', '24 by 60'
maxVal = 3e3; % maximal value possible; 
resTol = 1e-3; % residual tolerance
solver = 'L1_MIN'; % 'L1_MIN', 'MismatchRatio_SUCCMIN', 'EXHAUST'
MatGenType = 'typestry'; % 'bipartite' or 'bernoulli' or 'typestry'; only for the matrix of size 16 by 40;
bpMatRowInd = 22;

% load measurement or mixing matrix
switch MatSize
    
    case '25 by 100'
        load('bp_A_25_100_1InCol_5.mat');
        fName = sprintf('CS_%s_Solver_%s_%s.mat',...
            MatSize,solver,datestr(now,'yyyymmddHHMM'));
        figName = sprintf('CS_%s_Solver_%s_%s.fig',...
            MatSize,solver,datestr(now,'yyyymmddHHMM'));
        
    case '16 by 40'
        switch MatGenType
            case 'bernoulli'
                load('A16_40_from_main.mat');
                fName = sprintf('CS_%s_%s_Solver_%s_%s.mat',...
                    MatGenType,MatSize,solver,datestr(now,'yyyymmddHHMM'));
                figName = sprintf('CS_%s_ %s_Solver_%s_%s.fig',...
                    MatGenType,MatSize,solver,datestr(now,'yyyymmddHHMM'));
                
            case 'bipartite'
                load('BestBetakBipartitle16x40.mat');
                A = BestBetaK(bpMatRowInd,4:end);
                A = reshape(A,[16,40]);
                fName = sprintf('CS_%s_%s_Solver_%s_%s.mat',...
                    MatGenType,MatSize,solver,datestr(now,'yyyymmddHHMM'));
                figName = sprintf('CS_%s_ %s_Solver_%s_%s.fig',...
                    MatGenType,MatSize,solver,datestr(now,'yyyymmddHHMM'));
                
            case 'typestry'
                load('typestryData.mat');
                A = typestryData.A16b40;
                fName = sprintf('CS_%s_%s_Solver_%s_%s.mat',...
                    MatGenType,MatSize,solver,datestr(now,'yyyymmddHHMM'));
                figName = sprintf('CS_%s_ %s_Solver_%s_%s.fig',...
                    MatGenType,MatSize,solver,datestr(now,'yyyymmddHHMM'));
        end
        
    case '24 by 60'
        load('typestryData.mat');
        A = typestryData.A24b60;
        fName = sprintf('CS_%s_Solver_%s_%s.mat',...
            MatSize,solver,datestr(now,'yyyymmddHHMM'));
        figName = sprintf('CS_%s_Solver_%s_%s.fig',...
            MatSize,solver,datestr(now,'yyyymmddHHMM'));
end
    
% parameter setup
[nRow,nCol] = size(A);
OneInCol = sum(A(:,1));
trialNum = 100;

MismatchRatioSUCCMINParams.mismatchratio_norm = 'L2'; 
MismatchRatioSUCCMINParams.MaxIter = 3; % no guidance for a good choice of this
MismatchRatioSUCCMINParams.tol = 1e-3; % relative error tolerance in the successive optimization

Params.posNum = 0; % number of positives unknown;

gnrParams.MatSize = MatSize;
gnrParams.MatGenType = MatGenType;
gnrParams.maxVal = maxVal;
gnrParams.resTol = resTol;
gnrParams.solver = solver;
gnrParams.bpMatRowInd = bpMatRowInd;


%%

rng('shuffle'); % use the current time as the random seed

maxSpst = 0.2*nCol;
succRate = zeros(maxSpst,1);
spstArr = 1:maxSpst;
resArr = zeros(maxSpst,trialNum);
failSig = [];

for spst=spstArr
    
    succNum = 0;
    fprintf('Number of positive samples: %d\n',spst);
    
    for iTrial=1:trialNum
        
%         if spst=20 && iTrial==40
%             fprintf('spst, %d; iTrial, %d\n',spst,iTrial);
%         end
        
        % ground truth samples
        spstInd = randsample(nCol,spst);
        sampVal = zeros(nCol,1);
        sampVal(spstInd,1) = rand(spst,1)*maxVal;
        
        % obtain measurements
        poolVal = A*sampVal;
        
        % instantiate optimizer
        inData.poolVal = poolVal;
        inData.A = A;
        
        gnrParams.spst = spst;
        Optimizer = optimizer(inData,gnrParams);
        
        switch solver
            
            case 'L1_MIN'
        
                %% L1 minimization
                L1MinParams = []; % parameters associated with L1_minimizer
                sampValEst = Optimizer.L1_min(L1MinParams);
        
            case 'MismatchRatio_SUCCMIN'
        
                %% Mismatch ratio successive minimization using L2 norm
                % - why does the successive minimization takes so long
                sampValEst = Optimizer.MismatchRatio_SUCCMIN(MismatchRatioSUCCMINParams);

            case 'EXHAUST'
                
                %% Exhaustive search
                % - get all the combinations for choosing spst elements from 1:nCol
                % - each combination corresponds to a potential support set
                % - for each support set, we define
                %   Asub: consists of columns whose index is in the spst
                %   elements
                %   xsub: consists of elements whose index is in the spst
                %   elements
                % - for each support set, we solve
                %    min_xsub(1/2) * ||Asub*xsub - poolVal||_2^2
                %    s.t.    xsub >= 0
                %    or solve (Asub^T*Asub)*xsub = Asub^T*y
                % - the final solution will be taken as the one which
                %   achieves the smallest error
                
                suppCombs = nchoosek(1:nCol,spst);
                suppCombsNum = length(suppCombs);
                sampValEst = zeros(nCol,1);
                
                for iComb=1:suppCombsNum
                    
                    suppTmp = suppCombs(iComb,:);
                    MatCoeff = A(:,suppTmp)'*A(:,suppTmp);
                    xsub = linsolve(MatCoeff,A(:,suppTmp)'*poolVal);
                    
                    sampValTmp = zeros(nCol,1);
                    sampValTmp(suppTmp,1) = xsub;
                    
                    if norm(sampVal-sampValTmp,2) < norm(sampVal-sampValEst,2)
                        sampValEst = sampValTmp;
                    end
                    
                end
        end
        
        %% performance evaluation
        res = norm(sampVal - sampValEst,2) / norm(sampVal,2);
        resArr(spst,iTrial) = res;
        if res < resTol
            
            succNum = succNum+1; % count successful group testing
        else
            
            failSig = [failSig,sampVal];
            
        end
        
    end
    
    succRate(spst) = succNum / trialNum;
    
end

%% Save data and report results

saveData.MixMat = A;
saveData.succRate = succRate;
saveData.spstArr = spstArr;
saveData.resArr = resArr;
saveData.failSig = failSig;
save(fName,'saveData');

fig = figure; 
plot(succRate,'-*');
xlabel('# of positives'); ylabel('Success rate');
saveas(fig,figName);

% end

