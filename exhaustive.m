classdef exhaustive
            % This file perform exhaustive search for decoding by the following steps
            % - set an upper bound for sparsity, i.e., MaxSpst; 
            %   suggested to be no greater than 10% of total number of samples;
            %   for each possible choice of sparsity spst, form all the possible support sets;
            %   for each support set, reduce the problem to be an constrained least
            %   square;
            %   final solution will be the one achieving the smallest objective function value
            % 
            % Created by JYI, 10/27/2020
            % Updated by JYI, 11/02/2020
            % Updated by JYI, 11/22/2020
            % Updated by JYI, 11/28/2020
            % 
            % Updated by JYI, 07/08/2022, jirong.yi@hologic.com
            % - removed successive minimization component and its dependencies
            % - removed components and dependencies of MINPOS mode and REGULAR mode for exhasutive search
            % - removed components for saving intermediate results
            % - function to class

    properties
        poolVload; % virus load of pools
        epsilon; % small positive constant for avoid numerical issues
        MixMat; % mixing matrix
        sampNum; % sample number or population size
        vload; % estimated virus load
        ctVal; % estimated ct value
        poolCtVal;
        poolStatus;
        poolNum;
        sampMPos;
        sampPos;
        earlyTolCtVal;
        maxSpst;
    end

    methods

        function obj = exhaustive(data,Params)
            
            %% 
            obj.MixMat = data.MixMat;
            obj.poolVload = data.poolVload; 
            obj.poolCtVal = data.poolCtVal; 
            obj.poolStatus = data.poolStatus;
            [obj.poolNum,obj.sampNum] = size(obj.MixMat);
            obj.sampMPos = reshape(data.sampMPos,[1,length(data.sampMPos)]); % must positive samples
            obj.sampPos = data.sampPos; % potentially positive samples
            
            obj.earlyTolCtVal = Params.earlyTolCtVal; 
            obj.maxSpst = min(round(0.1*obj.sampNum),length(obj.sampPos));
            obj.epsilon = 1e-16;

            
            if isempty(obj.sampPos)
                supp = obj.sampMPos;
                obj = obj.solve(supp);
            else
            
                obj = obj.search(Params);
            
            end
            
        end

        function obj = search(obj,Params)
            % perform exhasutive search for solution
            maxSpstEffct = length(obj.sampMPos) + obj.maxSpst;

            for spst = 1:obj.maxSpst
                
                suppCombs = nchoosek(obj.sampPos,spst);
                suppCombsNum = size(suppCombs,1);

                for iSupp=1:suppCombsNum
                    
                    % fprintf('Combination: %d/%d\n',iSupp,suppCombsNum);
                    supp = [suppCombs(iSupp,:), obj.sampMPos];
                    spstEffct = length(supp);
                    fprintf('Sparsity: %d/%d\n',spstEffct,maxSpstEffct);
                    
                    % pattern consistance check
                    % - skip the support set if the positive pattern of the pools can not be covered by that of the resultant
                    %   columns of the mixing matrix OR if the negative pattern of the pools has index in the positive
                    %   pattern of the resultant columns of the mixing matrix
            
                    poolStatusEst = sum(obj.MixMat(:,supp),2)>0;
                    skip = ~all(poolStatusEst==obj.poolStatus);
                    if skip
                               continue; 
                    else
                        
                        Patt = [obj.poolStatus';poolStatusEst'];
                        fmt = [repmat('%4d ', 1, size(Patt,2)-1), '%4d\n'];
                        fprintf('Support set matched\n')
                        fprintf(fmt, Patt.');
                        
                    end

                    obj = obj.solve(supp);

                    % calculate ct Value of pools
                    convertor = vload2ct(Params.virusID,Params);
                    convertor = convertor.datafit();
                    obj.ctVal = convertor.ctVal_prd(obj.MixMat*obj.vload);
                    
                    %% early stopping
                    % - if for every pool, the residual between the observed ct value and the predicted ct value is less than
                    %   earlyTolCtVal, then we stop the exhaustive search and use the solution we have found as the final solution
                    
                    ctValResEle = abs(obj.ctVal-obj.poolCtVal) < obj.earlyTolCtVal;
                    if prod(ctValResEle)==1
                        break;
                    end
                end
                
                if exist('ctValResEle','var')
                    if prod(ctValResEle)==1
                            break;
                    end
                end
                
            end

        end

        function obj = solve(obj,supp)
            % estimate virus load of each individual sample and ct value of
            % each pool
            % args
            % - supp, array; support set of population, i.e., index set of
            % samples which are positive

            spst = length(supp);
            % data is normalized
            cvx_begin quiet
                variable vloadSub(spst,1)
                minimize(norm(obj.MixMat(:,supp)*vloadSub-obj.poolVload,2))
                subject to
                    -vloadSub <= 0;
            cvx_end
              
            obj.vload = zeros(obj.sampNum,1);
            obj.vload(supp,:) = vloadSub;
            
        end
    end
end

