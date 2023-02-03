function Mdl = trainS_wrapper(options, XTrain)
%TRAINS
%
% Train the statistical models here

if options.isMultivariate
    Mdl = trainS(options, XTrain{1, 1});
    Mdl = {Mdl};
else
    numChannels = size(XTrain, 2);

    % Train the same model for each channel seperately
    Mdl = cell(numChannels, 1);

    for i = 1:numChannels
        Mdl{i, 1} = trainS(options, XTrain{1, i});
    end
end
end