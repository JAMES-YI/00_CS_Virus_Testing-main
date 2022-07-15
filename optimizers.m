classdef optimizers

    properties
        TBD = 0;

    end

    methods

        function obj = optimizers()
        end

    end

    methods(Static)

        function vload = L1_MIN(data,Params)
            % Perform L1 minimization decoding virus load
            % args
            % - data, structure associated with single run; containing mixing matrix, and virus loads for each
            % pool; 
            % - Params, structure; 
            %
            % 
            %% 

            fprintf("Performing standard compressed sensing L1 minimization...\n")
    
            MixMatLoc = data.MixMat;
            poolVloadLoc = data.poolVload;
            sampNumLoc = data.sampNum;
            
            cvx_begin quiet
    
                variable vload(sampNumLoc);
                minimize(norm(vload,1));
                subject to
                    MixMatLoc*vload == poolVloadLoc;
                    -vload <= 0;
    
            cvx_end
        end

        function [vloadLb, vloadUb] = OBO_MM(data,Params)
            % Perform one-by-one minimization-maximization for decoding virus load
            % args
            % - data, structure associated with single run with fileds 'MixMat', 'poolVload'; 
            % containing mixing matrix, and virus loads for each pool; 
            % - Params, structure; 

            
            MixMat = data.MixMat;
            poolVload = data.poolVload;
            sampNum = size(MixMat,2);
            vloadLb = zeros(sampNum,1);
            vloadUb = zeros(sampNum,1);

            fprintf("Performing one-by-one minimization-maximization...\n")
            
            for iSamp=1:sampNum
                if rem(iSamp,10)==0 fprintf('%d/%d sample\n',iSamp,sampNum);end
                
                % minimization
                cvx_begin quiet
                    variable x(sampNum,1)
                    minimize(x(iSamp))
                    subject to
                        MixMat*x == poolVload;
                        -x <= 0;
                cvx_end
                
                vloadLb(iSamp) = x(iSamp); 
                
                % maximization
                cvx_begin quiet
                    variable x(sampNum,1)
                    minimize(-x(iSamp))
                    subject to
                        MixMat*x == poolVload;
                        -x <= 0; 
                cvx_end
                
                vloadUb(iSamp) = x(iSamp);
                
            end
           

        end

        function vload = MMR_MIN(data,Params)
            % perform mismatch ratio (MMR) minimization to estimate virus load
            % args
            % - data, structure with fields "MixMat" (mixing matrix),
            % "poolVload" (pool virus load), "sampMPos" (indices of
            % positive samples), "sampNum" (number of samples), "epsilon"
            % (small constant for avoiding numerical errors)

            fprintf("Performing mismatch ratio minimization...\n")

            MixMat = data.MixMat;
            poolVload = data.poolVload;
            sampMPos = data.sampMPos;
            sampNum = data.sampNum;
            sampMNeg = setdiff(1:sampNum,sampMPos);
            
            cvx_begin quiet
                    variable vload(sampNum,1)
                    minimize(norm( MixMat*vload-poolVload,2))
                    subject to
                        -vload(sampMPos) <= 0;
                        vload(sampMNeg) == 0;
           cvx_end

        end
    
    end

end