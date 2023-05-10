function Mdl = train_Other(modelOptions, XTrain, YTrain)
%TRAINCML Trains the classic ML model specified in the modelOptions parameter

switch modelOptions.name
    case "Your model name"
    case "OC-SVM"
        Mdl = ocsvm(XTrain, KernelScale="auto");
    case "iForest"
        [Mdl, ~, ~] = iforest(XTrain, NumLearners=modelOptions.hyperparameters.numLearners, NumObservationsPerLearner=modelOptions.hyperparameters.numObservationsPerLearner);
    otherwise
        Mdl = [];
end
end
