function Mdl = trainCML(options, XTrain)
%TRAINCML
%
% Trains the classic ML model specified in the options parameter

switch options.model
    case 'OC-SVM'
        rng('default');
        Mdl = fitcsvm(XTrain, ones(size(XTrain, 1), 1));
    case 'iForest'
        [Mdl, ~, ~] = iforest(XTrain, NumLearners=options.hyperparameters.model.numLearners.value);
    otherwise
        Mdl = [];
end
end
