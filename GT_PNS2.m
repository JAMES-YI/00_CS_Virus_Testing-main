classdef GT_PNS2
    % Define a group testing class GT_P3S2, a two-stage group testing
    % approach. In the 1st stage, all the individual samples are divided
    % into different pools with each pool contains 3 individual samples,
    % and no individual sample can appear in two different pools. For pools
    % tested positive, 2nd stage is required, i.e., perform test for each
    % individual in the pool.
    % 
    % Created by JYI, 07/07/2022, jirong.yi@hologic.com

    properties(Access=private)
        sampStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
        sampVload; % amount of virus load of each individual sample in [vlLb,vlUb]
        stage;
        poolSize;
    end

    properties(Access=public)

        poolStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
        poolVload; % amount of virus load of each individual sample in [vlLb,vlUb]
        poolMatrix; % pooling matrix used to get the pooling results
        sampStatusEst; % estimated individual sample status, i.e., negative if 0, or positive if 1
        sampVloadEst = []; % estimated of virus load of each individual sample in [vlLb,vlUb]

    end

    methods

        function obj = GT_PNS2(sampVload,sampStatus)
            % args
            % - sampVload, 1D array; ground truth sample virus load
            % - sampStatus, 1D array with elements 0 (negative or uninfected) or 1 (positive or infected); ground truth sample status

            obj.sampVload = sampVload;
            obj.sampStatus = sampStatus;

        end

        function obj = init_pooling(obj,poolSize)
            % args
            % - poolSize, int; number of samples in each pool

            obj.poolSize = poolSize;
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
            % perform decoding

            obj = obj.grpPool_Decode();
            
            idxes = find(obj.sampStatusEst==-1);
            if ~isempty(idxes)
                obj = obj.idvdlPool_Decode(idxes);
            end

        end

        function obj = grpPool_Decode(obj)
            % first stage pooling
            
            obj.stage = 1;
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

        function obj = idvdlPool_Decode(obj,sampIdxes)
            % perform individual test
            % args
            % - sampIdxes, 1D array of integers; the set of sample indices
            % whose status cannot be determined in the first stage
            % 
    
            obj.stage = obj.stage + 1;
            numRows = length(sampIdxes);
            newRows = zeros(numRows, size(obj.poolMatrix,2));
            for rowIdx=1:numRows
                newRows(rowIdx,sampIdxes(rowIdx)) = 1;
            end
    
            obj.poolMatrix = [obj.poolMatrix; newRows];
            obj.poolVload = obj.poolMatrix*obj.sampVload;

            obj.poolStatus = zeros(size(obj.poolMatrix,1),1);
            idxes = find(obj.poolVload>0);
            obj.poolStatus(idxes) = 1;

            % reveal groundtruth
            obj.sampStatusEst(sampIdxes) = obj.sampStatus(sampIdxes);

            fprintf("%d stages of pooling (pooling all individual samples in the undetermined index set) has been completed.\n",obj.stage)
    
        end

        

    end

end