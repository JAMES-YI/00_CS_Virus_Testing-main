function [xLb,xUb] = obo_mm(varargin)
% This file implements the one-by-one minimzation-maximization (obo mm) algorithm for 
% recovering x from compressed measurements y:=Ax where
% x in [L,U]. More specifically, we solve the following two 
% linear programmings for each element of x,
% 
% min_x x_i
% s.t.  L_j <= (Ax)_j <= U_j, j=1,2,...,|x|
%       x>=0
% 
% max_x x_i
% s.t.  L_j <= (Ax)_j <= U_j, j=1,2,...,|x|
%       x>=0
% where L_j is the virus load corresponding to (ct value + CtValDev), and
% U_j is the virus load corresponding to (ct value - CtValDev)
% 
%
% input arguments
% - poolset, an object of class poolTest
% - CtValDev, deviation of CT value; a parameter; 
%
% output arguments
% - xLb, lower bound estimate of virus load
% - xUb, upper bound estimate of virus load
% 
% Created by JYI, 09/02/2020
% 
%
%% Check mode
% if no input arguments are provided, then perform testing.
if nargin==0
    
    % for correctness testing only
    load('poolset.mat');
    load('Params.mat');
    
elseif nargin==2
    
    poolset = varargin{1};
    Params = varargin{2}; 

else

    fprintf("INPUT ERRORS")
    
end

% 
%% Configuration parameters

CtValDev = Params.CtValDev;
runNum = poolset.runNum; 
poolCtVal = poolset.poolCtVal;
sampNum = poolset.sampNum;  
% VloadUb = poolset.VloadUb; % upper bound of virus load
% VloadLb = 0;

%% Virus load bounds computation

convertor = ct2vload(Params.virusID,Params);
convertor = convertor.datafit();

for i=1:runNum
    
    negPoolInd = find(poolset.poolStatus{i}==0);
    poolVloadUbTmp = convertor.vload_prd(poolCtVal{i} - CtValDev);
    poolVloadLbTmp = convertor.vload_prd(poolCtVal{i} + CtValDev);
    poolVloadUbTmp(negPoolInd) = 0;
    poolVloadLbTmp(negPoolInd) = 0;
    
    poolVloadUb{i} = poolVloadUbTmp;
    poolVloadLb{i} = poolVloadLbTmp;
    
end
clear i

%% One-by-one minimization-maximization decoding
fprintf('Performing obo-mm decoding...\n'); 

tic; 
for iRun=1:runNum
    
%     poolVloadTmp = poolVload{iTria};

    xLbTmp = zeros(sampNum,1);
    xUbTmp = zeros(sampNum,1); 
    
    if iscell(poolset.MixMat)
        MixMat = poolset.MixMat{iRun};
    else
        MixMat = poolset.MixMat;
    end

    ut = utils();
    dilution = ut.dilution(Params.virusID,MixMat);
    MixMat = MixMat ./ dilution;
    
    for iSamp=1:sampNum
        % fprintf('%d/%d sample\n',iSamp,sampNum);
        % minimization
        cvx_begin quiet
            variable x(sampNum,1)
            minimize(x(iSamp))
            subject to
                -MixMat*x <= - poolVloadLb{iRun};
                MixMat*x <= poolVloadUb{iRun};
                -x <= 0;
        cvx_end
        
        xLbTmp(iSamp) = x(iSamp); 
        Log.minStatus{iRun} = cvx_status;
        
        % maximization
        cvx_begin quiet
            variable x(sampNum,1)
            minimize(-x(iSamp))
            subject to
                -MixMat*x <= -poolVloadLb{iRun};
                MixMat*x <= poolVloadUb{iRun};
                -x <= 0; 
        cvx_end
        
        xUbTmp(iSamp) = x(iSamp);
        Log.maxStatus{iRun} = cvx_status;
        
    end
    
    xLb{iRun} = xLbTmp;
    xUb{iRun} = xUbTmp;
    
    fprintf('Run %d: minimization status %s, maximization status %s.\n',...
           iRun,Log.minStatus{iRun},Log.maxStatus{iRun});
    
end



clear iRun

tEnd = toc;
fprintf('Elapsed time for obo-mm decoding %8.2e seconds.\n',tEnd);


end