function Mdl = trainCML(options, XTrain)
% Train model
switch options.model
    case 'OC-SVM'
        rng('default');
        Mdl = fitcsvm(XTrain, ones(size(XTrain, 1), 1));
    otherwise
        Mdl = [];
end
end
