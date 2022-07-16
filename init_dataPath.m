function [dataPath,Params] = init_dataPath(Params)
% This function is to set up the data path for reading data from
% xlsx files in the first stage of pooling.
% 
% input argument
% - Params, return of function config()
% output argument
% - dataPath, Params
%
% Created by JYI, 08/28/2020
% Updated by JYI, 10/27/2020
% Updated by JYI, 11/20/2020
% Updated by JYI, 12/30/2020
% Updated by JYI, 06/27/2022
% - updated the source data format
% - changed file and function from dataPathSetup.m to init_dataPath.m
%% 
virusID = Params.virusID;
MatInfo = Params.MatInfo;
ctValType = Params.ctValType;

dataPath.sheet = 'Sheet1'; 
dataPath.InitInd = 3;

%% data file path
switch Params.virusID
    case 'MHV-1'
        
        if Params.trialInd==1
            dataPath.fID = 'clinical_data/MHV-1_Trial-1_Stage-1_Encoded_KWALDSTEIN_202010042110.xlsx';
        elseif Params.trialInd==2
            dataPath.fID = 'clinical_data/MHV-1_Trial-2_Stage-1_Encoded_KWALDSTEIN_202011201614.xlsx';
        else
            error('Params.trialInd can be at most 2 for MHV-1.');
        end
        
    case 'COVID-19'
         
        % Params.dilution = 10; % fold of dilution; the dilution for each pool can be different
        if Params.trialInd==1
            dataPath.fID = 'clinical_data/COVID-19_Trial-1_Stage-1_Encoded_KWALDSTEIN_202010281100.xlsx';
        else
            error('Params.trialInd can be at most 1 for COVID-19.');
        end
end

%% data locations
switch virusID
    
    case 'MHV-1'
        switch MatInfo
            case '3 by 7'
                dataPath.StatusLet = 'B'; 

                if strcmp(ctValType,'primary')
                    dataPath.CtValLet = {'C'};
                elseif strcmp(ctValType,'secondary')
                    dataPath.CtValLet = {'D'};
                elseif strcmp(ctValType,'all')
                    dataPath.CtValLet = {'C','D'};
                else
                    error('Error in selecting ct value type! Choose either primary or secondary');
                end

                runNum = 1;

            case '4 by 15'
                dataPath.StatusLet = 'G'; 

                if strcmp(ctValType,'primary')
                    dataPath.CtValLet = {'H'};
                elseif strcmp(ctValType,'secondary')
                    dataPath.CtValLet = {'I'};
                elseif strcmp(ctValType,'all')
                    dataPath.CtValLet = {'H','I'};
                else
                    error('Error in selecting ct value type! Choose either primary or secondary');
                end

               runNum = 5;

            case '5 by 31'

                dataPath.StatusLet = 'L'; 

                if strcmp(ctValType,'primary')
                    dataPath.CtValLet = {'M'};
                elseif strcmp(ctValType,'secondary')
                    dataPath.CtValLet = {'N'};
                elseif strcmp(ctValType,'all')
                    dataPath.CtValLet = {'M','N'};
                else
                    error('Error in selecting ct value type! Choose either primary or secondary');
                end

                runNum = 7;
        end
        
    case 'COVID-19'
        
        switch MatInfo
            
            case '16 by 40'
                dataPath.StatusLet = 'C'; 

                if strcmp(ctValType,'primary')
                    dataPath.CtValLet = {'D'};
                elseif strcmp(ctValType,'secondary')
                    dataPath.CtValLet = {'E'};
                elseif strcmp(ctValType,'all')
                    dataPath.CtValLet = {'D','E'};
                else
                    error('Error in selecting ct value type! Choose either primary or secondary');
                end

                runNum = 2;
        end
        
end

Params.runNum = runNum;
end