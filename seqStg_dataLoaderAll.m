function [poolset,Params] = seqStg_dataLoaderAll(poolset,Params,dataPath)
% This function will load all the primal and secondary test results.
%
% Created by JYI, 10/04/2020
% 
% Updated by JYI, 11/06/2020
% Updated by JYI, 01/01/2021
% Updated by JYI, 07/15/2022
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
            dataPath = stg2_dataPath(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = stg3_dataPath(dataPath,Params);
        else
            error('Error with stage setup');
        end

        SSDataLoader = seqStg_dataLoader(dataPath,Params);
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
            dataPath = stg2_dataPath(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = stg3_dataPath(dataPath,Params);
        else
            error('Error with stage setup');
        end

        SSDataLoader = seqStg_dataLoader(dataPath,Params);
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
            dataPath = stg3_dataPath(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = stg3_dataPath(dataPath,Params);
        else
            error('Error with stage setup');
        end

        SSDataLoader = seqStg_dataLoader(dataPath,Params);
        [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
        SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);

        % Concatenate data from first stage and second stage

        poolset = poolset.data_stg_concat(SSDataLoader);
        clear SSDataLoader

        % load secondary data

        ctValType = 'secondary';
        Params.ctValType = ctValType;
        if dataPath.currStage==2
            dataPath = stg2_dataPath(dataPath,Params);
        elseif dataPath.currStage==3
            dataPath = stg3_dataPath(dataPath,Params);
        else
            error('Error with stage setup');
        end

        SSDataLoader = seqStg_dataLoader(dataPath,Params);
        [SSDataLoader,dataTxt] = SSDataLoader.loadData(Params);
        SSDataLoader = SSDataLoader.MixMatGen(dataTxt,Params);

        % Concatenate data from first stage and second stage

        poolset = poolset.data_stg_concat(SSDataLoader);
        Params.ctValType = 'all';

end