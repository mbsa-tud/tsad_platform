function [XTest, YTest, labels] = prepareDataTest_S(options, dataTest, labelsTest)
%PREPAREDATATEST_S
%
% Prepares the testing data for statistical models

switch options.model
    case 'Your model'
    otherwise
        if options.useSubsequences
            [XTest, YTest, labels] = splitDataTest(dataTest, labelsTest, ...
                options.hyperparameters.data.windowSize.value, ...
                'reconstructive', options.dataType, options.isMultivariate);
        else
            if options.isMultivariate
                XTest = dataTest;
                YTest = XTest;
                labels = cell2mat(labelsTest);
            else
                numChannels = size(dataTest{1, 1}, 2);
                XTest = cell(1, numChannels);
                for i = 1:numChannels
                    XTest{1, i} = dataTest{1, 1}(:, i);
                end
                YTest = XTest;
                labels = cell2mat(labelsTest);
            end
        end
    end
end
