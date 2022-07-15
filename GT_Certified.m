classdef GT_Certified
    % Define a group testing class GT_Certified, a certified quantitative group testing
    % approach. In the 1st stage, all the individual samples are pooled according to a carefully-designed 
    % pooling matrix. An one-by-one minimization-maximization approach is used to estimate the virus load 
    % lower and upper bounds. The virus load bounds will be used to determine three index sets, 
    % i.e., POS (set of potentially positive sample indices), MPOS (set of positive sample indices), MNEG
    % (set of negative sample indices). If POS is nonempty, we pool all the samples in POS together in the second stage.
    % If the pool in the second stage is positive, we then test each individual in the pool for the third stage.
    % Once all POS is empty, we perform mismatch ratio minimization to get the virus load of each individual sample for
    % certification purpose. If sample stauts and sample virus load from the mismatch ratio minimization are consistent with 
    % the sample status and the sample virus load bounds in the one-by-one minimization-maximization, then we report the final results. Otherwise, 
    % we reporting warning or errors. 
    % 
    % Created by JYI, 07/07/2022, jirong-yi@uiowa.edu, jirong.yi@hologic.com
    %
    %% 

    properties(Access=private)

    sampStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
    sampVload; % amount of virus load of each individual sample in [vlLb,vlUb]
    epsilon = 1e-6; % for avoid numerical errors or residual tolerance
    stage;
    certified = 0; % whether or not the decoded results are certified
    
    end

    properties(Access=public)

    poolStatus; % groundtruth individual sample status, i.e., negative if 0, or positive if 1
    poolVload; % amount of virus load of each individual sample in [vlLb,vlUb]
    poolMatrix; % pooling matrix used to get the pooling results
    sampVloadEst; % estimated of virus load of each individual sample by solving a certificating mismatch minimization problem
    
    % obo_mm decoding results
    sampVloadLb; % estimated of virus load lower bound of each individual sample 
    sampVloadUb; % estimated of virus load upper bound of each individual sample
    sampStatusEst; % estimated individual sample status, i.e., negative if 0, or positive if 1
    sampPos; % POS (set of potentially positive sample indices)
    sampMPos; % MPOS (set of positive sample indices), 
    sampMNeg; % MNEG (set of negative sample indices); obo_mm ends only if sampNeg is empty
    
    % certifying results
    sampStatusCert; 
    end

    methods

        function obj = GT_Certified(sampVload,sampStatus)
            % args
            % - sampVload, 1D array; ground truth sample virus load
            % - sampStatus, 1D array with elements 0 (negative or uninfected) or 1 (positive or infected); ground truth sample status

            obj.sampVload = sampVload;
            obj.sampStatus = sampStatus;

        end

        function obj = init_pooling(obj,poolMatrix)
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
            % decode to get the results
            
            % perform obo_mm for decoding
            obj = obj.vloadBounds();
            obj = obj.status_obomm(config);
            
            % subsequent
            if ~isempty(obj.sampPos)
                obj = obj.subsetPool_Decode(obj.sampPos);
                if ~isempty(obj.sampPos)
                    obj = obj.idvdlPool_Decode(obj.sampPos);
                else
                    fprintf("The status of all the samples has been determined with positive sample indices %s.\n",num2str(obj.sampMPos))
                end
            else
                fprintf("The status of all the samples has been determined with positive sample indices %s.\n",num2str(obj.sampMPos));
            end

            % perform mismatch ratio minimization for certification
            obj = obj.certify(config);
            obj.visualization();

        end

        function obj = vloadBounds(obj)
            % update virus load upper and lower bounds
            data.MixMat = obj.poolMatrix;
            data.poolVload = obj.poolVload;
            data.poolStatus = obj.poolStatus;
            data.sampNum = size(obj.poolMatrix,2);

            optim = optimizers();
            [obj.sampVloadLb, obj.sampVloadUb] = optim.OBO_MM(data,0);
        end

        function obj = certify(obj,config)
            % certify the validity of the decoded results
            
            data.MixMat = obj.poolMatrix;
            data.poolVload = obj.poolVload;
            data.poolStatus = obj.poolStatus;
            data.sampNum = size(obj.poolMatrix,2);
            data.sampMPos = obj.sampMPos;
            data.epsilon = obj.epsilon;

            optim = optimizers();
            obj.sampVloadEst = optim.MMR_MIN(data,0);
            
            idxes = find(obj.sampVloadEst<config.vlLb);
            obj.sampVloadEst(idxes) = 0;
            obj.sampStatusCert = ones(size(obj.sampStatus));
            obj.sampStatusCert(idxes) = 0;

            idxesEst = sort(find(obj.sampStatusEst==1));
            idxesCert = sort(find(obj.sampStatusCert==1));
            if length(idxesEst) ~= length(idxesCert)
                ctfctStatus = 0;
            else
                ctfctStatus = sum(abs(idxesEst-idxesCert))==0;
            end
            
            ctfctLbViolation = sum(obj.sampVloadEst - obj.sampVloadLb < - obj.epsilon);
            ctfctLb = ctfctLbViolation == 0;
            ctfctUbViolation = sum(obj.sampVloadEst - obj.sampVloadUb > obj.epsilon);
            ctfctUb = ctfctUbViolation == 0;
            ctfctVload = ctfctLb && ctfctUb;

%             lbDiff = norm(obj.sampVloadEst - obj.sampVloadLb,2) / norm(obj.sampVloadLb,2);
%             ubDiff = norm(obj.sampVloadEst - obj.sampVloadUb,2) / norm(obj.sampVloadUb,2);
%             ctfctVload = max(lbDiff,ubDiff) <= obj.epsilon;

            if ctfctVload && ctfctStatus
                obj.certified = 1;
            end

            fprintf("Overall certif.: %d | Status certif.: %d | Vload certif.: %d (lower bound violation %d, upper bound violation %d) | (certified if 1, or not certified if 0)\n",...
                obj.certified,ctfctStatus,ctfctVload,ctfctLbViolation,ctfctUbViolation);
            
%             fprintf("Overall certif.: %d | Status certif.: %d (lbDiff %.2e, ubDiff %.2e, threshold %.2e) | Vload certif.: %d (certified if 1, or not certified if 0)",...
%                 obj.certified,ctfctStatus,lbDiff,ubDiff,obj.epsilon,ctfctVload);
        end

        function visualization(obj)
            % visualization for certification
            figure; hold on; xlabel('Sample Index'); ylabel('Sample Virus Load');
            plot(obj.sampVloadLb,'r-*','DisplayName','Vload Lb'); 
            plot(obj.sampVloadUb,'b-<','DisplayName','Vload Ub');
            plot(obj.sampVloadEst,'g-o','DisplayName','Vload Certif.');
            legend();

        end

        function obj = status_obomm(obj,config)
            % update the status, index sets, virus load bounds of individual samples
            obj.sampMPos = find(obj.sampVloadLb > config.vlLb);
            obj.sampMNeg = find(obj.sampVloadUb < config.vlLb);
            dtmd = union(obj.sampMPos,obj.sampMNeg);
            obj.sampPos = setdiff(1:length(obj.sampVloadLb), dtmd);

            obj.sampStatusEst = -1*ones(size(obj.sampStatus));
            obj.sampStatusEst(obj.sampMPos) = 1;
            obj.sampStatusEst(obj.sampMNeg) = 0;
            
            undtmdNum = length(obj.sampPos);
            if undtmdNum<=10
                fprintf("Stage %d of pooling (with mixing matrix) has been completed, with ndices of samples with undetermined status: %s\n",obj.stage,num2str(obj.sampPos))
            elseif undtmdNum > 10
                fprintf("Stage %d of pooling (with mixing matrix) has been completed, with number of samples with undetermined status: %d\n",obj.stage,undtmdNum)
            end
        end
    
        function obj = subsetPool_Decode(obj,sampIdxes)
            % pool samples specified by sampIdxes
            % assume dilution 1
            % args
            % - sampIdxes, 1D array of integer; the set of sample indices
            % whose status cannot be determined in the one-by-one
            % minimization-maximization process just after the 1st stage
            % pooling
            % sample virus load bounds are determined by solving the
            % obo-mm optimization, but its status is directly determined
            % from the pool status
    
            obj.stage = obj.stage + 1;
            newRow = zeros(1,size(obj.poolMatrix,2));
            newRow(sampIdxes) = 1;
    
            obj.poolMatrix = [obj.poolMatrix; newRow];
            obj.poolVload = obj.poolMatrix*obj.sampVload;
            obj.poolStatus = zeros(size(obj.poolMatrix,1),1);
            idxes = find(obj.poolVload>0);
            obj.poolStatus(idxes) = 1;

            obj = obj.vloadBounds();

            if obj.poolStatus(end)==0 % new pool is negative

                obj.sampStatusEst(sampIdxes) = 0;
                obj.sampMNeg = union(obj.sampMNeg,obj.sampPos);
                obj.sampPos = [];

                fprintf("Stage %d of pooling (pooling all undetermined samples) has been completed, and a new negative pool is obtained.\n",obj.stage)
            else
                fprintf("Stage %d of pooling (pooling all undetermined samples) has been completed, and a new positive pool is obtained.\n",obj.stage)
            end
    
        end
    
        function obj = idvdlPool_Decode(obj,sampIdxes)
            % perform individual test
            % args
            % - sampIdxes, 1D array of integers; the set of sample indices
            % whose status cannot be determined in the one-by-one
            % minimization-maximization process even after pooling together
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

            obj.sampStatusEst(sampIdxes) = obj.sampStatus(sampIdxes);

            idxes = find(obj.sampStatus(sampIdxes)==1);
            obj.sampMPos = union(obj.sampMPos,sampIdxes(idxes));
            idxes = find(obj.sampStatus(sampIdxes)==0);
            obj.sampMNeg = union(obj.sampMNeg,sampIdxes(idxes));
            obj.sampPos = [];

            obj = obj.vloadBounds();

            fprintf("Stage %d of pooling (pooling all individual samples in the undetermined index set) has been completed.\n",obj.stage)
    
        end
    end

end