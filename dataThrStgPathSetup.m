function dataSecStgPath = dataThrStgPathSetup(dataSecStgPath,Params)
% This file is to set up the data path for loading pooling test results
% from the second stage.
% 
% input arguments
% - MatInfo, information of matrix used in the first stage
% - ctValType, for specifying which group of ct values to use; the main
% group or the duplicated group
% - dataSecStgPath
%
% output arguments
% - dataSecStgPath
%
% TBD
% - use different group of ct values; (1) main group, 'primary'; (2) duplicated group, 'secondary';
% (3) both the main and duplicated group, 'all';
%
% Created by JYI, 09/04/2020.
%
% Updated by JYI, 11/06/2020
% - incorporate retests results for COVID-19
% - introduce variable Params
% 
% Updated by JYI, 01/05/2020
% - change 'MHV1' to 'MHV-1'
%% 

MatInfo = Params.MatInfo;
ctValType = Params.ctValType;
virusID = Params.virusID; 

switch virusID
    case 'MHV-1'

        if strcmp(ctValType,'primary')
            switch MatInfo

                case '3 by 7'

                    dataSecStgPath.runInd = {};
                    dataSecStgPath.sheetID = {};
                    dataSecStgPath.Rg = {};

                case '4 by 15'

                    dataSecStgPath.runInd = {2,4,5};
                    dataSecStgPath.sheetID = {'Sheet1','Sheet1','Sheet1'};
                    dataSecStgPath.Rg = {'A4:C4','A7:C7','A10:C10'};

                case '5 by 31'

                    dataSecStgPath.runInd = {1,2,3,4,5,6,7};
                    dataSecStgPath.sheetID = {'Sheet1','Sheet1','Sheet1','Sheet1','Sheet1','Sheet1',...
                                              'Sheet1'};
                    dataSecStgPath.Rg = {'F4:H4','F7:H7','F10:H10','F28:H28',...
                                         'F31:H31','F34:H35',...
                                         'F38:H38'};
            end

        elseif strcmp(ctValType,'secondary')
            switch MatInfo

                case '3 by 7'

                    dataSecStgPath.runInd = {};
                    dataSecStgPath.sheetID = {};
                    dataSecStgPath.Rg = {};

                case '4 by 15'

                    dataSecStgPath.runInd = {2,4,5};
                    dataSecStgPath.sheetID = {'Sheet1','Sheet1','Sheet1'};
                    dataSecStgPath.Rg = {'A4:D4','A7:D7','A10:D10'};

                case '5 by 31'

                    dataSecStgPath.runInd = {1,2,3,4,5,6,7};
                    dataSecStgPath.sheetID = {'Sheet1','Sheet1','Sheet1','Sheet1','Sheet1','Sheet1',...
                                              'Sheet1'};
                    dataSecStgPath.Rg = {'F4:I4','F7:I7','F10:I10','F28:I28',...
                                         'F31:I31','F34:I35',...
                                         'F38:I38'};
            end

        end
        
    case 'COVID-19'
        if strcmp(ctValType,'primary')
            switch MatInfo

                case '3 by 7'
                    % if no extra retests

                    dataSecStgPath.runInd = {};
                    dataSecStgPath.sheetID = {};
                    dataSecStgPath.Rg = {};

                case '16 by 40'

                    dataSecStgPath.runInd = {1,2};
                    dataSecStgPath.sheetID = {'Sheet1','Sheet1'};
                    dataSecStgPath.Rg = {'C4:E6','C10:E12'};
            end

        elseif strcmp(ctValType,'secondary')
            switch MatInfo

                case '3 by 7'

                    dataSecStgPath.runInd = {};
                    dataSecStgPath.sheetID = {};
                    dataSecStgPath.Rg = {};

                case '16 by 40'

                    dataSecStgPath.runInd = {1,2};
                    dataSecStgPath.sheetID = {'Sheet1','Sheet1'};
                    dataSecStgPath.Rg = {'C4:F4','C10:F10'};
            end

        end
end

end