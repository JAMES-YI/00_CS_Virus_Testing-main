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
% Created by JYI, 20200823
% Updated by JYI, 20201004
% Updated by JYI, 10/26/2020
% Updated by JYI, 11/06/2020
% Updated by JYI, 11/20/2020
% Updated by JYI, 06/23/2022

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

poolset = poolset.vload_dec(Params);
ResExporter(poolset,Params);
end
