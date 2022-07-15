% This file will set up the parameters for compressed sensing based virus
% testing, and perform testing. This file is also used to generate the
% experimental results for the following paper
% 
% [1] Waldstein, Kody A., Jirong Yi, Michael Myung Cho, Raghu Mudumbai, Xiaodong Wu, Steven M. Varga, and Weiyu Xu. 
% "Use of compressed sensing to expedite high-throughput diagnostic testing for COVID-19 and beyond." medRxiv (2021).
% 
%
% Created by JYI, 12/31/2020
% Updated by JYI, 06/23/2022
% - each run of this script will perform decoding from pooled results for
% one virus type, one trial, and one pooling matrix. Pooling results from
% multiple stage can be combined to improve the decoding results in each
% run. Original implementation supports multiple trials
% - each independent experiment contains results from the {stage 1, stage 2, ...} if adaptive request decoding is
% performed; 
% - totally 2 independent trial experiments are conducted for
% MHV-1; totally 1 independent trial experiment is done for COVID-19
% - use the results from the first n stages for decoding; 
% - 
% ToDo
% - loading primary data 
% - loading secondary data
% 
clc; clear; close all; 
system('taskkill /F /IM EXCEL.EXE');
t_start = tic;
%% Parameters for manually setup
config.virusID = 'COVID-19'; % 'MHV-1', or 'COVID-19'
config.trialInd = 1; % index of the independent experiments to consider; 
config.stageNum = 2; % fit to adaptive request decoding scheme; 

%% Parameters automatically setup
switch config.virusID
    case 'MHV-1'
        
        MatSizeList = [3,7;...
                       4,15;...
                       5,31]; % each row is a matrix size; binary parity check matrix of size R^(n times (2^n-1))
    case 'COVID-19'
        
        MatSizeList = [16,40]; 
        % each row is a matrix size; binary matrix constructed from Bipartite graph according to 
        % 
        % [1] Cho, Myung, Kumar Vijay Mishra, and Weiyu Xu. "Computable performance guarantees for compressed sensing matrices." 
        % EURASIP journal on advances in signal processing 2018, no. 1 (2018): 1-18.
end

config.solver = 'EXHAUSTIVE';


%% Decoding and generate full report
for iSize=1:size(MatSizeList,1) % decoding for eacg matrix size
    config.MatSize = MatSizeList(iSize,:); 
    poolset = main_dec(config);
end

fprintf("Completed decoding with %s seconds.\n",toc(t_start))


