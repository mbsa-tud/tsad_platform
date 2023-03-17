function [tmpScores, filesTest] = GT_trainAndEvaluateAllModels(datasetPath, models_DNN, models_CML, models_S, ...
                                        preprocMethod, ratioTestVal, thresholds, dynamicThresholdSettings, trainingPlots, trainParallel,augmentationChoice,intensity,trained)
%GT_TRAINANDEVALUATEALLMODELS Trains all specified models on a single dataset
%with data augmentation and returns all scores and testing file names

fprintf('\nLoading data\n\n')
% Loading data
[rawDataTrain, ~, labelsTrain, ~, ...
    rawDataTest, ~, labelsTest, filesTest, ~] = loadCustomDataset(datasetPath);

if isempty(rawDataTest) && isempty(rawDataTrain)
    error("Invalid dataset selected");
end

numChannels = size(rawDataTest{1, 1}, 2);


fprintf('\nPreprocessing data with method: %s\n\n', preprocMethod);
% Preprocessing
[dataTrain, dataTest, ~] = preprocessData(rawDataTrain, ...
                                            rawDataTest, ...
                                            preprocMethod, ...
                                            false, ...
                                            []); 
% Augmentation
[dataTrain,dataTest]=augmentationData(dataTrain,dataTest,augmentationChoice,intensity,trained);

% Splitting test/val set
[dataTest, labelsTest, filesTest, ...
    dataTestVal, labelsTestVal, ~] = splitTestVal(dataTest, labelsTest, filesTest, ratioTestVal);

% Training DNN models
if ~isempty(models_DNN)
    fprintf('\nTraining DNN models\n\n')

    if trainParallel
        % This logic is required to corerctly determine which
        % models to train in parallel. Univariate models, which
        % train a separate model for every channel of multivariate
        % data, are trained parallel independently of one another
        
        if numChannels == 1
            models_DNN_parallel = models_DNN;
            models_DNN_consecutive = [];
        else
            models_DNN_parallel = [];
            models_DNN_consecutive = [];
            for i = 1:numel(models_DNN)
                if models_DNN(i).modelOptions.isMultivariate
                    models_DNN_parallel = [models_DNN_parallel, models_DNN(i)];
                else
                    models_DNN_consecutive = [models_DNN_consecutive, models_DNN(i)];
                end
            end
        end


        if ~isempty(models_DNN_parallel)
            trainedModels_tmp = trainModels_DNN_Parallel(models_DNN_parallel, ...
                                                            dataTrain, ...
                                                            labelsTrain, ...
                                                            dataTestVal, ...
                                                            labelsTestVal, ...
                                                            thresholds, ...
                                                            trainingPlots, ...
                                                            false);
            fields = fieldnames(trainedModels_tmp);
            for f_idx = 1:length(fields)
                trainedModels.(fields{f_idx}) = trainedModels_tmp.(fields{f_idx});
            end
        end
        if ~isempty(models_DNN_consecutive)
            trainedModels_tmp = trainModels(models_DNN_consecutive, ...
                                        dataTrain, ...
                                        labelsTrain, ...
                                        dataTestVal, ...
                                        labelsTestVal, ...
                                        thresholds, ...
                                        trainingPlots, ...
                                        true);
            fields = fieldnames(trainedModels_tmp);
            for f_idx = 1:length(fields)
                trainedModels.(fields{f_idx}) = trainedModels_tmp.(fields{f_idx});
            end
        end
    else
        trainedModels_tmp = trainModels(models_DNN, ...
                                        dataTrain, ...
                                        labelsTrain, ...
                                        dataTestVal, ...
                                        labelsTestVal, ...
                                        thresholds, ...
                                        trainingPlots, ...
                                        false);
        fields = fieldnames(trainedModels_tmp);
        for f_idx = 1:length(fields)
            trainedModels.(fields{f_idx}) = trainedModels_tmp.(fields{f_idx});
        end
    end
end

% Training CML models
if ~isempty(models_CML)
    fprintf('\nTraining CML models\n\n')
    trainedModels_tmp = trainModels(models_CML, ...
                                        dataTrain, ...
                                        labelsTrain, ...
                                        dataTestVal, ...
                                        labelsTestVal, ...
                                        thresholds, ...
                                        'none', ...
                                        false);
    fields = fieldnames(trainedModels_tmp);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_tmp.(fields{f_idx});
    end
end

% Training S models
if ~isempty(models_S)
    fprintf('\nTraining Statistical models\n\n')
    trainedModels_tmp = trainModels(models_S, ...
                                        dataTrain, ...
                                        labelsTrain, ...
                                        dataTestVal, ...
                                        labelsTestVal, ...
                                        thresholds, ...
                                        'none', ...
                                        false);
    fields = fieldnames(trainedModels_tmp);
    for f_idx = 1:length(fields)
        trainedModels.(fields{f_idx}) = trainedModels_tmp.(fields{f_idx});
    end
end

tmpScores = cell(length(thresholds), 1);
for tmpIdx = 1:length(tmpScores)
    tmpScores{tmpIdx, 1} = cell(length(filesTest), 1);
end


% Detection
if ~isempty(trainedModels)
    fprintf('\nDetecting with models\n\n')
    fields = fieldnames(trainedModels);

    for modelIdx = 1:length(fields)
        trainedModel = trainedModels.(fields{modelIdx});
        
        fprintf("Detecting with: %s\n", trainedModel.modelOptions.label);

        % For all files in the test folder
        for dataIdx = 1:length(filesTest)
            [XTest, YTest, labels] = prepareDataTest(trainedModel.modelOptions, dataTest(dataIdx, 1), labelsTest(dataIdx, 1));
                
            anomalyScores = detectWith(trainedModel, XTest, YTest, labels);
            
            % For all thresholds in the thresholds variable
            for thrIdx = 1:length(thresholds)
                if ~trainedModel.modelOptions.outputsLabels
                    [predictedLabels, ~] = applyThresholdToAnomalyScores(trainedModel, anomalyScores, labels, thresholds(thrIdx), dynamicThresholdSettings);
                else
                    predictedLabels = anomalyScores;
                end

                [scoresPointwise, scoresEventwise, ...
                    scoresPointAdjusted, scoresComposite] = calcScores(predictedLabels, labels);
                
                fullScores = [scoresPointwise(3); ...
                                scoresEventwise(3); ...
                                scoresPointAdjusted(3); ...
                                scoresComposite(1); ...
                                scoresPointwise(4); ...
                                scoresEventwise(4); ...
                                scoresPointAdjusted(4); ...
                                scoresComposite(2); ...
                                scoresPointwise(1); ...
                                scoresEventwise(1); ...
                                scoresPointAdjusted(1); ...
                                scoresPointwise(2); ...
                                scoresEventwise(2); ...
                                scoresPointAdjusted(2)];
        
                tmp = tmpScores{thrIdx, 1};
                tmp{dataIdx, 1} = [tmp{dataIdx, 1}, fullScores];
                tmpScores{thrIdx, 1} = tmp;
            end
        end
    end
end
end