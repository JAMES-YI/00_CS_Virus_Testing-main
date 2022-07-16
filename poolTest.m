classdef poolTest
% This file defines a poolTest class which is the implementation of the
% compressed sensing based decoding approach proposed in 
% 
% [1] Waldstein, Kody A., Jirong Yi, Michael Myung Cho, Raghu Mudumbai, Xiaodong Wu, Steven M. Varga, and Weiyu Xu. 
% "Use of compressed sensing to expedite high-throughput diagnostic testing for COVID-19 and beyond." medRxiv (2021).
% 
% Created by JYI, 08/25/2020
% Updated by JYI, 12/03/2020
% Updated by JYI, 06/23/2022
% - results from obo_mm are the final results for reporting & results from
% adaptive pooling are for qualitative certificating & results from
% exhaustive search is for quantitative certificating
%
%% Properties
properties(SetAccess=public)
    
    poolStatus; % cell array; number of cells is equal to number of runs; 
    % status of each pool test; either positve (1) or negative (0); 
    poolCtVal; % cell array; number of cells is equal to number of runs; ct value of each pool;
    poolVload; % cell array; number of cells is equal to number of runs; virus load of each pool
    poolNum; % int; number of pools; at each stage, the pool number is the accumulated pool numbers from all the existing stages 
    
    MixMat; % 2d array (if only single stage pooling results are used) or a cell array (if multiple stage pooling results requested)
    runNum; % number of runs performed for a specified virus type, a specified mixing matrix, and a specified trial
    sampNum; % number of individual samples pooled; fixed for each virus type, and each trial and each run; not change with respect to number of stages
    
    % Support set estimation results via group testing or one-by-one
    % minimization-maximization (final results for reporting)
    VloadLb;% cell with each element being a 1d array whose dimensionality is the number of individual samples; 
    % each cell corresponds to one run of experiment; estimated virus
    % load lower bound;
    VloadUb; % cell with each element being a 1d array whose dimensionality is the number of individual samples; 
    % each cell corresponds to one run of experiment; estimated virus
    % load lower bound;
    CtValLb = 12; CtValUb = 34; % a pool will be determined as positive if its ct value is in [12,34]
    sampStatus; % 1d array; status (positive or negative or undetermined) of each individual sample;
    sampMPos; % cell array; number of cells is equal to number of runs; index of positive samples; sampObommMPos;
    sampPos; % cell array; number of cells is equal to number of runs; index of potentially positive samples; sampObommPos;
    sampMNeg; % cell array; number of cells is equal to number of runs; index of negative samples; sampObommMNeg; 
    
    % Compressed sensing based decoding results (used only as certificates)
    sampCsVload; % cell array; number of cells is equal to number of runs; estimated virus load of each individual sample
    sampCsStatus; % 1d array; status (positive or negative) of each individual sample;
    sampCsMPos; % cell array; index set of samples which are decoded as positive;
    sampCsMNeg; % cell array; index set of samples which must be negative;
   
    
end

%% Methods

methods
  
    function obj = poolTest(Params)
        % decoding for multiple stages and multiple runs associated with
        % single initial binary mixing matrix and a single type of rivus
        % args:
        % - Params, structure returned by function config(preconfig)
        % Created by JYI, 08/01/2020
        % Updated by JYI, 06/24/2022
        
        virusID = Params.virusID;
        MatInfo = Params.MatInfo;
        mixmat = mixing_matrices(virusID,MatInfo,false);
        obj.MixMat = mixmat.matrix;
        [obj.poolNum,obj.sampNum] = size(obj.MixMat);
        
    end

    %% 
    function obj = vload_dec(obj,Params)
        % Decode quantitative results vis compressed sensing  
        % Created by JYI, 08/01/2020
        % Updated by JYI, 10/23/2020
        % Updated by JYI, 11/22/2020
        % Updated by JYI, 06/24/2022
        % - removed the grid search solver, the projected gradient solver,
        % the least square solver, mismatchratio successive minimization solver,
        % mismatch ratio minimization solver and their corresponding dependencies
        
        obj = CtVal2Vload(obj,Params);
        solver = Params.solver;
        virusID = Params.virusID;
        obj = obj.supp_est_mtr(Params); % Support set estimation
        
        for i=1:obj.runNum
            
            fprintf('Trial %d/%d\n',i,obj.runNum);
            if iscell(obj.MixMat) % when adaptive requests of pooling results are available
                data.MixMat = obj.MixMat{i};
            else % when only single stage of pooling results are available
                data.MixMat = obj.MixMat;
            end
            
            ut = utils();
            dilution = ut.dilution(virusID,data.MixMat);
            
            Params.dilution = dilution;
            data.MixMat = data.MixMat ./ dilution;
            
            fprintf('Performing exhaustive decoding...\n');
            
            data.sampNum = obj.sampNum; 
            data.poolCtVal = obj.poolCtVal{i};
            
            data.suppSet = setdiff(1:obj.sampNum,obj.sampMNeg{1,i});
            data.sampPos = obj.sampPos{1,i};
            data.sampMPos = obj.sampMPos{1,i};
            data.poolStatus = obj.poolStatus{i};
            data.poolVload = obj.poolVload{i};
            exs = exhaustive(data,Params);
            vload = exs.vload;
            
            % prepare data for saving
           
            
            % - construct final index sets results
            obj.sampCsVload{i} = vload;
            obj.sampCsMPos{i} = find(vload>Params.vloadMin);
            obj.sampCsMNeg{i} = setdiff(1:obj.sampNum,obj.sampCsMPos{i});
            obj.sampCsStatus{i} = repmat('N',obj.sampNum,1);
            obj.sampCsStatus{i}(obj.sampCsMPos{i}) = 'P';

        end
  
    end
    
    
    function obj = data_stg_concat(obj,dataLoader)
        % Concatenate pooling data from different testing stages
        % - SSDataLoader, an object of SecStgDataLoader class
        
        % MixMat concatenation
        MixMatBase = obj.MixMat;
        trialNumLoc = obj.runNum;
        obj.MixMat = cell(trialNumLoc,1);
        runIndMat = cell2mat(dataLoader.runInd);
        
        
        for iTrial=1:trialNumLoc
            
            if ~iscell(MixMatBase)
                if ismember(iTrial,runIndMat)
                    obj.MixMat{iTrial} = [MixMatBase; dataLoader.MixMat{iTrial}];
                    obj.poolStatus{iTrial} = [obj.poolStatus{iTrial}; dataLoader.poolStatus{iTrial}];
                    obj.poolCtVal{iTrial} = [obj.poolCtVal{iTrial}; dataLoader.poolCtVal{iTrial}];
                else
                    % no updates if no extra pooling tests are performed
                    obj.MixMat{iTrial} = MixMatBase;
                end
            else
                if ismember(iTrial,runIndMat)
                    obj.MixMat{iTrial} = [MixMatBase{iTrial}; dataLoader.MixMat{iTrial}];
                    obj.poolStatus{iTrial} = [obj.poolStatus{iTrial}; dataLoader.poolStatus{iTrial}];
                    obj.poolCtVal{iTrial} = [obj.poolCtVal{iTrial}; dataLoader.poolCtVal{iTrial}];
                else
                    % no updates if no extra pooling tests are performed
                    obj.MixMat{iTrial} = MixMatBase{iTrial};
                end
            end
        end
        
        % poolStatus concatenation
        
        % poolCtVal concatenation
    end
    
    %%
    function obj = supp_est_mtr(obj,Params)
        % Decode quanlitative results for multiple runs (mtr) within a trial for
        % one type of virus via traditional group testing approach, or
        % one-by-one minimization-maximization approach
        % 
        % args
        % - Params, structure; return from function config(...)
        % - posNumPrior, prior info of positive samples; either 1 (only one positive sample in the population) or
        % 0 (number of positives is unknown);
        %
        % Created by JYI, 08/01/2020
        % Updated by JYI, 06/24/2022
        
        posNumPrior = Params.posNumPrior;
        switch posNumPrior
            case 0 
                fprintf('Decoding pool results without knowing the number of positives individual samples...\n');
            case 1
                fprintf('Decoding pool results with 1 positive individual sample...\n');
        end

        obj = supp_est(obj,Params);
    
    end

    function res_display(obj)
        % Display the results, i.e., estimated virus load, status and etc
        % of each individual sample
        % 
        % Created by JYI, 08/01/2020
        % Updated by JYI, 06/24/2022
        
        runNumLoc = obj.runNum;
        for i=1:runNumLoc
            fprintf('Trial %d/%d\n',i,runNumLoc);
            fprintf('pos ind\t virus load (ng/ul)\t status (P/N/U) \n');
            fprintf('%d\t%8.2e\t%s\n',...
                    [1:obj.sampNum; obj.sampCsVload{i}'; obj.sampCsStatus{i}']);
        end
    end

    function obj = load_data(obj,dataPath,runNum)
        % 
        % Load pool tests status and ct values from the first pooling stage
        % Created by JYI, 08/27/2020
        % Updated by JYI, 06/27/2022
        
        fID = dataPath.fID; 
        sheet = dataPath.sheet; 
        StatusLet = dataPath.StatusLet; 
        CtValLet = dataPath.CtValLet; 
        InitInd = dataPath.InitInd;

        obj.runNum = runNum; 
        
        for i=1:obj.runNum
    
            StartInd = InitInd + (obj.poolNum+2)*(i-1); 
            EndInd = StartInd + (obj.poolNum-1);
            StatusRange = sprintf('%s%d:%s%d',StatusLet,StartInd,...
                                              StatusLet,EndInd);
            obj.poolStatus{i} = readmatrix(fID,'Sheet',sheet,'Range',StatusRange);
            
            valGrpNum = length(CtValLet);
            obj.poolCtVal{i} = [];
            
            for grpNum=1:valGrpNum % load ctValues of all the duplicates for each run
                CtValRange = sprintf('%s%d:%s%d',CtValLet{grpNum},StartInd,...
                                                 CtValLet{grpNum},EndInd);
                obj.poolCtVal{i} = [obj.poolCtVal{i}; readmatrix(fID,'Sheet',sheet,'Range',CtValRange)];
            end
        end
    end
    
    function obj = dup_MixMat(obj,dataPath)
        % - Update the mixing matrix by replicating the binary mixing matrix mutliples times 
        % according to the number of duplications, and then concatenate the
        % mixing matrices; if only single duplicate group is considered,
        % the mixing matrix will not be updated
        % - dataPath, return from init_dataPath()
        % Created by JYI, 08/27/2020
        % Updated by JYI, 06/27/2022
        
        dupNum = length(dataPath.CtValLet);
        if dupNum~=1 obj.MixMat = repmat(obj.MixMat,[dupNum,1]);
        end
        
    end

    function obj = dup_poolStatus(obj,dataPath)
        % - Update the pooling status vector by concatenating pooling results from different duplicates
        % Created by JYI, 08/27/2020
        % Updated by JYI, 06/27/2022
        
        dupNum = length(dataPath.CtValLet);
        if dupNum~=1
            for i=1:obj.runNum obj.poolStatus{i} = repmat(obj.poolStatus{i},[dupNum,1]);
            end
        end
        
    end

    function obj = CtVal2Vload(obj,Params)
        % Convert ct value to virus load for all the runs associated with
        % one mixing matrix in one trial of one type of virus
        % - virus load will be restricted in [0, virus load corresponding
        % to CtValLb]
        % - the observed ct value will be converted to virus load via
        % ct2vload class which is defined in ct2vload.m
        % Created by JYI, 08/27/2020
        % Updated by JYI, 06/27/2022
        
        convertor = ct2vload(Params.virusID,Params);
        convertor = convertor.datafit();
        
        for i=1:obj.runNum obj.poolVload{i} = convertor.vload_prd(obj.poolCtVal{i});
        end
        
    end
    
    
end
end