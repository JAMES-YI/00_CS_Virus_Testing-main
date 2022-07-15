%% 
fID = 'curve data';
curveData = xlsread(fID,'curve data','A2:B9');
figure; 
subplot(2,1,1); plot(curveData(:,1),curveData(:,2));
subplot(2,1,2); plot(log10(curveData(:,1)),curveData(:,2));

% fitting data
f = fit(log10(curveData(:,1)),curveData(:,2),'poly1')
