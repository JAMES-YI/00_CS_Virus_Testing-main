classdef utils
    % This file defines a dummy class which contains useful methods for preprocessing and postprocessing
    % 
    % Created by JYI, 06/24/2022
    %
    
    %%
    properties
        TBD = 0
    end
    
    %% 
    methods(Static)

        function obj = utils()

        end

        function dltFctor = dilution(virusID,mixMatrix)
            % compute the dilution factor
            % - virusID, str; virus type, 'COVID-19', 'MHV-1'
            % - mixMatrix, 2d array; binary mixing matrix
            % - dltFctor, 1d array with same size as number of rows of
            % mixMatrix
            % 
            % Created by JYI, 06/24/2022
            % 
            % 

            switch virusID
                case 'MHV-1'
                    dltFctor = 4*ones(size(mixMatrix,1),1);
                    indOnes = find(sum(mixMatrix,2)==1); % find individual tests
                    dltFctor(indOnes) = 1;
                case 'COVID-19'
                    dltFctor = sum(mixMatrix,2);
            end

        end

        function obj = load_stdCurveData(obj)
        % loads the standard curve data for interpolation over ct value
        % and virus load.
        % - the standard curve data is the same for different stages within
        % the same trial for each virus type
        % - obj, instance of ct2vload class or vload2ct class
        %
        % Created by JYI, 10/05/2020
        % Updated by JYI, 10/23/2020
        % Updated by JYI, 06/27/2022
        %%
        
        switch obj.virusID
            case 'MHV-1'
                
                if obj.Params.trialInd==1
                    fID = sprintf('Data/MHV-1_Trial-1_StdCurve_KWALDSTEIN_202010042110.xlsx');
                    stID = 'Sheet1';
                    ctRg1 = 'C2:C9';
                    vlRg1 = 'A2:A9';

                    ctRg3 = 'D2:D9';
                    vlRg3 = 'A2:A9';
                    
                elseif obj.Params.trialInd==2
                    
                    fID = sprintf('Data/MHV-1_Trial-2_StdCurve_KWALDSTEIN_202011201614.xlsx');
                    stID = 'Sheet1';
                    ctRg1 = 'C2:C9';
                    vlRg1 = 'A2:A9';

                    ctRg3 = 'D2:D9';
                    vlRg3 = 'A2:A9';
                    
                else
                    error('Params.trialInd can be at most 2 for MHV-1.\n')
                end


                ctVal1 = readmatrix(fID,'Sheet',stID,'Range',ctRg1);
                ctVal3 = readmatrix(fID,'Sheet',stID,'Range',ctRg3);
                obj.ctVal = [ctVal1; ctVal3]';

                vload1 = readmatrix(fID,'Sheet',stID,'Range',vlRg1);
                vload3 = readmatrix(fID,'Sheet',stID,'Range',vlRg3);
                obj.vload = [vload1; vload3]';
                
            case 'COVID-19'
                
                if obj.Params.trialInd==1
                    
                    fID = sprintf('Data/COVID-19_Trial-1_StdCurve_KWALDSTEIN_202010281100.xlsx');
                    stID = 'Sheet1';

                    ctRg1 = 'B3:B14';
                    ctRg2 = 'C3:C14';
                    vlRg1 = 'A3:A14';
                    vlRg2 = 'A3:A14';

                    ctVal1 = readmatrix(fID,'Sheet',stID,'Range',ctRg1);
                    ctVal2 = readmatrix(fID,'Sheet',stID,'Range',ctRg2);
                    obj.ctVal = [ctVal1; ctVal2]';

                    vload1 = readmatrix(fID,'Sheet',stID,'Range',vlRg1);
                    vload2 = readmatrix(fID,'Sheet',stID,'Range',vlRg2);
                    obj.vload = [vload1; vload2]';
                else
                    error('Params.trialInd can be at most 1 for COVID-19.\n')
                end
                
        end
    end

    end


end