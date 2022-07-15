% This file is associated with main_CS.m, 
% and will allow a deep look at the failure case for signal recovery.
% The data including the sensing matrix, and the signal for which the recovery fails are
% contained in .mat files. The following files are required according to your needs.
% 
% Created by JYI, 10/14/2020
% 
%%

load('CS_16 by 40_Solver_L1_MIN_202010141234.mat');

A = saveData.MixMat;
failSig = saveData.failSig;

for iSig = 1:300
    close all;
    sampVal = failSig(:,iSig);
    poolVal = A*sampVal;

    % instantiate optimizer
    inData.poolVal = poolVal;
    inData.A = A;

    gnrParams.spst = 1;
    Optimizer = optimizer(inData,gnrParams);

    % L1_MIN minimizer
    L1MinParams = []; % parameters associated with L1_minimizer
    sampValEst = Optimizer.L1_min(L1MinParams);

    figure; hold on;
    plot(sampVal,'*');
    plot(sampValEst,'o');
    legend('Truth','Estimate');
    xlabel('Element Index'); ylabel('Element Value');
    
end