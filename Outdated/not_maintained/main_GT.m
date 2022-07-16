% This file perform group testing using synthesized sample data for the mixing matrix
% constructed via bipartite graph of size 25 by 100, and with 5 ones in each column.
% 
% - The following data is required
%   bp_A_25_100_1InCol_5.mat
% - 
% 
% Created by JYI, 09/17/2020
%
%%
load('bp_A_25_100_1InCol_5.mat');

[nRow,nCol] = size(A);
OneInCol = sum(A(:,1));
trialNum = 100;
Params.posNum = 0; % number of positives unknown;

fName = sprintf('statistical_row%d_col%d_1inCol%d_%s.mat',...
    nRow,nCol,OneInCol,datestr(now,'yyyymmddHHMM'));

%%

rng('shuffle');
succRate = zeros(nCol,1);
spstArr = 1:nCol;

for spst=spstArr
    
    succNum = 0;
    fprintf('Number of positive samples: %d\n',spst);
    
    for iTrial=1:trialNum
        
        % ground truth samples
        spstInd = randsample(nCol,spst);
        sampStatus = zeros(nCol,1);
        sampStatus(spstInd) = 1;
        
        % generate pool results
%         poolStatus = zeros(nRow,1);
%         for iRow=1:nRow
%             
%             ptcptInd = find(A(iRow,:)==1); % find all the sample participating in the pool
%             ptcptSamp = sampStatus(ptcptInd);
%             poolStatus(iRow) = sum(ptcptSamp(:)) >= 1; % check if there is positive samples 
%         
%         end
        
        poolStatus = A*sampStatus>0;
        
        % Estimate sample results
        [~,MPos,Pos] = pool_dec_spb(A,poolStatus,Params);
        sampStatusEst = zeros(nCol,1); % must negative samples
        sampStatusEst(MPos) = 1; % must positive samples
        sampStatusEst(Pos) = -3; % potential positive samples
        
        if all(sampStatus==sampStatusEst)
            
            succNum = succNum+1; % count successful group testing
            
        end
        
    end
    
    succRate(spst) = succNum / trialNum;
    
end

%% Save data

saveData.MixMat = A;
saveData.succRate = succRate;
saveData.spstArr = spstArr;
save(fName,'saveData');

figure; 
plot(succRate,'-*');
xlabel('# of positives'); ylabel('Success rate');



