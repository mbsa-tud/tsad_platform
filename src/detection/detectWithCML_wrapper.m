function anomalyScores = detectWithCML_wrapper(options, Mdl, XTest, YTest, labels)
%DETECTWITHCML
%
% Runs the detection for classic ML models and returns anomaly Scores

if options.isMultivariate
    % For multivariate models
    if ~isempty(Mdl)
        Mdl_tmp = Mdl{1, 1};
    else
        Mdl_tmp = Mdl;
    end

    anomalyScores = detectWithCML(options, Mdl_tmp, XTest{1, 1}, YTest{1, 1}, labels);
else
    numChannels = size(XTest, 2);

    anomalyScores = [];
    for i = 1:numChannels
        if ~isempty(Mdl)
            Mdl_tmp = Mdl{i, 1};
        else
            Mdl_tmp = Mdl;
        end

        anomalyScores_tmp  = detectWithCML(options, Mdl_tmp, XTest{1, i}, YTest{1, i}, labels);
        anomalyScores = [anomalyScores, anomalyScores_tmp];
    end
end

if options.outputsLabels
    anomalyScores = any(anomalyScores, 2);
    return;
end

numChannels = size(anomalyScores, 2);

if isfield(options, 'scoringFunction')
    % Apply scoring function
    switch options.scoringFunction
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
