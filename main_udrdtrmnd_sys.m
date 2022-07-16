% This file is to illustrate the performance of L1 minimization for solving
% under-determined system in different scenarios, i.e., large ambient
% dimension and low ambient dimension.
%
% Created by JYI, 10/20/2020
%
%% 
close all;
N = 10;
n = round(0.3*N);
s = round(0.05*N);

A = binornd(1,0.5,n,N);
x = zeros(N,1);
supp = randsample(N,s);
x(supp) = rand(s,1)*100;
y = A*x;

cvx_begin quiet
    variable x_est(N,1)
    minimize(norm(x_est,1))
    subject to
        A*x_est == y
        - x_est <= 0
cvx_end

figure; hold on;
plot(x,'o');
plot(x_est,'*');
legend('Truth','Estimate');
xlabel('Element Index'); ylabel('Element Value');

% figName = sprintf('Recovery_perf_under_diff_N_N%d',N);
% fig = gcf;
% fig.PaperPositionMode = 'auto';
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3),fig_pos(4)];
% print(fig,figName,'-dpdf');
