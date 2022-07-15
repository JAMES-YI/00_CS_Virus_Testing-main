classdef GT_PNSK
    % This file defines the GT_PNSK class for group testing via multiple
    % stages. Two parameters are involved, i.e., divisor and stageMax, and
    % the initial pool size will be divisor^(stageMax-1). At the stageMax
    % stage, the pool size will be divisor^(stageMax-stageMax). In each
    % stage, the individual samples are pooled in disjoint pools, i.e., no
    % sample appear in two or more pools.
    % 
    % References
    % [1] Eberhardt, Jens Niklas, Nikolas Peter Breuckmann, and Christiane Sigrid Eberhardt. 
    % "Multi-stage group testing improves efficiency of large-scale COVID-19 screening." 
    % Journal of Clinical Virology 128 (2020): 104382.
    %
    % Created by JYI, 20220709, jirong.yi@hologic.com

    properties(Access=private)
        sampStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
        sampVload; % amount of virus load of each individual sample in [vlLb,vlUb]
        stage; % running index
        divisor; % scaling down factor for pool size
        stageMax; % maximal number of stages
    end

    properties(Access=public)

        poolStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
        poolVload; % amount of virus load of each individual sample in [vlLb,vlUb]
        poolMatrix; % pooling matrix used to get the pooling results
        sampStatusEst; % estimated individual sample status, i.e., negative if 0, or positive if 1
        sampVloadEst = []; % estimated of virus load of each individual sample in [vlLb,vlUb]
    end

    methods

        function obj = GT_PNSK(sampVload,sampStatus)

            % args
            % - sampVload, 1D array; ground truth sample virus load
            % - sampStatus, 1D array with elements 0 (negative or uninfected) or 1 (positive or infected); ground truth sample status

            obj.sampVload = sampVload;
            obj.sampStatus = sampStatus;
        end

        function obj = init_pooling(divisor,stageMax)
            % args
            % - divisor, int; scaling down factor of pool size
            % - stageMax, int; maximal stages to consider

            obj.stage = 1;
            
            poolSize = divisor^(stageMax-1);
            sampNum = length(obj.sampVload);
            rmd = rem(sampNum,poolSize); 
            poolNum = (sampNum - rmd) / poolSize + 1;

            obj.poolMatrix = zeros(poolNum,sampNum);
            for poolIdx=1:poolNum
                
                startIdx = (poolIdx-1)*poolSize + 1;
                if poolIdx<poolNum
                    endIdx = poolIdx*poolSize;
                else
                    endIdx = sampNum;
                end

                obj.poolMatrix(poolIdx,startIdx:endIdx) = 1;
            end

            obj.poolVload = obj.poolMatrix*obj.sampVload;
            obj.poolStatus = zeros(size(obj.poolVload));
            idxes = find(obj.poolVload > 0);
            obj.poolStatus(idxes) = 1;
        end

        function obj = decode(obj,config)
            % config;
            % decoding
            fprintf("To be implemented in the future.\n")

        end

        function obj = grpPool_Decode(obj)
            % first stage pooling
            
            
            [poolNum, sampNum] = size(obj.poolMatrix);
            obj.sampStatusEst = -1 * ones(sampNum,1);

            for poolIdx=1:poolNum
                if obj.poolStatus(poolIdx)==0

                    idxes = find(obj.poolMatrix(poolIdx,:)==1);
                    obj.sampStatusEst(idxes) = 0;

                end
            end

            fprintf("%d stages of pooling (pooling all samples in disjoint groups) has been completed.\n",obj.stage)

        end

    end

end