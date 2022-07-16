classdef optimizer
% This file defines an optimizer class which contains various optimization solvers for performing 
% signal reconstruction: given measuurement (or mixing) matrix A and
% measurements y which can be of the general form y = Ax+n, we want to
% estimate x from A and y.
% 
% Created by JYI, 10/08/2020
% Updated by JYI, 07/05/2022
% - this file will no longer be maintained

%%
properties
    inData;
    gnrParams;
end


%%
methods
    %%
    function obj = optimizer(inData,gnrParams)
        
        obj.inData = inData;
        obj.gnrParams = gnrParams;
        
    end
    
    %% 
    function xEst = L1_min(obj,slvParams)
        
        %         - estimate x via the general L1 minimization of the form
        %         min_x ||x||_1
        %         s.t.  x >= 0
        %               A*x == y
        
        A = obj.inData.A;
        poolVal = obj.inData.poolVal;
        
        [~,nCol] = size(A);
        
        cvx_begin quiet
            variable sampValEst(nCol,1);
            minimize(norm(sampValEst,1));
            subject to 
                A*sampValEst == poolVal;
                - sampValEst <= 0; 
        cvx_end
        
        xEst = sampValEst;
        
        
    end
    
    %% 
    function xEst = MismatchRatio_SUCCMIN(obj,slvParams)
        % - estimate the signal via successive minimization over the
        %   mismatch ratio, i.e.,
        %   min_x sum_{i in P} |y_i - (Ax)_i|/(Ax)_i
        %   s.t.  (Ax)_j = 0, j in N
        %       x >= 0 
        % - P, index set of positive pools
        % - N, index set of negative pools
        
        A = obj.inData.A;
        poolVal = obj.inData.poolVal;
        
        MaxIter = slvParams.MaxIter;
        tol = slvParams.tol;
        mismatchratio_norm = slvParams. mismatchratio_norm;
        
        [~,nCol] = size(A);
        
        x = A'*poolVal;
        y = poolVal;
        
        poolPos = find(poolVal > 0);
        poolNeg = find(poolVal == 0);


        nSamp = nCol;
        
        for Iter=1:MaxIter
    
            x_prev = x;

            switch mismatchratio_norm
                case 'L1'
                    % L1 norm
                    cvx_begin quiet
                        variable x_cvx(nSamp,1)
                        minimize(norm((poolVal(poolPos,1) - A(poolPos,:)*x_cvx) ./ y(poolPos,1),1))
                        subject to
                            A(poolNeg,:)*x_cvx == 0;
                            - x_cvx <= 0;
                    cvx_end

                case 'L2'
                    % L2 norm
                    cvx_begin quiet
                        variable x_cvx(nSamp,1)
                        minimize(norm((poolVal(poolPos,1) - A(poolPos,:)*x_cvx) ./ y(poolPos,1),2))
                        subject to
                            A(poolNeg,:)*x_cvx == 0;
                            - x_cvx <= 0;
                    cvx_end

            end

            x = x_cvx;

            % update y
            y = A*x; % without updating y
        %     
            if norm(x-x_prev,2) < tol || norm(poolVal-y,2) < tol
                break;
            end

        end

        xEst = x;
        
        
    end
    

    
    
end

methods(Static)
    
    

        %% 
    function xEst = Exhaust(slvParams)
        
    end
    
    %% 
    function xEst = Obo_mm(slvParmas)
        %         - implement the one-by-one minimzation-maximization (obo mm) algorithm for 
        %           recovering x from compressed measurements y := Ax + n where
        %           x in [L,U] and x is a potential noise vector. More specifically, we solve the following two 
        %           linear programmings for each element of x,
        % 
        %             min_x x_i
        %             s.t.  L_j <= (Ax)_j <= U_j, j=1,2,...,|x|
        %                   x>=0
        % 
        %             max_x x_i
        %             s.t.  L_j <= (Ax)_j <= U_j, j=1,2,...,|x|
        %                   x>=0
        %             where L_j is the virus load corresponding to (ct value + CtValDev), and
        %             U_j is the virus load corresponding to (ct value - CtValDev)
        %         
        %         References
        %         [1] based on the implementation in obo_mm.m
        %
        
        % Data preparation and parameter setup
        xLbTmp = zeros(sampNum,1);
        xUbTmp = zeros(sampNum,1); 
        MixMat = poolset.MixMat{iTrial};
        singlePart = find(sum(MixMat,2)>1); % more than 1 participate
        MixMat(singlePart,:) = MixMat(singlePart,:) / Params.dilution;

        % Solve two linear programmings to estimate upper and lower bound
        for iSamp=1:sampNum
            fprintf('%d/%d sample\n',iSamp,sampNum);
            % minimization
            cvx_begin quiet
                variable x(sampNum,1)
                minimize(x(iSamp))
                subject to
                    -MixMat*x <= - poolVloadLb{iTrial};
                    MixMat*x <= poolVloadUb{iTrial};
                    -x <= 0;
            cvx_end

            xLbTmp(iSamp) = x(iSamp); 
            Log.minStatus{iTrial} = cvx_status;

            % maximization
            cvx_begin quiet
                variable x(sampNum,1)
                minimize(-x(iSamp))
                subject to
                    -MixMat*x <= -poolVloadLb{iTrial};
                    MixMat*x <= poolVloadUb{iTrial};
                    -x <= 0; 
            cvx_end

            xUbTmp(iSamp) = x(iSamp);
            Log.maxStatus{iTrial} = cvx_status;

        end
        
    end
    
    
end
    
    
    
end

