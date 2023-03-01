function anomalyScores = detectWithS_wrapper(trainedModel, XTest, YTest, labels)
%DETECTWITHS
%
% Runs the detection for statistical models and returns anomaly Scores
fprintf("Detecting with: %s\n", trainedModel.options.model);

if trainedModel.options.isMultivariate
    % For multivariate models
    if ~isempty(trainedModel.Mdl)
        Mdl_tmp = trainedModel.Mdl{1, 1};
    else
        Mdl_tmp = trainedModel.Mdl;
    end

    anomalyScores = detectWithS(trainedModel.options, Mdl_tmp, XTest{1, 1}, YTest{1, 1}, labels);
else
    numChannels = size(XTest, 2);

    anomalyScores = [];
    for i = 1:numChannels
        if ~isempty(trainedModel.Mdl)
            Mdl_tmp = trainedModel.Mdl{i, 1};
        else
            Mdl_tmp = trainedModel.Mdl;
        end

        anomalyScores_tmp  = detectWithS(trainedModel.options, Mdl_tmp, XTest{1, i}, YTest{1, i}, labels);
        anomalyScores = [anomalyScores, anomalyScores_tmp];
    end
end

if trainedModel.options.outputsLabels
    anomalyScores = any(anomalyScores, 2);
    return;
end

numChannels = size(anomalyScores, 2);

if isfield(trainedModel.options, 'hyperparameters')
    if isfield(trainedModel.options.hyperparameters, 'scoringFunction')
        % Apply scoring function
        switch trainedModel.options.hyperparameters.scoringFunction.value
            case 'separate'
            case 'aggregated'
                if numChannels > 1
                    anomalyScores = rms(anomalyScores, 2);
                end
            otherwise
                % Do nothing
        end
    end
end
end
