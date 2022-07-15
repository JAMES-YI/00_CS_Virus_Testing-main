function resrep_setup(poolset,Params)
% This file sets up the results reporting configurations.
%
% Created by JYI, 09/04/2020.
% Updated by JYI, 09/25/2020
% - write decoded quantitative results to excel
% -
% 
%%

trialNum = poolset.trialNum;
poolNum = poolset.poolNum;
sampNum = poolset.sampNum; 
logStatus = Params.logStatus;

% Write to excel
if strcmp(Params.solver,'OBO_MM')
    fTemplate = 'Data/MHV1 Pooled Testing Exp 1 Results 082820_stage1&2_obo_mm_template.xlsx';
    fTemplate2 = 'Data/MHV1 Pooled Testing Exp 1 Results 082820_stage1&2_non-obo_mm_template.xlsx';
    copy(fTemplate,Params.excelID);
    switch Params.MatInfo
        
        case '3 by 7'
            
            for iTrial=1:trialNum
                startInd = 3+(iTrial-1)*9;
                startIndLb = sprintf('F%d',startInd);
                startIndUb = sprintf('G%d',startInd);
                sheetID = 'Sheet1';
                
                VloadLbTmp = poolset.VloadLb{iTrial};
                VloadUbTmp = poolset.VloadUb{iTrial};
                
                % write to obo_mm
                writematrix(VloadLbTmp,Params.excelID,...
                    sheetID,'Range',startIndLb);
                writematrix(VloadUbTmp,Params.excelID,...
                    sheetID,'Range',startIndUb);
                
                % write to non-obo_mm
                startIndLb2 = sprintf('F%d',startInd);
                startIndUb2 = sprintf('G%d',startInd);
                writematrix(VloadLbTmp,fTemplate2,...
                    sheetID,'Range',startIndLb2);
                writematrix(VloadUbTmp,fTemplate2,...
                    sheetID,'Range',startIndUb2);
                
            end
            
            
        case '4 by 15'
            
             for iTrial=1:trialNum
                startInd = 3+(iTrial-1)*17;
                startIndLb = sprintf('N%d',startInd);
                startIndUb = sprintf('O%d',startInd);
                sheetID = 'Sheet1';
                
                VloadLbTmp = poolset.VloadLb{iTrial};
                VloadUbTmp = poolset.VloadUb{iTrial};
                writematrix(VloadLbTmp,Params.excelID,...
                    sheetID,'Range',startIndLb);
                writematrix(VloadUbTmp,Params.excelID,...
                    sheetID,'Range',startIndUb);
                
                startIndLb2 = sprintf('Q%d',startInd);
                startIndUb2 = sprintf('R%d',startInd);
                writematrix(VloadLbTmp,fTemplate2,...
                    sheetID,'Range',startIndLb2);
                writematrix(VloadUbTmp,fTemplate2,...
                    sheetID,'Range',startIndUb2);
            end
            
        case '5 by 31'
            
            for iTrial=1:trialNum
                startInd = 3+(iTrial-1)*33;
                startIndLb = sprintf('V%d',startInd);
                startIndUb = sprintf('W%d',startInd);
                sheetID = 'Sheet1';
                
                VloadLbTmp = poolset.VloadLb{iTrial};
                VloadUbTmp = poolset.VloadUb{iTrial};
                writematrix(VloadLbTmp,Params.excelID,...
                    sheetID,'Range',startIndLb);
                writematrix(VloadUbTmp,Params.excelID,...
                    sheetID,'Range',startIndUb);
                
                startIndLb2 = sprintf('AA%d',startInd);
                startIndUb2 = sprintf('AB%d',startInd);
                writematrix(VloadLbTmp,fTemplate2,...
                    sheetID,'Range',startIndLb2);
                writematrix(VloadUbTmp,fTemplate2,...
                    sheetID,'Range',startIndUb2);
            end
            
    end
else
    % single value estimate
    fTemplate = 'Data/MHV1 Pooled Testing Exp 1 Results 082820_stage1&2_non-obo_mm_template.xlsx';
    copy(fTemplate,Params.excelID);
    
    switch Params.MatInfo
        
        case '3 by 7'
            
            for iTrial=1:trialNum
                startInd = 3+(iTrial-1)*9;
                startIndSg = sprintf('H%d',startInd);
                sheetID = 'Sheet1';
                
                VloadTmp = poolset.sampVloadLb{iTrial};
                
                writematrix(VloadTmp,Params.excelID,...
                    sheetID,'Range',startIndSg);
                
            end
            
        case '4 by 15'
            
            for iTrial=1:trialNum
                startInd = 3+(iTrial-1)*17;
                startIndSg = sprintf('S%d',startInd);
                sheetID = 'Sheet1';
                
                VloadTmp = poolset.sampVloadLb{iTrial};
                
                writematrix(VloadTmp,Params.excelID,...
                    sheetID,'Range',startIndSg);
                
            end
            
        case '5 by 31'
            
            for iTrial=1:trialNum
                startInd = 3+(iTrial-1)*33;
                startIndSg = sprintf('AC%d',startInd);
                sheetID = 'Sheet1';
                
                VloadTmp = poolset.sampVloadLb{iTrial};
                
                writematrix(VloadTmp,Params.excelID,...
                    sheetID,'Range',startIndSg);
                
            end
    end
end

%%

% Keep logs
switch logStatus
    case 'on'
        output_log = 'output_log.txt'; 
        outputID = fopen(output_log,'a'); 
        SegInfo = sprintf('\n#----------pool number=%d, sample number=%d, date=%s------------------#\n',...
                          poolNum,sampNum,datestr(now,'yyyymmddHHMM'));

        fprintf(outputID,SegInfo);

        for i=1:trialNum

            fprintf(outputID,'Decoded results for trial %d/%d: Status\tVirus Load\n',i,trialNum);
            sampStatus = poolset.sampStatus{i}; 
            sampVload = poolset.sampVload{i};

            for sampIter = 1:sampNum

                fprintf(outputID,'\t\t  %d-th sample: %s\t%8.2e\n',sampIter,sampStatus(sampIter,:),sampVload(sampIter));

            end

        end

        fclose(outputID);
        
    case 'off'
        
%         for i=1:trialNum
%             
%             posInd = poolset.sampPos{i};
%             sampVload = poolset.sampVload{i};
%             fprintf('Trial %d/%d\n',i,trialNum);
%             fprintf('pos ind\t virus load (ng/ul)\n');
%             
%             for sampIter=posInd'
%                 fprintf('%d\t%8.4e\n',sampIter,sampVload(sampIter));
%             end
%             
%         end
end

end