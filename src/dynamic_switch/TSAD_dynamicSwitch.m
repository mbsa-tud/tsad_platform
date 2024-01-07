classdef TSAD_dynamicSwitch
    %DYNAMICSWITCH Dynamic switch class providing methods to traing and
    %test the model selection mechanism
    
    properties (Access = private)
        % Models
        models

        % Dynamic switch classifier
        classifier
    end
    
    methods (Access = public)
        function obj = TSAD_dynamicSwitch()
            %DYNAMICSWITCH Construct an instance of this class
        end

        function obj = fit(obj, models, dataTrain, labelsTrain, fileNames)
            %FIT trains classifier to predict best model for specific time
            %series

            obj.models = models;
            
            [XTrain, labelName] = obj.prepareTrainingData(dataTrain, labelsTrain, fileNames);
            obj.classifier = obj.fitClassifier(XTrain, labelName);
        end

        function [finalTable, selectedModels] = evaluate(obj, dataTest, labelsTest, threshold, dynamicThresholdSettings)
            % EVALUATE Tests the dynamic switch and compares it to the
            % performance of all individual models
        
            numTestFiles = numel(dataTest);
            modelIDs = fieldnames(obj.models);
            numModels = numel(modelIDs);
            allModelNames = strings(numModels, 1);
            
            for i = 1:numModels
                allModelNames(i) = obj.models.(modelIDs{i}).instanceInfo.label;
            end
            
            fullScores_Switch = cell(numTestFiles, 1);
            fullScores = cell(numTestFiles, 1);
            
            selectedModels = strings(numTestFiles, 1);
            
            for i = 1:numTestFiles
                fullScores_Switch{i} = obj.detectAndScore(dataTest(i), labelsTest(i), threshold, dynamicThresholdSettings);
                fullScores{i} = obj.detectAndScoreAll(dataTest(i), labelsTest(i), threshold, dynamicThresholdSettings);
            end        
            
            averages = calcAverageScores(fullScores_Switch);
            averages = [averages calcAverageScores(fullScores)];
            
            scoreNames = table(METRIC_NAMES);
            scoreNames.Properties.VariableNames = "Metric";
            
            averagesTable = array2table(averages);
            averagesTable.Properties.VariableNames = ["Dynamic Switch"; allModelNames];
            
            finalTable = [scoreNames, averagesTable];
        end

        function [anomalyScores, predictedLabels, labels] = detect(obj, dataTest, labelsTest, threshold, dynamicThresholdSettings)
            %DETECT Detect anomalies using model selection mechanism
            
            % Extract features
            XTest = obj.getTimeSeriesFeatures(dataTest);

            % classifier chooses model and uses it to detect anomalies
            pred = string(classify(obj.classifier, XTest));
                        
            [anomalyScores, ~, labels, ~] = obj.models.(pred).detect(dataTest, labelsTest);
            
            [predictedLabels, ~] = obj.models.(pred).applyThreshold(anomalyScores, labels, threshold, dynamicThresholdSettings, []);        
        end

        function scores = detectAndScore(obj, dataTest, labelsTest, threshold, dynamicThresholdSettings)
            %DETECTANDSCORE Detect anomalies using model selection mechanism and
            %return scores
            
            % Extract features
            XTest = obj.getTimeSeriesFeatures(dataTest);

            % classifier chooses model and uses it to detect anomalies
            pred = string(classify(obj.classifier, XTest));
                        
            [anomalyScores, ~, labels, ~] = obj.models.(pred).detect(dataTest, labelsTest);
            
            [predictedLabels, ~] = obj.models.(pred).applyThreshold(anomalyScores, labels, threshold, dynamicThresholdSettings, []);

            scores = computeMetrics(anomalyScores, predictedLabels, labels);
        end

        function scores = detectAndScoreAll(obj, dataTest, labelsTest, threshold, dynamicThresholdSettings)
            %DETECTANDSCOREALL Detect anomalies using all models and
            %return scores
            
            % Detect for all models
            modelIDs = fieldnames(obj.models);
            numModels = numel(modelIDs);

            scores = [];

            for i = 1:numModels
                [anomalyScores, ~, labels, ~] = obj.models.(modelIDs{i}).detect(dataTest, labelsTest);
            
                [predictedLabels, ~] = obj.models.(modelIDs{i}).applyThreshold(anomalyScores, labels, threshold, dynamicThresholdSettings, []);
                scores = [scores, computeMetrics(anomalyScores, predictedLabels, labels)];
            end                   
        end
    end

    methods (Access = private)
        function features = getTimeSeriesFeatures(obj, inputData)
            %getTimeSeriesFeatures Computes statistical features of time series data
            
            features = [];
            
            for channel_idx = 1:size(inputData, 2)
                % For every channel of the dataset compute the same features
                try
                    data = inputData(:, channel_idx);
            
                    % Compute signal features
                    ClearanceFactor = max(abs(data))/(mean(sqrt(abs(data)))^2);
                    CrestFactor = peak2rms(data);
                    ImpulseFactor = max(abs(data))/mean(abs(data));
                    Kurtosis = kurtosis(data);
                    Mean = mean(data,"omitnan");
                    PeakValue = max(abs(data));
                    SINAD = sinad(data);
                    SNR = snr(data);
                    ShapeFactor = rms(data,"omitnan")/mean(abs(data),"omitnan");
                    Skewness = skewness(data);
                    Std = std(data,"omitnan");
                
                    % Concatenate signal features.
                    features = [features, ClearanceFactor, ...
                                CrestFactor, ...
                                ImpulseFactor,...
                                Kurtosis,...
                                Mean, ...
                                PeakValue, ...
                                SINAD,...
                                SNR,...
                                ShapeFactor,...
                                Skewness,...
                                Std];
                catch
                    % Package computed features into a table.
                    features = [features, NaN(1, 11)];
                end
            end
            
            features = array2table(features);
            % features.Properties.VariableNames = ["ClearanceFactor", ...
            %                                         "CrestFactor", ...
            %                                         "ImpulseFactor", ...
            %                                         "Kurtosis", ...
            %                                         "Mean", ...
            %                                         "PeakValue", ...
            %                                         "SINAD", ...
            %                                         "SNR", ...
            %                                         "ShapeFactor", ...
            %                                         "Skewness", ...
            %                                         "Std"];
        end

        function [XTrain, labelName] = prepareTrainingData(obj, data, labels, fileNames)
            %PREPARETRAININGDATA Prepares the training data for the dynamic switch
            
            labelName = "best_model";
            
            labelNames = fieldnames(labels);
            
            XTrain = [];
            
            for i = 1:numel(labelNames)
                % Check if file is available in training data
                [exists, file_idx] = ismember(labelNames{i}, fileNames);
                
                % If not then skip
                if ~exists
                    continue;
                end
            
                % Convert time series to feature vector
                XTrain_tmp = obj.getTimeSeriesFeatures(data{file_idx, 1});
                XTrain_tmp.(labelName) = convertCharsToStrings(labels.(labelNames{i}).id);
                XTrain = [XTrain; XTrain_tmp];
            end
            
            XTrain = convertvars(XTrain, labelName, "categorical");
        end

        function mdl = fitClassifier(obj, XTrain, labelName)
            %FITCLASSIFIER Trains the dynamic switch DNN classifier
            
            classNames = categories(XTrain{:, labelName});
            numFeatures = size(XTrain, 2) - 1;
            numClasses = numel(classNames);
            
            miniBatchSize = 64;
            
            options = trainingOptions("adam", ...
                "InitialLearnRate", 0.01, ...
                "MaxEpochs", 1500, ...
                "MiniBatchSize", miniBatchSize, ...
                "Shuffle", "every-epoch", ...
                "Plots", "training-progress", ...
                "Verbose", false);
            
            layers = [
                featureInputLayer(numFeatures)
                fullyConnectedLayer(50)
                batchNormalizationLayer
                reluLayer
                fullyConnectedLayer(numClasses)
                softmaxLayer
                classificationLayer];
            
            mdl = trainNetwork(XTrain, labelName, layers, options);
        end
    end
end

