function [XTest, YTest, labels] = prepareDataTest_CML(options, dataTest, labelsTest)
%PREPAREDATATEST_CML
%
% Prepares the testing data for classic ML models

switch options.model
    case 'Your model'
    case 'Merlin'
        XTest = cell2mat(dataTest);
        YTest = XTest;
        labels = cell2mat(labelsTest);
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
