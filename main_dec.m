function poolset = main_dec(preconfig)

% This file is to decode pooled sample results to obtain individual sample
% results.
% 
% - preconfig contains the following fileds
%   preconfig.MatSize
%   preconfig.solver
%   preconfig.virusID
%   preconfig.stageNum
%   preconfig.trialInd
%
% Creted by JYI, 20200823
% Updated by JYI, 20201004
% - add funcitonality for loading both the primary and secondary data
%   from the second stage
% - use new standard curve data for interpolation of ct value and virus
% load
% 
% Updated by JYI, 10/26/2020
% - incorporate decoding for COVID-19 using bipartite graph of size 16 by
%   40
% - adaptive dilution factor, i.e., each pool has its own dilution factor
%   (1) matrix scaling
%   (2) in adaptive request scenario
%   (3) only for COVID-19 virus case
% - for MHV1, the dilution factor is always 4
% - Postprocessing of results returned in 'EXHAUSTIVE' decoding and stored
%   in file
%      Params.dfNameExhaustiveData
% - results file name format
%   16x40 Results Exp 1_updated_prep_SOLVER_JYI_dilution_10_20201028.xlsx
% - exhaustMode
%   (1) 'REGULAR': evaluate over every possible sparsity, and every possible support for each sparsity; essentially a combinatorial problem; 
%       for each possible case, solve a LSQ; the solution achieving the
%       smallest objective function value will be used; 
%   (2) 'NORMALIZED': the basic idea is the same as 'REGULAR'; however, we normalize the virus load difference in the LSQ optimization by the pool virus load
%   (3) 'SUCCESSIVE': the basic idea is the same as 'NORMALIZED'; however, the normalization is performed successively;
%   (4) 'MINPOS': the basic idea is the same as 'SUCCESSIVE'; however, we
%       minimize the virus load residual over only the positive pools; the
%       virus load of the negative pools is used as constraint
% 
% Updated by JYI, 11/06/2020
% - incorporate retest data for COVID-19 decoding 
%
% Updated by JYI, 11/20/2020
% - incorporate test data for MHV1 virus decoding; the new data should be
%   used as independent from previous MHV1 virus decoding data; the new
%   data is needed probably due to errors in the previous MHV1 virus test
%   data; correspondence by 'MHV1_2'
% - write results to excel file
%
% ToDo
% - documentation of architecture of the system
% - architecture optimization
% - factorization and packing
%
% Updated by JYI, 20220623
% - modularized configuration component
% - removed dependencies of the following solvers: 'LSQ_ANA','LSQ_ITER','LOGRATIO_GRID','LOGRATIO_PGD','MISMATCHRATIO_GRID','MISMATCHRATIO_SUCC', 
% 'MISMATCH'

%% Setup
% System Configuration
Params = config(preconfig);

% Data path configuration for first stage or inital request
[dataPath,Params] = init_dataPath(Params);

%% Load data from 1st stage of pooling
% Loading data in first stage test
poolset = poolTest(Params);
poolset = poolset.load_data(dataPath,Params.runNum);

% Duplicated groups handeling
poolset = poolset.dup_MixMat(dataPath);
poolset = poolset.dup_poolStatus(dataPath);

%% Loading data from subsquent stages of pooling
% - effective only when there are multiple stages of requests for pooling
% results
% - load pooling results from the first Params.stageNum stage
if Params.stageNum > 1
    subseqDataLoader = AdReqDataLoader(Params);

    for i=2:Params.stageNum

        dataPath = subseqDataLoader.config(i);
        poolset = subseqDataLoader.load(poolset,dataPath);

    end
end

%% Decoding

poolset = poolset.vload_dec(Params); % Quantitative decoding

%% Write results to excels
fprintf('Writing data to excel sheets...\n');
ResExporter(poolset,Params);
end
