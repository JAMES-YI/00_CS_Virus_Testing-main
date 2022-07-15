function [poolset,Params] = dataSecStgLoadAll(poolset,Params,dataPath)
% This function will load all the primal and secondary test results.
%
% Created by JYI, 10/04/2020
% 
% Updated by JYI, 11/06/2020
% - incorporate COVID-19 retest data
%
% Updated by JYI, 01/01/2021
% - change 'MHV1' to 'MHV-1'
% 
%%

MatInfo = Params.MatInfo;
virusID = Params.virusID; 

switch virusID
    case 'MHV-1'
        % load primary data
        ctValType = 'primary';
        Params.ctValType = ctValType;
        % dataSecStgPath = dataSecStgPathSetup(MatInfo,ctValType,dataSecStgPath);
        if dataPath.currStage==2
            % dataPath = dataSecStgPathSetup(dataPath,Params);
            dataPath = AdReqDataPathSetup2nd(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = AdReqDataPathSetup3rd(dataPath,Params);
        else
            error('Error with stage setup');
        end

        % fID = 'Data/MHV1 Re-Test Results.xlsx';
        % [num,txt] = xlsread(fID,'Sheet1','F10:I14');
        % cell_dat = {'13,15,21'; '42,40,47,11,30'; '15,51,23'; '67,76'};
        % cell_dat_split = cellfun(@(S) sscanf(S, '%f,').', cell_dat, 'Uniform', 0);

        SSDataLoader = SecStgDataLoader(dataPath,Params);
        [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
        SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);

        % Concatenate data from first stage and second stage

        poolset = poolset.data_stg_concat(SSDataLoader);
        clear SSDataLoader

        % load secondary data

        ctValType = 'secondary';
        Params.ctValType = ctValType;
        % dataSecStgPath = dataSecStgPathSetup(MatInfo,ctValType,dataSecStgPath);
        if dataPath.currStage==2
            % dataPath = dataSecStgPathSetup(dataPath,Params);
            dataPath = AdReqDataPathSetup2nd(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = AdReqDataPathSetup3rd(dataPath,Params);
        else
            error('Error with stage setup');
        end

        % fID = 'Data/MHV1 Re-Test Results.xlsx';
        % [num,txt] = xlsread(fID,'Sheet1','F10:I14');
        % cell_dat = {'13,15,21'; '42,40,47,11,30'; '15,51,23'; '67,76'};
        % cell_dat_split = cellfun(@(S) sscanf(S, '%f,').', cell_dat, 'Uniform', 0);

        SSDataLoader = SecStgDataLoader(dataPath,Params);
        [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
        SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);

        % Concatenate data from first stage and second stage

        poolset = poolset.data_stg_concat(SSDataLoader);
        Params.ctValType = 'all';
        
    case 'COVID-19'
        % load primary data
        ctValType = 'primary';
        Params.ctValType = ctValType;
        if dataPath.currStage==2
            % dataPath = dataSecStgPathSetup(dataPath,Params);
            dataPath = AdReqDataPathSetup2nd(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = AdReqDataPathSetup3rd(dataPath,Params);
        else
            error('Error with stage setup');
        end

        % fID = 'Data/MHV1 Re-Test Results.xlsx';
        % [num,txt] = xlsread(fID,'Sheet1','F10:I14');
        % cell_dat = {'13,15,21'; '42,40,47,11,30'; '15,51,23'; '67,76'};
        % cell_dat_split = cellfun(@(S) sscanf(S, '%f,').', cell_dat, 'Uniform', 0);

        SSDataLoader = SecStgDataLoader(dataPath,Params);
        [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
        SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);

        % Concatenate data from first stage and second stage

        poolset = poolset.data_stg_concat(SSDataLoader);
        clear SSDataLoader

        % load secondary data

        ctValType = 'secondary';
        Params.ctValType = ctValType;
        if dataPath.currStage==2
            % dataPath = dataSecStgPathSetup(dataPath,Params);
            dataPath = AdReqDataPathSetup2nd(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = AdReqDataPathSetup3rd(dataPath,Params);
        else
            error('Error with stage setup');
        end

        % fID = 'Data/MHV1 Re-Test Results.xlsx';
        % [num,txt] = xlsread(fID,'Sheet1','F10:I14');
        % cell_dat = {'13,15,21'; '42,40,47,11,30'; '15,51,23'; '67,76'};
        % cell_dat_split = cellfun(@(S) sscanf(S, '%f,').', cell_dat, 'Uniform', 0);

        SSDataLoader = SecStgDataLoader(dataPath,Params);
        [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
        SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);

        % Concatenate data from first stage and second stage

        poolset = poolset.data_stg_concat(SSDataLoader);
        Params.ctValType = 'all';

end