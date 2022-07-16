function vload = mismatch(data,Params)
% This function solves the successive mismatch optimization, i.e.,
% min_x norm((poolVload(poolPos,1) - MixMat(poolPos,:)*x_cvx),1))
% subject to
%     MixMat(poolNeg,:)*x_cvx == 0;
%     - x_cvx <= 0;
% 
% or
% min_x norm((poolVload(poolPos,1) - MixMat(poolPos,:)*x_cvx),2))
% subject to
%     MixMat(poolNeg,:)*x_cvx == 0;
%     - x_cvx <= 0;
% 
% Created by JYI, 09/17/2020
%
% Updated by JYI, 06/27/2022
% - this file will no longer be maintained
%% Data preparation and algorithm configuration

MixMat = data.MixMat;
poolVload = data.poolVload;
mismatchratio_norm = Params.mismatchratio_norm;

[~,nSamp] = size(MixMat);
poolPos = find(poolVload > 0);
poolNeg = find(poolVload == 0);

%% 
    
switch mismatchratio_norm
    case 'L1'
        % L1 norm
        cvx_begin quiet
            variable x_cvx(nSamp,1)
            minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,:)*x_cvx),1))
            subject to
                MixMat(poolNeg,:)*x_cvx == 0;
                - x_cvx <= 0;
        cvx_end

    case 'L2'
        % L2 norm
        cvx_begin quiet
            variable x_cvx(nSamp,1)
            minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,:)*x_cvx),2))
            subject to
                MixMat(poolNeg,:)*x_cvx == 0;
                - x_cvx <= 0;
        cvx_end

end
    
x = x_cvx;
vload = x;

end