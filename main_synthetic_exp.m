% Perform comparisons of different decoding methods for virus testing
% 
% Created by JYI, 07/05/2022, jirong-yi@uiowa.edu, jirong.yi@hologic.com
%
clear; close all; 
%% 
config.decodeMethod = 'PNS2'; % 'CSL1', 'Certified', 'PNS2' 
config.poolNum = 5;
config.sampNum = 22;
config.prevalence = 0.1;
config.vlLb = 1e0; % virus lower bound of positive samples when synthesize ground truth data
config.vlUb = 1e6; % virus upper bound of positive samples when synthesize ground truth data
config.fixedPoolSize = 1;
if config.fixedPoolSize
    config.poolSize = 3;
else
    config.poolSize = ceil(config.sampNum/config.poolNum); % used in 'PNS2' and 'PNSK'
end
config.matrixSize = sprintf('%d by %d',config.poolNum,config.sampNum);
config.VirusType = 'SYNTHETIC'; % 'MHV-1', 'COVID-19', 'SYNTHETIC'
%% 
ds = dataSynthesis(config);
mmtx = mixing_matrices(config.VirusType,config.matrixSize,true);
A = mmtx.matrix;

[sampVload, sampStatus] = ds.getTruth();

if strcmp(config.decodeMethod,'CSL1')
    decoder = GT_CSL1(sampVload,sampStatus);
    decoder = decoder.pooling(A);
    decoder = decoder.decode(config);
    sampVloadEst = decoder.sampVloadEst; sampStatusEst = decoder.sampStatusEst;
elseif strcmp(config.decodeMethod,'Certified')
    decoder = GT_Certified(sampVload,sampStatus);
    decoder = decoder.init_pooling(A);
    decoder = decoder.decode(config);
    sampVloadEst = decoder.sampVloadEst; sampStatusEst = decoder.sampStatusEst;

elseif strcmp(config.decodeMethod,'PNS2')
    decoder = GT_PNS2(sampVload,sampStatus);
    decoder = decoder.init_pooling(config.poolSize);
    decoder = decoder.decode(config);
    sampVloadEst = decoder.sampVloadEst; sampStatusEst = decoder.sampStatusEst;
end

figure; hold on; xlabel('Sample Index'); ylabel('Sample Virus Load');
plot(sampVload,'-*','DisplayName','Truth');
plot(sampVloadEst,'-o','DisplayName','Estimate');
legend();

%% evaluation metrics calculation
dataEval.sampVload = sampVload;
dataEval.sampStatus = sampStatus;
dataEval.sampVloadEst = sampVloadEst;
dataEval.sampStatusEst = sampStatusEst;
dataEval.poolMatrix = decoder.poolMatrix;
evaluator = evalStatistics(dataEval);
[efccy,sstvt,spcfct] = evaluator.getResults();

if strcmp(config.decodeMethod,'CSL1') || strcmp(config.decodeMethod,'Certified')
    vloadResidual = norm(sampVload-sampVloadEst,2);
    fprintf("Performance of %s: virus load estimation residual %.2e, sensitivity %.3f, specificity %.3f, efficiency %.3f (tests/sample)\n",...
        config.decodeMethod,vloadResidual,sstvt,spcfct,efccy);
else
    fprintf("Performance of %s: sensitivity %.3f, specificity %.3f, efficiency %.3f (tests/sample)\n",...
        config.decodeMethod,sstvt,spcfct,efccy);
end