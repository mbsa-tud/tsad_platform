function Mdl = trainCML(options, XTrain, YTrain)
%TRAINCML
%
% Trains the classic ML model specified in the options parameter

switch options.model
    case 'OC-SVM'
        Mdl = fitcsvm(XTrain, ones(size(XTrain, 1), 1));
    case 'iForest'
        [Mdl, ~, ~] = iforest(XTrain, NumLearners=options.hyperparameters.numLearners.value, NumObservationsPerLearner=options.hyperparameters.numObservationsPerLearner.value);
    otherwise
        Mdl = [];
end
end
