function vload = mismatchratio_pgd(data,varargin)
% This file is to solve the following optimization 
% min_x sum_{i in P} |y_i - (Ax)_i|/(Ax)_i
% s.t.  (Ax)_j = 0, j in N
%       x >= 0 
% Or
% min_x sum_{i in P} |y_i - (Ax)_i|/(Ax)_i
% s.t.  x >= 0 
% via projected subgradient algorithm
%
% - P, index set of positive pools
% - N, index set of negative pools
% - the results from group testing are required; all the positive samples
%   must have been accurately and completely identified;
% - the algorithm will only update the virus load of positive samples, and
%   the virus load of negative samples will directly be set to 0
% 
% Created by JYI, 09/15/2020
% Updated by JYI, 06/24/2022
% - the projected subgradient algorithm will no longer be maintained
%
%% Data preparation and parameter setup

sampMPos = data.sampMPos;
poolVload = data.poolVload; 
MixMat = data.MixMat;
sampNum = data.sampNum;

if nargin==1
    Params = varargin{1};
end


poolPos = find(poolVload>0);
poolNeg = find(poolVload==0);
MixMat = MixMat(:,sampMPos);

objFun = @(x) norm((poolVload(poolPos) - MixMat(poolPos,:)*x) ./ (MixMat(poolPos,:)*x),1);
objVal = [];

MaxIter = 5000;
data.gam = 0.015;
data.a = 1;
data.b = 500;


%% 
vload = zeros(sampNum,1);

x_sub = rand(length(sampMPos),1)*1000;
% objTmp = objFun(x_sub);
% objVal = [objVal,objTmp];

for Iter=1:MaxIter
    
    % subgradient
    grad = 0;
    for iPos=1:length(poolPos)
        
        poolPosTmp = poolPos(iPos);
        inProd = MixMat(poolPosTmp,:)*x_sub;
        signCoeff = sign(inProd-poolVload(poolPosTmp));
        grad = grad + signCoeff*(poolVload(poolPosTmp) / inProd^2)*MixMat(poolPosTmp,:)';
        
    end
    
    % update solution
    eta = stp_rule(data,stpType);
    x_sub = x_sub - eta*grad;
    x_sub = min(max(x_sub,0),2500);
    
    % Update objective function
    objValTmp = objFun(x_sub);
    objVal = [objVal,objValTmp];
    
    
end

vload(sampMPos) = x_sub;

figure; 

plot(objVal,'*-');



%%



end