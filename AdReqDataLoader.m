classdef AdReqDataLoader
% This file defines an adaptive request data loader class for loading data
% from subsequent pooling results, and incorporate the loaded results to
% results from early stage for decoding.
%
% High level architecture
% - add the pooling results stage by stage by creating a AdReqDataLoader
%   instance for each stage
% 
% properties include the following:
% - virusID
% - trialNum
% - MatInfo

% methods include the following:
% - 
%
% Built on top of
%   SecStgDataLoader.m, dataSecStgConfig
% Created by JYI, 12/29/2020
% 
%%

    
    
%% Properties
properties(SetAccess = private)
    
    virusID;
    runNum; % number of runs performed for a specified virus type and a specified mixing matrix
    MatInfo;
    Params;
    dataPath;
    
end


%% Methods
methods
    
    %%
    function dataLoader = AdReqDataLoader(Params)
        
        dataLoader.virusID = Params.virusID;
        dataLoader.runNum = Params.runNum;
        dataLoader.MatInfo = Params.MatInfo;
        dataLoader.Params = Params;
        
    end
    
    %% configurations
    function dataPath = config(dataLoader,indStage)
        % setup the file path and data type for loading data ("primary",
        % "secondary", "all")
        % - File path is specified by virus ID ("MHV-1", "COVID-19") and
        %   trial index, and stage index (if adaptive request decoding is
        %   performed)
        % - Data from the 1st stage will always be loaded in a separate
        %   process
        % ToDo
        % - configuration for COVID-19
        % - configuration for MHV1_2
        
        % specify file path
        dataPath.currStage = indStage;
        switch dataLoader.virusID
            
            case 'MHV-1'
                
                %% MHV-1 specify file path
                if dataLoader.Params.trialInd==1
                    
                    dataPath.fID = sprintf('Data/MHV-1_Trial-%d_Stage-%d_Encoded_KWALDSTEIN_202010042110.xlsx',...
                                dataLoader.Params.trialInd,indStage); % need to specify the trialInd and the stage index
               
                elseif dataLoader.Params.trialInd==2
                    
                    dataPath.fID = sprintf('Data/MHV-1_Trial-%d_Stage-%d_Encoded_KWALDSTEIN_202011201614.xlsx',...
                                dataLoader.Params.trialInd,indStage);
                            
                else
                    error('Params.trialInd can take at most 2 for MHV-1.')
                end
                
                %% MHV-1 specify regions
                if strcmp(dataLoader.Params.ctValType,'primary') || strcmp(dataLoader.Params.ctValType,'secondary')

                    % dataPath = dataSecStgPathSetup(dataPath,dataLoader.Params);
                    if dataPath.currStage==2
                        % dataPath = dataSecStgPathSetup(dataPath,Params);
                        dataPath = AdReqDataPathSetup2nd(dataPath,dataLoader.Params);
                    elseif dataPath.currStage==3
                        dataPath = AdReqDataPathSetup3rd(dataPath,dataLoader.Params);
                    else
                        error('Error with stage setup');
                    end

                elseif strcmp(dataLoader.Params.ctValType,'all')

                    dataPath = dataPath; % datapath will be specified later

                else 

                    error("The type of ct values can only be 'all', 'primary', or 'secondary'!");
                end

	
            %%   
            case 'COVID-19'
                
                %% COVID-19 specify file path
                if dataLoader.Params.trialInd==1
                    dataPath.fID = sprintf('Data/COVID-19_Trial-%d_Stage-%d_Encoded_KWALDSTEIN_202010281100.xlsx',...
                                dataLoader.Params.trialInd,indStage); % need to specify the trialInd and the stage index
                else 
                    error('Params.trialInd can take at most 1 for COVID-19.');
                end
                
                %% COVID-19 specify regions
                if strcmp(dataLoader.Params.ctValType,'primary') || strcmp(dataLoader.Params.ctValType,'secondary')

                    % dataPath = dataSecStgPathSetup(dataPath,dataLoader.Params);
                    if dataPath.currStage==2
                        % dataPath = dataSecStgPathSetup(dataPath,Params);
                        dataPath = AdReqDataPathSetup2nd(dataPath,dataLoader.Params);
                    else
                        error('Error with stage setup');
                    end

                elseif strcmp(dataLoader.Params.ctValType,'all')

                    dataPath = dataPath; % datapath will be specified later

                else 

                    error("The type of ct values can only be 'all', 'primary', or 'secondary'!");

                end
                
                
        end
        
%         % specify regions
%         if strcmp(dataLoader.Params.ctValType,'primary') || strcmp(dataLoader.Params.ctValType,'secondary')
%             
%             % dataPath = dataSecStgPathSetup(dataPath,dataLoader.Params);
%             if dataPath.currStage==2
%                 % dataPath = dataSecStgPathSetup(dataPath,Params);
%                 dataPath = AdReqDataPathSetup2nd(dataPath,dataLoader.Params);
%             elseif dataPath.currStage==3
%                 dataPath = AdReqDataPathSetup3rd(dataPath,dataLoader.Params);
%             else
%                 error('Error with stage setup');
%             end
%             
%         elseif strcmp(dataLoader.Params.ctValType,'all')
%             
%             dataPath = dataPath; % datapath will be specified later
%             
%         else 
%             
%             error("The type of ct values can only be 'all', 'primary', or 'secondary'!");
%             
%         end
        
    end
    
    
    %% load data
    function poolset = load(dataLoader,poolset,dataPath)
        % load the pooling results and generate the corresponding mixing
        % matrix
        % - 
        
        if strcmp(dataLoader.Params.ctValType,'primary') || strcmp(dataLoader.Params.ctValType,'secondary')
            
            SSDataLoader = SecStgDataLoader(dataPath,dataLoader.Params);
            [SSDataLoader,dataTxt] = SSDataLoader.loadData(dataLoader.Params);
            SSDataLoader = SSDataLoader.MixMatGen(dataTxt,dataLoader.Params);

            % Concatenate data from first stage and second stage
            poolset = poolset.data_stg_concat(SSDataLoader);

        elseif strcmp(dataLoader.Params.ctValType,'all')
            [poolset,~] = dataSecStgLoadAll(poolset,dataLoader.Params,dataPath);
        end
        
    end
    
end


    
    
end

% function [poolset, Params] = AdReqDataLoader2nd(poolset,Params)
% % This file is to set up the configuration for loading adaptive testing
% % results for decoding.
% % - All the subsequent data will be loaded for decoding
% %
% % Created by JYI, 11/06/2020
% % 
% % Modified by JYI, 12/29/2020
% % - only load the second stage data for decoding in MHV1 case
% % - ToDo: only load the second stage data for decoding in COVID-19 case
% % - ToDo: only load the second stage data for decoding in MHV1_2 case
% % 
% %% 
% switch Params.virusID
%     case 'MHV1'
%         dataPath.fID = 'Data/MHV-1_Trial-1_Stage-2_Encoded_KWALDSTEIN_202010042110.xlsx';
% 
%         if strcmp(Params.ctValType,'primary') || strcmp(Params.ctValType,'secondary')
%             dataPath = dataSecStgPathSetup(dataPath,Params);
% 
%             % fID = 'Data/MHV1 Re-Test Results.xlsx';
%             % [num,txt] = xlsread(fID,'Sheet1','F10:I14');
%             % cell_dat = {'13,15,21'; '42,40,47,11,30'; '15,51,23'; '67,76'};
%             % cell_dat_split = cellfun(@(S) sscanf(S, '%f,').', cell_dat, 'Uniform', 0);
% 
%             SSDataLoader = SecStgDataLoader(dataPath,Params);
%             [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
%             SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);
% 
%             % Concatenate data from first stage and second stage
% 
%             poolset = poolset.data_stg_concat(SSDataLoader);
% 
%         elseif strcmp(Params.ctValType,'all')
%             [poolset,Params] = dataSecStgLoadAll(poolset,Params,dataPath);
%         end
% 
%     case 'COVID-19'
% 
%         dataPath.fID = 'Data/16x40 Exp 1 Retest Results_prep.xlsx';
% 
%         if strcmp(Params.ctValType,'primary') || strcmp(Params.ctValType,'secondary')
%             dataPath = dataSecStgPathSetup(dataPath,Params);
% 
%             % fID = 'Data/MHV1 Re-Test Results.xlsx';
%             % [num,txt] = xlsread(fID,'Sheet1','F10:I14');
%             % cell_dat = {'13,15,21'; '42,40,47,11,30'; '15,51,23'; '67,76'};
%             % cell_dat_split = cellfun(@(S) sscanf(S, '%f,').', cell_dat, 'Uniform', 0);
% 
%             SSDataLoader = SecStgDataLoader(dataPath,Params);
%             [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
%             SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);
% 
%             % Concatenate data from first stage and second stage
% 
%             poolset = poolset.data_stg_concat(SSDataLoader);
% 
%         elseif strcmp(Params.ctValType,'all')
%             [poolset,Params] = dataSecStgLoadAll(poolset,Params,dataPath);
%         end
%         
%     case 'MHV1_2'
% 
% 
% end

% end