% This file is to visualize the decoding results. The following files are required
%   Data/MHV1 Pooled Testing Exp 1 Decoded Results with Actual_Nonadaptive_noSep.xlsx
%   Data/MHV1 Pooled Testing Exp 1 Decoded Results with Actual_Adaptive_noSep.xlsx
% 
% Created by JYI, 11/01/2020
% Updated by JYI, 06/29/2022
% - this file will no longer be maintiained

%%

mode = 'Nonadaptive'; % 'Adaptive'
MatInfo = '3 by 7'; % '4 by 15', '5 by 31'
epsilon = 10^(-14); % avoid numerical error

fID = sprintf('Data/MHV1 Pooled Testing Exp 1 Decoded Results with Actual_%s_noSep.xlsx',...
    mode);

switch MatInfo
    
    case '3 by 7'
        
        MatSize = [3,7];
        trialNum = 1;
        for i=1:trialNum
            
            sampStatus{i} = xlsread(fID,'Sheet1','F3:F9');
            sampVLoadLower{i} = xlsread(fID,'Sheet1','G3:G9');
            sampVLoadUpper{i} = xlsread(fID,'Sheet1','H3:H9');
            sampVLoadEst{i} = xlsread(fID,'Sheet1','I3:I9');
            sampVLoadAct{i} = xlsread(fID,'Sheet1','J3:J9');
        end
        
    case '4 by 15'
        
        trialNum = 5;
        MatSize = [4,15];
        for i=1:trialNum
            startInd = 3+(i-1)*17;
            endInd = i*17;
            
            statusRg = sprintf('Q%d:Q%d',startInd,endInd);
            sampVLoadLowerRg = sprintf('R%d:R%d',startInd,endInd);
            sampVLoadUpperRg = sprintf('S%d:S%d',startInd,endInd);
            sampVLoadEstRg = sprintf('T%d:T%d',startInd,endInd);
            sampVLoadActRg = sprintf('U%d:U%d',startInd,endInd);
            
            sampStatus{i} = xlsread(fID,'Sheet1',statusRg);
            sampVLoadLower{i} = xlsread(fID,'Sheet1',sampVLoadLowerRg);
            sampVLoadUpper{i} = xlsread(fID,'Sheet1',sampVLoadUpperRg);
            sampVLoadEst{i} = xlsread(fID,'Sheet1',sampVLoadEstRg);
            sampVLoadAct{i} = xlsread(fID,'Sheet1',sampVLoadActRg);
            
        end
        
    case '5 by 31'
        
        trialNum = 7;
        MatSize = [5,31];
        for i=1:trialNum
            startInd = 3+(i-1)*33;
            endInd = i*33;
            
            statusRg = sprintf('AB%d:AB%d',startInd,endInd);
            sampVLoadLowerRg = sprintf('AC%d:AC%d',startInd,endInd);
            sampVLoadUpperRg = sprintf('AD%d:AD%d',startInd,endInd);
            sampVLoadEstRg = sprintf('AE%d:AE%d',startInd,endInd);
            sampVLoadActRg = sprintf('AF%d:AF%d',startInd,endInd);
            
            sampStatus{i} = xlsread(fID,'Sheet1',statusRg);
            sampVLoadLower{i} = xlsread(fID,'Sheet1',sampVLoadLowerRg);
            sampVLoadUpper{i} = xlsread(fID,'Sheet1',sampVLoadUpperRg);
            sampVLoadEst{i} = xlsread(fID,'Sheet1',sampVLoadEstRg);
            sampVLoadAct{i} = xlsread(fID,'Sheet1',sampVLoadActRg);
            
        end
    
end

timeStamp = datestr(now,'yyyymmddHHMM');

for i=1:trialNum
    
    folderName = sprintf('%sBy%s',MatSize(1),MatSize(2));
    if ~isfolder(folderName)
        mkdir(folderName);
    end
    figName = sprintf('size%dBy%d%sRun%d_Stmp%s.pdf',...
        MatSize(1),MatSize(2),...
        mode,i,timeStamp);
    
    figure; hold on; box on;
    xlabel('Sample Index','fontsize',12); 
    ylabel('Viral Load (ng/$\mu$l) in log10 Scale','fontsize',12,...
        'interpreter','latex');
    
    % plot status
    posInd = find(sampVLoadAct{i}>0);
    h(1) = plot(posInd,zeros(length(posInd),1),'o',...
        'MarkerSize',15,...
        'LineWidth',2);
    
    posIndEst = find(sampStatus{i}==1);
    if ~isempty(posIndEst)
        h(2) = plot(posIndEst,zeros(length(posIndEst),1),'+',...
            'MarkerSize',15,...
            'LineWidth',2);
    end
    
    % plot virus load
    h(3) = plot(1:MatSize(2),log10(sampVLoadLower{i}+epsilon),'*',...
        'MarkerSize',10,...
        'LineWidth',2);
    h(4) = plot(1:MatSize(2),log10(sampVLoadUpper{i}+epsilon),'x',...
        'MarkerSize',10,...
        'LineWidth',2);
    h(5) = plot(1:MatSize(2),log10(sampVLoadAct{i}+epsilon),'v',...
        'MarkerSize',10,...
        'LineWidth',2);
    h(6) = plot(1:MatSize(2),log10(sampVLoadEst{i}+epsilon),'s',...
        'MarkerSize',10,...
        'LineWidth',2);
    
    % legend
    if ~isempty(posIndEst)
        legend([h(1),h(2),h(3),h(4),h(5),h(6)],...
            'Grnd. Tru. Pos','Est. Pos.',...
            'LB. Est','UB. Est','Act.','Est.');
    else
        legend([h(1),h(3),h(4),h(5),h(6)],...
            'Grnd. Tru. Pos',...
            'LB. Est','UB. Est','Act.','Est.');
    end
    
    % save figure
    fig=gcf; 
    fig.PaperPositionMode='auto';
    print(figName,'-dpdf','-fillpage')
    
    close all;
    
end


