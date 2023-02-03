function Mdl = trainCML_wrapper(options, XTrain)
%TRAINCML
%
% Trains the classic ML model specified in the options parameter

if options.isMultivariate
    Mdl = trainCML(options, XTrain{1, 1});
    Mdl = {Mdl};
else
    numChannels = size(XTrain, 2);

    % Train the same model for each channel seperately
    Mdl = cell(numChannels, 1);

    for i = 1:numChannels
        Mdl{i, 1} = trainCML(options, XTrain{1, i});
    end
end
end
