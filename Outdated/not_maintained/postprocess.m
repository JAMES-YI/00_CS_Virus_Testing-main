% This file is to postprocess the results returned by exhaustive decoding methods.
% - dfID specified by Params.dfNameExhaustiveData
% 
% Created by JYI, 11/03/2020
%
%%
close all; 

% dfID = 'ExhaustiveData202011030934.mat';
dfID = 'ExhaustiveData202011031621.mat';

load(dfID);
for i=2
   singleRunData = saveDataExhaust{1,i};
   vloadList = singleRunData.vloadList;
   objValList = singleRunData.objValList;
   ctValList = singleRunData.ctValList;
   poolCtValResL1List = singleRunData.poolCtValResL1List;
   poolCtValResL2List = singleRunData.poolCtValResL2List;
   
%    figure; 
%    subplot(1,3,1); plot(objValList,'o'); 
%    subplot(1,3,2); plot(poolCtValResL1List,'o');
%    subplot(1,3,3); plot(poolCtValResL2List,'o');
   
   figure; hold on; 
   plot(objValList,'o');
   plot(poolCtValResL1List,'o');
   plot(poolCtValResL2List,'o');
   legend('obj','ct res L1', 'ct res L2')
   
%    poolVloadTruth = poolset.poolVload{i};
%    soluNum = size(vloadList,2);
%    for iSolu=1:soluNum
%       figure; hold on; 
%       plot(poolVloadTruth,'o');
%       plot(vload)
%       legend('Truth','Est');
%    end
   
   
end