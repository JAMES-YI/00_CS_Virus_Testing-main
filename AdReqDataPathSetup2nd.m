function dataPath = AdReqDataPathSetup2nd(dataPath,Params)
% This file is to set up the data path for loading pooling test results
% from the second stage.
% 
% Updated by JYI, 12/29/2020
% - build on top of dataSecStgPathSetup.m
% - only the second stage data will be loaded for decoding in MHV1
% 
%% 

MatInfo = Params.MatInfo;
ctValType = Params.ctValType;
virusID = Params.virusID; 

switch virusID
    case 'MHV-1'

        if strcmp(ctValType,'primary')
            switch MatInfo

                case '3 by 7'

                    dataPath.runInd = {};
                    dataPath.sheetID = {};
                    dataPath.Rg = {};

                case '4 by 15'

                    dataPath.runInd = {2,4,5};
                    dataPath.sheetID = {'Sheet1','Sheet1','Sheet1'};
                    dataPath.Rg = {'A4:C4','A7:C7','A10:C10'};

                case '5 by 31'

                    dataPath.runInd = {1,2,3,4,5,6,7};
                    dataPath.sheetID = {'Sheet1','Sheet1','Sheet1','Sheet1','Sheet1','Sheet1',...
                                              'Sheet1'};
                    dataPath.Rg = {'F4:H4','F7:H7','F10:H10','F28:H28','F31:H31','F34:H35',...
                                         'F38:H38'};
            end

        elseif strcmp(ctValType,'secondary')
            switch MatInfo

                case '3 by 7'

                    dataPath.runInd = {};
                    dataPath.sheetID = {};
                    dataPath.Rg = {};

                case '4 by 15'

                    dataPath.runInd = {2,4,5};
                    dataPath.sheetID = {'Sheet1','Sheet1','Sheet1'};
                    dataPath.Rg = {'A4:D4','A7:D7','A10:D10'};

                case '5 by 31'

                    dataPath.runInd = {1,2,3,4,5,6,7};
                    dataPath.sheetID = {'Sheet1','Sheet1','Sheet1','Sheet1','Sheet1','Sheet1',...
                                              'Sheet1'};
                    dataPath.Rg = {'F4:I4','F7:I7','F10:I10','F28:I28','F31:I31','F34:I35',...
                                         'F38:I38'};
            end

        end
        
    case 'COVID-19'
        if strcmp(ctValType,'primary')
            switch MatInfo

                case '3 by 7'
                    % if no extra retests

                    dataPath.runInd = {};
                    dataPath.sheetID = {};
                    dataPath.Rg = {};

                case '16 by 40'

                    dataPath.runInd = {1,2};
                    dataPath.sheetID = {'Sheet1','Sheet1'};
                    dataPath.Rg = {'C4:E6','C10:E12'};
            end

        elseif strcmp(ctValType,'secondary')
            switch MatInfo

                case '3 by 7'

                    dataPath.runInd = {};
                    dataPath.sheetID = {};
                    dataPath.Rg = {};

                case '16 by 40'

                    dataPath.runInd = {1,2};
                    dataPath.sheetID = {'Sheet1','Sheet1'};
                    dataPath.Rg = {'C4:F4','C10:F10'};
            end

        end
        
end

end