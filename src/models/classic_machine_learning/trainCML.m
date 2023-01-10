function Mdl = trainCML(options, XTrain)
%TRAINCML
%
% Trains the classic ML model specified in the options parameter

switch options.model
    case 'OC-SVM'
        Mdl = fitcsvm(XTrain{1, 1}, ones(size(XTrain{1, 1}, 1), 1));
    case 'iForest'
        [Mdl, ~, ~] = iforest(XTrain{1, 1}, NumLearners=options.hyperparameters.model.numLearners.value);
    otherwise
        Mdl = [];
end
end
