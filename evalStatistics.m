classdef evalStatistics

    properties(Access=private)

        % evaluation metrics
        efccy; % number of tests per sample
        sstvt; % sensitivity; True P/Groundtruth_positive
        spcfct; % specificity; 1 - True N/Groundtruth_negative


    end

    properties(Access=public)

        sampVload; % truth individual sample virus load
        sampStatus; % truth individual sample status
        sampVloadEst; % estimated individual sample virus load
        sampStatusEst; % estimated individual sample status
        poolMatrix; % effective pooling matrix

    end

    methods

        function obj = evalStatistics(data)
            % data, structure with fields sampVload, sampVloadEst,
            % sampStatus, sampStatusEst, poolMatrix

            obj.sampVload = data.sampVload;
            obj.sampStatus = data.sampStatus;
            obj.sampVloadEst = data.sampVloadEst;
            obj.sampStatusEst = data.sampStatusEst;
            obj.poolMatrix = data.poolMatrix;

            obj = obj.evaluate();

        end

        function obj = evaluate(obj)
            % calculate evaluation metrics
            obj = obj.efficiency();
            obj = obj.sensitivity();
            obj = obj.specificity();

            fprintf('Evaluation has been completed.\n')

        end

        function obj = efficiency(obj)
            % calculate efficiency
            obj.efccy = size(obj.poolMatrix,1) / size(obj.poolMatrix,2);
        end

        function obj = sensitivity(obj)
            % calculate sensitivity: true positive / (all ground truth
            % positives)
            groundPIdxes = find(obj.sampStatus==1);
            decode = obj.sampStatusEst(groundPIdxes);
            decodePIdxes = find(decode==1);
            obj.sstvt = length(decodePIdxes) / length(groundPIdxes);
        end

        function obj = specificity(obj)
            % calculate specificity: true negative/(all ground truth
            % negatives)
            groundNIdxes = find(obj.sampStatus==0);
            decode = obj.sampStatusEst(groundNIdxes);
            decodePIdxes = find(decode==1);
            obj.spcfct = 1 - length(decodePIdxes) / length(groundNIdxes);

        end

        function [efccy,sstvt,spcfct] = getResults(obj)
            % get evaluation metrics values, [efccy,sstvt,spcfct]
            efccy = obj.efccy;
            sstvt = obj.sstvt;
            spcfct = obj.spcfct;
        end

    end

end