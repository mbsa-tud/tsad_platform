function errors = getReconstructionErrors(prediction, XTest, timeSeriesTest, errorType, windowSize, dataType)
%GETRECONSTRUCTIONERRORS Computes reconstruction errors according to
%selected errorType
% data

if (~ismember(dataType, ["CBT", "BC"]))
    error("invalid dataType, must be either CBT or BC");
end

% Convert BC to CBT
if strcmp(dataType, "BC")
    numChannels = round(size(prediction, 2) / windowSize);
    numWindows = size(prediction, 1);

    predictionTmp = zeros(numChannels, numWindows, windowSize);
    XTestTmp = zeros(numChannels, numWindows, windowSize);

    for i = 1:numWindows
        for j = 1:numChannels
            predictionTmp(j, i, :) = reshape(prediction(i, ((j - 1) * windowSize + 1):((j - 1) * windowSize + windowSize)), [1, 1, windowSize]);
            XTestTmp(j, i, :) = reshape(XTest(i, ((j - 1) * windowSize + 1):((j - 1) * windowSize + windowSize)), [1, 1, windowSize]);
        end
    end

    prediction = predictionTmp;
    XTest = XTestTmp;
end

% Compute error
switch errorType
    case "pointwise"
        % calulate the point-wise errors for each subsequence and then calculate the median error for each time step
        errors = abs(prediction - XTest);                
        errors = mergeOverlappingSubsequences(errors, windowSize, @median);
    case "subsequencewise"
        % calulate the RMSE for each subsequence and channel and
        % then calculate the mean error for each time step
        errors = abs(prediction - XTest);
        numChannels = size(prediction, 1);
        numWindows = size(prediction, 2);        

        for i = 1:numWindows
            for j = 1:numChannels
                % Assign RMSE to each poit of every subsequence
                errors(j, i, :) = rms(errors(j, i, :));
            end
        end            

        errors = mergeOverlappingSubsequences(errors, windowSize, @mean);
    otherwise
        error("Unknown reconstructionErrorType");
end
end