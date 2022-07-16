function Params = config(preconfig)
% This file will set up the configurations for compressed sensing based decoding system, 
% and the returned structure params will be used to instantiate an object of poolTest class.
% 
% - experiments architecture
% for virusID=['MHV-1','COVID-19']
%     for triaID=1:2
%         for runID=1:7
%             for dupID=1:2
%                for stageID=1:6
%                end
%             end
%         end
%     end
% end
% Created by JYI, 06/23/2022
%%

 
Params.posNumPrior = 0; % 1 (only one is positive) or 0 (not specify the number of positives); default 0
Params.suppEstMethod = 'oboMM'; % via group testing if 'grpTest', or one-by-one minimization-maximization if 'oboMM'

% Parameters associated with I/O and data
Params.tmStamp = datestr(now,'yyyymmddHHMM');
Params.dfNameExhaustiveData = sprintf('ExhaustiveData%s.mat',Params.tmStamp);
Params.MatSize = preconfig.MatSize; 
Params.userID = 'JYI';
Params.vloadMin = 1e-6; % minimal virus load achievable by positive samples; recommended to be 1e-6;
% if the estimated virus upper bound is less than Params.vloadMin in the
% oo_mm, we will treat it as negative
Params.vloadMax = 1e-6; % minimal virus load achievable by positive samples; recommended to be 1e-6;
% if the estimated virus lower bound is greater than Params.vloadMin in the
% oo_mm, we will treat it as negative

% Parameters associated with optimizer
Params.solver = preconfig.solver; % 'EXHAUSTIVE', 'L1_MIN'
Params.earlyTolCtVal = 1.5; % for 'EXHAUSTIVE' solver only; should not be too big or too small; recommended to be (0.5,2]; default 1.5

% Parameters associated with virus
Params.virusID = preconfig.virusID; % 'MHV-1', or 'COVID-19'
Params.trialInd = preconfig.trialInd; % index of the independent experiments to consider; each independent experiment contains
% results from the {stage 1, stage 2, ...} if adaptive request decoding is
% performed; trialInd (which is actually the number of experiments) 
% and the trialNum (which is actually the number of runs) are completely different;
% totally 2 independent trial experiments are conducted for
% MHV-1; totally 1 independent trial experiment is done for COVID-19
Params.stageNum = preconfig.stageNum; % fit to adaptive request decoding scheme; 
% use the results from the first n stages for decoding; 
% maximal value for MHV-1 is 3 in trail 1; maximal value for MHV-1 is 2 in
% trial 2; maximal value for COVID-19 is 2 in trial 1;
Params.ctValType = preconfig.ctValType;

switch Params.virusID
    case 'MHV-1'
        Params.CtValDev = 2; % required for OBO_MM decoding method only; 
        % suggested to be in [2,3.5]; default value 2; too small
        % value will lead to infeasibility, while too large value will
        % lead to loose estimate
        Params.exhaustMaxIterSucc = 1; % for 'EXHAUSTIVE' solver in 'SUCCESSIVE' mode only; 
        % 100 iterations is too big and numerical issues can occur; default 1
        Params.MaxIterSucc = 50; % for 'MISMATCHRATIO_SUCC' only; 
        % default 50; number of iterations for successive mismatch ratio minimization does 
        % not affect much the estimation, i.e., 1 and 100 can achive
        % comparable results; by the define condition for convergence,
        % the algorithm usually converges in roughly 10 iterations
    case 'COVID-19'
        Params.CtValDev = 2;
        Params.exhaustMaxIterSucc = 1; % for 'EXHAUSTIVE' solver in 'SUCCESSIVE' mode only; 
        % 100 iterations is too big and numerical issues can occur; default 1
        Params.MaxIterSucc = 50; % for 'MISMATCHRATIO_SUCC' only; 
            % default 100; large value does not bring much benefits; 
end

% - solvers based on grid search
Params.radius = 1; % only used in decoding methods based on grid search;

%% Automatical setup of parameters
% Parameters associated with writing results report
% ToDo: COVID-19 case

Params.optExcelID = sprintf('outputs/%s_Trial-%d_Stage-%d_duplicate-%s_Decoded_%s.xlsx',...
                            Params.virusID,Params.trialInd,Params.stageNum,Params.ctValType,Params.userID); 
Params.poolNum = Params.MatSize(1); 
Params.sampNum = Params.MatSize(2); 
Params.MatInfo = sprintf('%d by %d',Params.poolNum,Params.sampNum);



end