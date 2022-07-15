classdef GT_CSL1
    % Define a group testing class GT_CSL1, i.e., using standard compressed sensing L1 minimization for single-stage group testing. 
    %  min_x ||x||_1, s.t. Ax=y, x>=0
    % 
    % Created by JYI, 07/07/2022
    %%

    properties(Access=private)

    sampStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
    sampVload; % amount of virus load of each individual sample in [vlLb,vlUb]
    stage;
    
    end

    properties(Access=public)

    poolStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
    poolVload; % amount of virus load of each individual sample in [vlLb,vlUb]
    poolMatrix; % pooling matrix used to get the pooling results
    sampStatusEst; % estimated individual sample status, i.e., negative if 0, or positive if 1
    sampVloadEst; % estimated of virus load of each individual sample in [vlLb,vlUb]
    % 
    end

    methods

        function obj = GT_CSL1(sampVload,sampStatus)
            % args
            % - sampVload, 1D array; ground truth sample virus load
            % - sampStatus, 1D array with elements 0 (negative or uninfected) or 1 (positive or infected); ground truth sample status

            obj.sampVload = sampVload;
            obj.sampStatus = sampStatus;

        end

        function obj = pooling(obj,poolMatrix)
            % pool the samples according to a pooling matrix
            % args
            % - poolMatrix, 2D array with elemnts 0 or 1; specify the
            % participation of samples in pools; assume dilution 
            % assume: equal volume of individual samples are pooled; 
            %         after pooling, the pool is concentrated to have the same
            %         volume as the original pooled sample volume; (dilution
            %         factor 1)
            
            obj.stage = 1;
            obj.poolMatrix = poolMatrix;
            obj.poolVload = poolMatrix*obj.sampVload;
            obj.poolStatus = zeros(size(poolMatrix,1),1);
            idxes = find(obj.poolVload>0);
            obj.poolStatus(idxes) = 1;
            fprintf("Pooling has been completed.\n")
    
        end
    
        function obj = decode(obj,config)
            % perform L1 minimization to decode group testing results
            % args
            % - config, structure with fields specifying the experimental
            % configurations
            % the sampVloadEst and sampStatusEst will be determined
            
            data.MixMat = obj.poolMatrix;
            data.poolVload = obj.poolVload;
            data.poolStatus = obj.poolStatus;
            data.sampNum = size(obj.poolMatrix,2);
            
            optim = optimizers();
            obj.sampVloadEst = optim.L1_MIN(data,0);
            obj.sampStatusEst = zeros(size(obj.sampVloadEst));
            pstvIdxes = find(obj.sampVloadEst > config.vlLb);
            obj.sampStatusEst(pstvIdxes) = 1;
        end

    end

end