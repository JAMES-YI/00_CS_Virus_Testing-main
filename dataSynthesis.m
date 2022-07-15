classdef dataSynthesis
%     This file defines a class for synthesizing data for evaluating performance of different virus testing approaches.
%
%     Created by JYI, 07/05/2022
%%
properties(Access=private)

    sampStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
    sampVload; % amount of virus load of each individual sample in [vlLb,vlUb]
    sampPos; % indices of positive samples
    config;

end

methods

    function obj = dataSynthesis(config)
        % config is a structure with fields 'sampNum', 'prevalence',
        % 'vlUb', 'vlLb'

        obj.config = config;
        obj = obj.gnrtTruth();

    end

    function obj = gnrtTruth(obj)
        % generate truth data
        sampNum = obj.config.sampNum;
        prevalence = obj.config.prevalence;
        
        rng(0); % for reporduction of experiments
        idxes = randsample(sampNum,round(sampNum*prevalence));
        sampStatus = zeros(sampNum,1); sampStatus(idxes) = 1;
        % sampStatus = binornd(1,prevalence,sampNum,1); 
        obj.sampStatus = sampStatus;

        sampVload = zeros(sampNum,1);
        idxes = find(sampStatus==1);
        vlRg = obj.config.vlUb - obj.config.vlLb;
        sampVload(idxes) = rand(size(idxes,1),1)*vlRg + obj.config.vlLb;
        obj.sampVload = sampVload;
        obj.sampPos = idxes;

        fprintf('Ground truth data have been generated.\n')
    end

    function [sampVload, sampStatus] = getTruth(obj)
        % get ground truth 
        % return [sampVload, sampStatus]
        sampVload = obj.sampVload;
        sampStatus = obj.sampStatus;

    end

end

end