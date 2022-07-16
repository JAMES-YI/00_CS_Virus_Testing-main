classdef AdReqDataLoader
% This file defines an adaptive request data loader class for loading data
% from subsequent pooling results, and incorporate the loaded results to
% results from early stage for decoding.
%
% High level architecture
% - add the pooling results stage by stage by creating a AdReqDataLoader
%   instance for each stage
% 
% Built on top of
%   SecStgDataLoader.m, dataSecStgConfig.m
% Created by JYI, 12/29/2020
% Updated by JYI, 07/15/2022
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


methods
    
    function obj = AdReqDataLoader(Params)
        
        obj.virusID = Params.virusID;
        obj.runNum = Params.runNum;
        obj.MatInfo = Params.MatInfo;
        obj.Params = Params;
        
    end
    
    function dataPath = config(obj,indStage)
        % setup the file path and data type for loading data ("primary",
        % "secondary", "all")
        
        dataPath.currStage = indStage;
        switch obj.virusID
            
            case 'MHV-1'
                
                %% MHV-1 specify file path
                if obj.Params.trialInd==1
                    
                    dataPath.fID = sprintf('clinical_data/MHV-1_Trial-%d_Stage-%d_Encoded_KWALDSTEIN_202010042110.xlsx',...
                                obj.Params.trialInd,indStage); % need to specify the trialInd and the stage index
               
                elseif obj.Params.trialInd==2
                    
                    dataPath.fID = sprintf('clinical_data/MHV-1_Trial-%d_Stage-%d_Encoded_KWALDSTEIN_202011201614.xlsx',...
                                obj.Params.trialInd,indStage);
                            
                else
                    error('Params.trialInd can take at most 2 for MHV-1.')
                end
                
                %% MHV-1 specify regions
                if strcmp(obj.Params.ctValType,'primary') || strcmp(obj.Params.ctValType,'secondary')

                    if dataPath.currStage==2
                        dataPath = stg2_dataPath(dataPath,obj.Params);
                    elseif dataPath.currStage==3
                        dataPath = stg3_dataPath(dataPath,obj.Params);
                    else
                        error('Error with stage setup');
                    end

                elseif strcmp(obj.Params.ctValType,'all')

                    dataPath = dataPath; % datapath will be specified later

                else error("The type of ct values can only be 'all', 'primary', or 'secondary'!");
                end

	
            %%   
            case 'COVID-19'
                
                %% COVID-19 specify file path
                if obj.Params.trialInd==1
                    dataPath.fID = sprintf('clinical_data/COVID-19_Trial-%d_Stage-%d_Encoded_KWALDSTEIN_202010281100.xlsx',...
                                obj.Params.trialInd,indStage); % need to specify the trialInd and the stage index
                else 
                    error('Params.trialInd can take at most 1 for COVID-19.');
                end
                
                %% COVID-19 specify regions
                if strcmp(obj.Params.ctValType,'primary') || strcmp(obj.Params.ctValType,'secondary')

                    if dataPath.currStage==2
                        dataPath = stg2_dataPath(dataPath,obj.Params);
                    else
                        error('Error with stage setup');
                    end

                elseif strcmp(obj.Params.ctValType,'all')

                    dataPath = dataPath; % datapath will be specified later

                else error("The type of ct values can only be 'all', 'primary', or 'secondary'!");
                end
        end
        
    end
    
    
    %% load data
    function poolset = load(obj,poolset,dataPath)
        % load the pooling results and generate the corresponding mixing
        % matrix
        % - 
        
        if strcmp(obj.Params.ctValType,'primary') || strcmp(obj.Params.ctValType,'secondary')
            
            dataLoader = seqStg_dataLoader(dataPath,obj.Params);
            [dataLoader,dataTxt] = dataLoader.loadData(obj.Params);
            dataLoader = dataLoader.MixMatGen(dataTxt,obj.Params);

            % Concatenate data from first stage and second stage
            poolset = poolset.data_stg_concat(dataLoader);

        elseif strcmp(obj.Params.ctValType,'all')
            [poolset,~] = seqStg_dataLoaderAll(poolset,obj.Params,dataPath);
        end
        
    end
    
end


    
    
end