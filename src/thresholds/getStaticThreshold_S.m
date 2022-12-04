function staticThreshold = getStaticThreshold_S(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds)
%GETSTATICTHRESHOLD_S
%
% This function calculates the static threshold for statistical models and
% returnes them in the staticThreshold struct

switch options.model
    case 'Merlin'
        staticThreshold.dummy = 0.5;
    otherwise
        if ~isempty(dataValTest)
            XTestValCell = cell(size(dataValTest, 1), 1);
            YTestValCell = cell(size(dataValTest, 1), 1);
            labelsTestValCell = cell(size(dataValTest, 1), 1);
            
            numAnoms = 0;
            numTimeSteps = 0;

            for i = 1:size(dataValTest, 1)
                [XTestValCell{i, 1}, YTestValCell{i, 1}, labelsTestValCell{i, 1}] = prepareDataTest_S(options, dataValTest(i, 1), labelsValTest(i, 1));
                
                numAnoms = numAnoms + sum(labelsTestValCell{end} == 1);
                numTimeSteps = numTimeSteps + size(labelsTestValCell{end}, 1);
            end

            contaminationFraction = numAnoms / numTimeSteps;                       
            
            if contaminationFraction > 0
                anomalyScores = [];
                labels = [];

                for i = 1:size(XTestValCell, 1)
                    anomalyScores_tmp = detectWithS(options, Mdl, XTestValCell{i, 1}, YTestValCell{i, 1}, labelsTestValCell{i, 1});
                    anomalyScores = [anomalyScores; anomalyScores_tmp];
                    labels = [labels; labelsTestValCell{i, 1}];
                end
                
                for i = 1:length(thresholds)
                    if ~strcmp(thresholds(i), "meanStd")
                        staticThreshold.(thresholds(i)) = calcStaticThreshold(anomalyScores, labels, thresholds(i), options.model);
                
                    end
                end
            else
                error("Anomalous validation set doesn't contain anomalies");
            end
        end

        if ismember("meanStd", thresholds)
            [anomalyScores, ~, ~] = detectWithS(options, Mdl, XTrain, [], []);
            
            staticThreshold.meanStd = calcStaticThreshold(anomalyScores, [], "meanStd", options.model);
        end
end
end
