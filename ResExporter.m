classdef ResExporter
    % This class is to write out results for MHV-1 to excel.
    % 
    % Created by JYI, 12/29/2020
    % Updated by JYI, 07/02/2022
    % - results from final cs exhaustive search module can only either be
    % positive or negative
    % - removed dependencies for writing decoding results for other solvers: 
    % 'LSQ_ANA','LSQ_ITER','LOGRATIO_GRID','LOGRATIO_PGD','MISMATCHRATIO_GRID','MISMATCHRATIO_SUCC', 
    % 
    % ToDo
    % - reduce redundancy of codes
    % - export data for COVID-19

    properties

        poolset;
        Params;

    end

    methods

        function obj = ResExporter(poolset,Params)
            % poolset, instance of poolTest class
            % Params, return from config()

            obj.poolset = poolset;
            obj.Params = Params;

            if strcmp(Params.virusID,'MHV-1')
                obj.MHV_1();
            elseif strcmp(Params.virusID,'COVID-19')
                obj.COVID_19()
            else
                fprintf("%s not supported",Params.virusID)
            end

        end

        function [obj,fmt] = formatter(obj)
            % set up configurations for exporting results
            switch obj.Params.virusID

                case 'MHV-1'
                    fmt.template = sprintf('Data/MHV-1_Trial-%d_Decoded_JYI_Template.xlsx',obj.Params.trialInd);
                    if strcmp(obj.Params.MatInfo,'3 by 7')
                        fmt.indInitial = 3; fmt.indDelta = 9;
                        fmt.oo_mmStatusLet = 'F';
                        fmt.oo_mmVlLbLet = 'G';
                        fmt.oo_mmVlUpLet = 'H';
                        fmt.CsStatusLet ='I';
                        fmt.CsVlLet = 'J';
                    elseif strcmp(obj.Params.MatInfo,'4 by 15')
                        fmt.indInitial = 3; fmt.indDelta = 17;
                        fmt.oo_mmStatusLet = 'Q';
                        fmt.oo_mmVlLbLet = 'R';
                        fmt.oo_mmVlUpLet = 'S';
                        fmt.CsStatusLet ='T';
                        fmt.CsVlLet = 'U';
                    elseif strcmp(obj.Params.MatInfo,'5 by 31')
                        fmt.indInitial = 3; fmt.indDelta = 33;
                        fmt.oo_mmStatusLet = 'AB';
                        fmt.oo_mmVlLbLet = 'AC';
                        fmt.oo_mmVlUpLet = 'AD';
                        fmt.CsStatusLet ='AE';
                        fmt.CsVlLet = 'AF';
                    else
                        fprintf('%s not supported',obj.Params.MatInfo);
                    end

                case 'COVID-19'
                    fmt.template = sprintf('Data/COVID-19_Trial-%d_Decoded_JYI_Template.xlsx',obj.Params.trialInd);
                    if strcmp(obj.Params.MatInfo,'16 by 40')
                        fmt.indInitial = 3; fmt.indDelta = 42;
                        fmt.oo_mmStatusLet = 'J';
                        fmt.oo_mmVlLbLet = 'K';
                        fmt.oo_mmVlUpLet = 'K';
                        fmt.CsStatusLet ='M';
                        fmt.CsVlLet = 'N';
                    else
                        fprintf('%s not supported',obj.Params.MatInfo);
                    end

            end

            if ~isfile(obj.Params.optExcelID) % create output file if not existing
                copyfile(fmt.template,obj.Params.optExcelID);
            end

        end

        function MHV_1(obj)
            % export MHV_1 experimental results
            [obj,fmt] = obj.formatter();
            obj.exhaustive(fmt);
            obj.oo_mm(fmt);

        end

        function COVID_19(obj)
            % export COVID_19 experimental results
            [obj,fmt] = obj.formatter();
            obj.exhaustive(fmt);
            obj.oo_mm(fmt);

        end

        function exhaustive(obj,fmt)
            % export exhaustive search results
            % - fmt, return from formatting()

            Params = obj.Params;
            poolset = obj.poolset;
            
            Params.sheetID = 'Sheet1';
            indInitial = fmt.indInitial;
            indDelta = fmt.indDelta;
            
            for iRun=1:Params.runNum
                % exhaustive search quantitative
                indStart = indInitial+(iRun-1)*indDelta;
                indEnd = iRun*indDelta;
                vloadRg = sprintf('%s%d:%s%d',fmt.CsVlLet,indStart,fmt.CsVlLet,indEnd);
                writematrix(poolset.sampCsVload{iRun},Params.optExcelID,...
                        'Sheet',Params.sheetID,'Range',vloadRg); % sample virus load from exhaustive search
    
                % exhaustive search qualitative
                indStart = indInitial+(iRun-1)*indDelta;
                indEnd = iRun*indDelta;
                statusRg = sprintf('%s%d:%s%d',fmt.CsStatusLet,indStart,fmt.CsStatusLet,indEnd);
                writematrix(poolset.sampCsStatus{iRun},Params.optExcelID,...
                        'Sheet',Params.sheetID,'Range',statusRg); % oo_mm status of each sample
    
                % exhaustive search set of potential positives
                if isempty(poolset.sampCsMPos{iRun})
                    indPosStr = 'NA';
                else
                    indPosStr = sprintf('%d,',poolset.sampCsMPos{iRun});
                end
                posRg = sprintf('%s%d',fmt.CsStatusLet,indEnd+1);
                writematrix(indPosStr,Params.optExcelID,...
                        'Sheet',Params.sheetID,'Range',posRg);
            end

        end

        function oo_mm(obj,fmt)
            % export oo_mm results

            Params = obj.Params;
            poolset = obj.poolset;
            
            Params.sheetID = 'Sheet1';
            indInitial = fmt.indInitial;
            indDelta = fmt.indDelta;

            for iRun=1:Params.runNum
    
                % virus load lower and upper bounds
                indStart = indInitial+(iRun-1)*indDelta;
                indEnd = iRun*indDelta;
                vloadLbRg = sprintf('%s%d:%s%d',fmt.oo_mmVlLbLet,indStart,fmt.oo_mmVlLbLet,indEnd);
                writematrix(poolset.VloadLb{iRun},Params.optExcelID,...
                        'Sheet',Params.sheetID,'Range',vloadLbRg); % sample virus load lower bound from oo_mm

                vloadUbRg = sprintf('%s%d:%s%d',fmt.oo_mmVlUpLet,indStart,fmt.oo_mmVlUpLet,indEnd);
                writematrix(poolset.VloadUb{iRun},Params.optExcelID,...
                        'Sheet',Params.sheetID,'Range',vloadUbRg); % sample virus load upper bound from oo_mm
                
                % qualitative status
                indStart = indInitial+(iRun-1)*indDelta;
                indEnd = iRun*indDelta;
                statusRg = sprintf('%s%d:%s%d',fmt.oo_mmStatusLet,indStart,fmt.oo_mmStatusLet,indEnd);
                writematrix(poolset.sampStatus{iRun},Params.optExcelID,...
                        'Sheet',Params.sheetID,'Range',statusRg); % oo_mm status of each sample

                % potential positive sample index set
                if isempty(poolset.sampPos{iRun})
                    indPosStr = 'NA';
                else
                    indPosStr = sprintf('%d,',poolset.sampPos{iRun});
                end
                posRg = sprintf('%s%d',fmt.oo_mmStatusLet,indEnd+1);
                writematrix(indPosStr,Params.optExcelID,...
                    'Sheet',Params.sheetID,'Range',posRg); % potential positive sample indices


            end

        end

    end
end
