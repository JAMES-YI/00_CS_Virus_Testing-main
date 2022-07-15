classdef SecStgDataLoader
% This file defines a data loader class for second 
% stage preprocessing.
% 
% Properties
% 
% Methods
% 
% Created by JYI, 09/04/2020.
%
% Modified by JYI, 12/29/2020
% - 
%
%% 
properties(SetAccess=private)
    % attributes
    % - dataPath, a structure containing
    %   - fID, data file name
    %   - sheetID, sheet name; cell array of same size as runInd
    %   - Rg, region; cell array of same size as runInd
    
    runInd; % cell array
    fID; 
    sheetID;
    Rg;
    poolCtVal; % cell array of size (trialNum,1)
    poolStatus; % cell array of size (trialNum,1)
    MixMat; % cell array of size (trialNum,1)
    Params;
    
    
end

methods
    
    function SSDataLoader = SecStgDataLoader(dataPath,Params)
        % Constructor
        
        SSDataLoader.runInd = dataPath.runInd;
        SSDataLoader.fID = dataPath.fID;
        SSDataLoader.sheetID = dataPath.sheetID;
        SSDataLoader.Rg = dataPath.Rg;
        SSDataLoader.Params = Params;
        
    end
    
    function [SSDataLoader,dataTxt] = loadData(SSDataLoader,Params)
        
        % Load data
        runNum = Params.runNum;
        dataTxt = cell(runNum,1);
        runIndLoc = SSDataLoader.runInd;
        runNumNew = length(runIndLoc);
        
        for iRun=1:runNumNew
            
            if strcmp(Params.ctValType,'primary')
                [Nmrc,TxtTmp] = xlsread(SSDataLoader.fID,SSDataLoader.sheetID{iRun},...
                                     SSDataLoader.Rg{iRun});
                SSDataLoader.poolStatus{runIndLoc{iRun}} = Nmrc(:,1);
                SSDataLoader.poolCtVal{runIndLoc{iRun}} = Nmrc(:,2);
                dataTxt{runIndLoc{iRun}} = TxtTmp; 
                % - dataTxt is a cell array; the number of elements is equal to the number of trials;
                % - each element dataTxtTmp of dataTxt is a cell array; the
                %   number of elements in dataTxtTmp is equal to the number of
                %   extra pool tests performed in the second stage
                % - runIndLoc{iTrial}is the trial index
                
            elseif strcmp(Params.ctValType,'secondary')
                [Nmrc,TxtTmp] = xlsread(SSDataLoader.fID,SSDataLoader.sheetID{iRun},...
                     SSDataLoader.Rg{iRun});
                Nmrc = Nmrc(:,[1,3]);
                SSDataLoader.poolStatus{runIndLoc{iRun}} = Nmrc(:,1);
                SSDataLoader.poolCtVal{runIndLoc{iRun}} = Nmrc(:,2);
                dataTxt{runIndLoc{iRun}} = TxtTmp; 
            end
                
        end
        
    end
    
    function SSDataLoader = MixMatGen(SSDataLoader,dataTxt,Params)
        % Generate mixing matrix
        
        runNum = Params.runNum;
        sampNum = Params.sampNum;
        
        runIndLoc = SSDataLoader.runInd;
        runNumNew = length(runIndLoc);
        SSDataLoader.MixMat = cell(runNum,1);
        
        for iRun=1:runNumNew
            
            dataTxtTmp = dataTxt{runIndLoc{iRun}};
            dataTxtSplit = cellfun(@(S) sscanf(S, '%f,').', dataTxtTmp, 'Uniform', 0);
            poolNumNew = length(dataTxtSplit);
            SSDataLoader.MixMat{runIndLoc{iRun}} = zeros(poolNumNew,sampNum);
            
            for iPool=1:poolNumNew
                SSDataLoader.MixMat{runIndLoc{iRun}}(iPool,dataTxtSplit{iPool}) = 1;
            end
        end
        
    end
    
end

end