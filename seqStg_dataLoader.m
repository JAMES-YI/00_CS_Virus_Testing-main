classdef seqStg_dataLoader
% This file defines a data loader class for later 
% stage preprocessing.
% 
% 
% Created by JYI, 09/04/2020
% Updated by JYI, 12/29/2020
% Updated by JYI, 07/15/2022, jirong-yi@uiowa.edu; jirong.yi@hologic.com
%
%% 
properties(SetAccess=private)
    
    runInd; % cell array
    fID; 
    sheetID;
    Rg;
    poolCtVal; % cell array of size (trialNum,1)
    poolStatus; % cell array of size (trialNum,1)
    MixMat; % cell array of size (trialNum,1); effective pooling matrix;
    Params;
    
    
end

methods
    
    function obj = seqStg_dataLoader(dataPath,Params)
        % Constructor
        
        obj.runInd = dataPath.runInd;
        obj.fID = dataPath.fID;
        obj.sheetID = dataPath.sheetID;
        obj.Rg = dataPath.Rg;
        obj.Params = Params;
        
    end
    
    function [obj,dataTxt] = loadData(obj,Params)
        
        % Load data
        runNum = Params.runNum;
        dataTxt = cell(runNum,1);
        runIndLoc = obj.runInd;
        runNumNew = length(runIndLoc);
        
        for iRun=1:runNumNew
            
            if strcmp(Params.ctValType,'primary')
                [Nmrc,TxtTmp] = xlsread(obj.fID,obj.sheetID{iRun},...
                                     obj.Rg{iRun});
                obj.poolStatus{runIndLoc{iRun}} = Nmrc(:,1);
                obj.poolCtVal{runIndLoc{iRun}} = Nmrc(:,2);
                dataTxt{runIndLoc{iRun}} = TxtTmp; 
                
            elseif strcmp(Params.ctValType,'secondary')
                [Nmrc,TxtTmp] = xlsread(obj.fID,obj.sheetID{iRun},...
                     obj.Rg{iRun});
                Nmrc = Nmrc(:,[1,3]);
                obj.poolStatus{runIndLoc{iRun}} = Nmrc(:,1);
                obj.poolCtVal{runIndLoc{iRun}} = Nmrc(:,2);
                dataTxt{runIndLoc{iRun}} = TxtTmp; 
            end
                
        end
        
    end
    
    function obj = MixMatGen(obj,dataTxt,Params)
        % Generate mixing matrix
        
        runNum = Params.runNum;
        sampNum = Params.sampNum;
        
        runIndLoc = obj.runInd;
        runNumNew = length(runIndLoc);
        obj.MixMat = cell(runNum,1);
        
        for iRun=1:runNumNew
            
            dataTxtTmp = dataTxt{runIndLoc{iRun}};
            dataTxtSplit = cellfun(@(S) sscanf(S, '%f,').', dataTxtTmp, 'Uniform', 0);
            poolNumNew = length(dataTxtSplit);
            obj.MixMat{runIndLoc{iRun}} = zeros(poolNumNew,sampNum);
            
            for iPool=1:poolNumNew
                obj.MixMat{runIndLoc{iRun}}(iPool,dataTxtSplit{iPool}) = 1;
            end
        end
        
    end
    
end

end