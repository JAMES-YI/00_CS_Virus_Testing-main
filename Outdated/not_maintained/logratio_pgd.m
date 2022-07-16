function vload = logratio_pgd(data,varargin)
% This function solves
%     min_x sum_i |log(y_i) - log((Ax)_i)|
%     s.t.  x>= 0 
% via projected gradient descent.
% 
% - results from group testing are required; the x contains only the virus load for positive
%   samples
% - all the positive individual samples must have been accurately and
%   completely identified
% - stop criteria: (1) exceed the maximal number of iterations; (2)
%   difference between consecutive iterate solutions is below a threshold; 
% - ideally, for each group of data, we should choose a corresponding set
%   of parameters; it can be hard to find a group of parameters which can
%   work for different groups of data
% 
% Created by JYI, 09/10/2020
% Updated by JYI, 06/24/2022
% - the pgd algorithm in this file will no longer be maintained
%
%% data preprocessing and parameter configuration

MixMat = data.MixMat;
sampNum = data.sampNum; 
sampMPos = data.sampMPos;
poolVload = data.poolVload;

if nargin==1
    Params = varargin{1};
end

kept = find(poolVload>0);
MixMat = MixMat(:,sampMPos);
% poolVloadsub = poolVload(kept,1);

MaxIter = 10000; % recommended value 10000
MaxInit = 100; % initialization times
tol =1e-3; % recommended value 1e-3
stpType = 'SQ_SUMMABLE'; % recommended SQ_SUMMABLE
% 'CONST_STEP', 'CONST_DIST', 'SQ_SUMMABLE', 'NONSUM_DIMINISH'
data.a = 1; % recommended value 1 for SQ_SUMMABLE; recommended value 0.02 for NONSUM_DIMINSH
% when a is too small (0.001), the iterate cannot even move
data.b = 500; % recommended value 500 for SQ_SUMMABLE
% when b is too big (20000), the iterate cannot even move; 

data.gam = 0.015; % recommended value 0.015 for CONST_STEP; recommended value 0.005 for CONST_STEP

%%
vload = zeros(sampNum,1);
objOpt = Inf;
% vloadsubOpt = 0;
% iIterOPt = 0;

for iInit=1:MaxInit
    vloadsub = rand(length(sampMPos),1)*randsample([1,10,100,1000],1);
    objVal = [];

    for iIter=1:MaxIter

        vloadsub_prev = vloadsub; 
        grad = 0;
        objTmp = 0;

        for iPool=1:length(kept)
            poolTmp = kept(iPool);
            inProd = MixMat(poolTmp,:)*vloadsub;
            signVal = sign(inProd - poolVload(poolTmp));
            grad = grad + signVal * (1/inProd) * MixMat(poolTmp,:)';

            objTmp = objTmp + abs(log(poolVload(poolTmp) / inProd));
        end 

        data.grad = grad;
        data.iIter = iIter;
        eta = stp_rule(data,stpType); 

        objVal = [objVal,objTmp];
        vloadsub = min(max(vloadsub - eta*grad,0),2500);
        diff = norm(vloadsub-vloadsub_prev,2);
        % fprintf('Diff: %.4e\n',diff);
        if diff < tol 
            break;
        end
    end
    
    % track the optimal objective function value
    if objVal(end)<=objOpt
        vloadsubOpt = vloadsub;
        iIterOpt = iIter;
        diffOpt = diff;
    end
end

% 
if iIterOpt<MaxIter && diffOpt < tol
    % fprintf('PGD achieves a residual below %.3f within %d iterations\n',tol,iIter);
else
    fprintf('PGD reaches the maximal number of iterations %d\n',MaxIter);
end
    
vload(sampMPos,1) = vloadsubOpt;

% figure; 
% plot(objVal,'*-');
% xlim([0 MaxIter])

end
