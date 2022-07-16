classdef gridEngine
% This file implements a grid search engine which can perform grid
% search to decode the virus load.
%
% Created by JYI, 09/09/2020
% Updated by JYI, 09/24/2020
% Updated by JYI, 06/24/2022
% - this search engine will no longer be maintained
    
    
    %% 
    properties
        % - pilotVload, cell array with each cell corresponding to a run or trial;
        %   store the virus load for each sample 
        % - rfUbVload, cell array; refined upper bound for grid search;
        % - rfLbVload, cell array;
        
        pilotVload; % 
        rfUbVload; 
        rfLbVload; 
        sampMPos;
        poolVload;
        MixMat;
        sampNum;
        trialNum;
        
        Params;
        radius;
        incrmt;
        
    end
    
    %% 
    methods
        function gEngine = gridEngine(poolset,Params)
            % - the ct vaues should have been converted to virus load
            % - Params contains dilution factor and incrmt for grid search
            
            % poolset = CtVal2Vload(poolset); % convert ct values to virus load
            gEngine.sampMPos = poolset.sampMPos;
            gEngine.poolVload = poolset.poolVload;
            gEngine.MixMat = poolset.MixMat;
            gEngine.sampNum = poolset.sampNum;
            gEngine.trialNum = poolset.trialNum;
            gEngine.incrmt = 1; % default initial increment;
            Params.incrmt = gEngine.incrmt; 
            gEngine.Params = Params;
            
            for iTrial=1:gEngine.trialNum
                
                % Require results from group testing
                % - virus load range [1.0407e-5,2.3157e+3]
                data.sampMPos = gEngine.sampMPos{iTrial};
                data.poolVload = gEngine.poolVload{iTrial};
                data.MixMat =gEngine.MixMat{iTrial};
                singlePart = find(sum(data.MixMat,2)>1); % more than 1 participate
                data.MixMat(singlePart,:) = data.MixMat(singlePart,:) / Params.dilution;

                data.sampNum = gEngine.sampNum;
                
                % Perform initial grid search
                vload = grid_search(data,Params);
                gEngine.pilotVload{iTrial} = vload;
            end
        end
        
        function gEngine = intv_refine(gEngine)
            % refine the upper and lower bounds for grid search
            % - bounds and the elements in sampMPos are correspondence
            % - radius, scalar; ideally set to be the increment of last
            %   time grid search
            
            radiusLoc = gEngine.incrmt; % use the increment in last-time grid search as radius; 
            gEngine.radius = gEngine.incrmt; 

            for iTrial=1:gEngine.trialNum
                
                MPosNum = length(gEngine.sampMPos{iTrial});
                for iPos=1:MPosNum
                    
                    sampInd = gEngine.sampMPos{iTrial}(iPos); % index of positive sample
                    pilotVloadTmp = gEngine.pilotVload{iTrial}(sampInd); % pilot virus load of positive sample
                    gEngine.rfUbVload{iTrial}(iPos) = pilotVloadTmp + radiusLoc;
                    gEngine.rfLbVload{iTrial}(iPos) = max(pilotVloadTmp - radiusLoc,0);
                end
            end
            
        end
        
        function gEngine = vload_refine(gEngine,Params)
           % refine the virus load via refined grid search
           % - the new increment should be set ideally to 10^(-3)*radius
           
           gEngine.incrmt = gEngine.radius * 10^(-3);
           for iTrial=1:gEngine.trialNum
                
                % Require results from group testing
                % - virus load range [1.0407e-5,2.3157e+3]
                data.sampMPos = gEngine.sampMPos{iTrial};
                data.poolVload = gEngine.poolVload{iTrial};
                data.MixMat = gEngine.MixMat{iTrial};
                singlePart = find(sum(data.MixMat,2)>1); % more than 1 participate
                data.MixMat(singlePart,:) = data.MixMat(singlePart,:) / Params.dilution;

                data.sampNum = gEngine.sampNum;
                data.rfUbVload = gEngine.rfUbVload{iTrial}; % with correspondence to sampMPos;
                data.rfLbVload = gEngine.rfLbVload{iTrial};
                ParamsLoc = gEngine.Params;
                ParamsLoc.incrmt = gEngine.incrmt;

                vload = grid_rf_search(data,ParamsLoc);
                gEngine.pilotVload{iTrial} = vload;
            end
           
        end
    end
    
    
end