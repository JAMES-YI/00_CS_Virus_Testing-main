function vload = mismatchratio_succ(data,Params)
% This function solves the successive mismatch optimization.
% 
% Created by JYI, 09/17/2020
%
% Updated by JYI, 01/05/2021
% - incorporate information from group testing results
%   to facilitate decoding
% Updated by JYI, 06/27/2022
% - this file will no longer be maintained

%% Data preparation and algorithm configuration

MixMat = data.MixMat;
poolVload = data.poolVload;
mismatchratio_norm = Params.mismatchratio_norm;
supp = union(data.sampMPos,data.sampPos); suppSize = length(supp);
nonsupp = data.sampMNeg;

[~,nSamp] = size(MixMat);
poolPos = find(poolVload > 0);
poolNeg = find(poolVload == 0);

MaxIter = Params.MaxIterSucc;
tol = 1e-8;

%% 
x = MixMat'*poolVload;
y = poolVload;

for Iter=1:MaxIter
    
    x_prev = x;
    
    switch mismatchratio_norm
        case 'L1'
            % L1 norm
            cvx_begin quiet
                variable x_cvx(suppSize,1)
                minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,supp)*x_cvx) ./ y(poolPos,1),1))
                subject to
                    MixMat(poolNeg,supp)*x_cvx == 0;
                    - x_cvx <= 0;
                    %- x_cvx <= 0;
            cvx_end
            
        case 'L2Supp'
            % L2 norm
            % Updated by JYI, 01/05/2020
            % - optimize only over support set
            cvx_begin quiet
                variable x_cvx(suppSize,1)
                minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,supp)*x_cvx) ./ y(poolPos,1),2))
                subject to
                    MixMat(poolNeg,supp)*x_cvx == 0;
                    - x_cvx <= 0;
                    %- x_cvx <= 0;
            cvx_end
            
        case 'L2'
            cvx_begin quiet
                variable x_cvx(nSamp,1)
                minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,:)*x_cvx) ./ y(poolPos,1),2))
                subject to
                    MixMat(poolNeg,:)*x_cvx == 0;
                    - x_cvx <= 0;
            cvx_end
            
        case 'L2L1'
            % L2 norm with L1 regularization
            cvx_begin quiet
                variable x_cvx(suppSize,1)
                minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,supp)*x_cvx) ./ y(poolPos,1),2) + norm(x_cvx,1))
                subject to
                    MixMat(poolNeg,supp)*x_cvx == 0;
                    - x_cvx <= 0;
                    %- x_cvx <= 0;
            cvx_end
    end
    
    x = x_cvx;
%     x = zeros(nSamp,1);
%     x(supp,1) = x_cvx;
    
    % update y
    y = MixMat*x; % without updating y
    
    residual = norm(poolVload-MixMat*x,2) / norm(poolVload,2);
    variation = norm(x-x_prev,2) / norm(x_prev,2);
    if (variation < tol) || ( residual < tol)
        % fprintf('Converged!\n')
        break;
    end
    
    
    
end

vload = x;

end
