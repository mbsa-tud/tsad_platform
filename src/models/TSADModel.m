classdef TSADModel
    %TSADMODEL Abstract parent class for models which can be used within the TSAD
    %platform
    %   TODO: write detailed summary here
    
    properties (GetAccess = public, SetAccess = protected)
        % Contains information about model like: name, dimensionality,
        % learning-type, etc.
        modelInfo % Struct

        % Contains configurable hyperparameters of the model
        hyperparameters % Struct

        % Required to differentiate between multiple instances of same
        % model
        instanceInfo % Struct



        % Trained model (empty for unsupervised models)
        Mdl = 23
        
        % Static thresholds, possibly learned during training (if anomalous
        % validation data is used)
        staticThresholds % Struct

        % Determines wether model has been trained and is ready for
        % tetsting
        isTrained % Bool

        % Determines input dimension model was trained on (Avoids errors
        % later on)
        trainedDimensionality % Int

        % Training anomaly scores, possibly required for scoring functions,
        % threshold calculation, etc.
        trainingAnomalyScoresRaw % Nxd double array
        trainingAnomalyScoreFeatures % Struct
        trainingLabels % Nx1 logical array
    end
    
    %% Public methods which can be called outside of the class
    methods (Access = public)
        function obj = TSADModel(config, instanceInfo)
            %TSADMODEL Construct an instance of this class
            obj = obj.initModelInfo();

            % If provided, assign hyperparameters
            if isfield(config, "hyperparameters")
                obj.hyperparameters = config.hyperparameters;
            end

            % Assign instance info
            obj.instanceInfo = instanceInfo;
            
            % If provided, assign/reassign modelInfo fields
            if (isfield(config, "modelInfo"))
                infoFields = fieldnames(config.modelInfo);
                for i = 1:length(infoFields)
                    obj.modelInfo.(infoFields{i}) = config.modelInfo.(infoFields{i});
                end
            end

            % For unsupervised models, set isTrained to True to enable
            % testing right away (no training step needed)
            if strcmp(obj.modelInfo.learningType, "unsupervised")
                obj.isTrained = true;
            else
                obj.isTrained = false;
            end
        end
    
        function obj = trainingWrapper(obj, dataTrain, labelsTrain, dataTestVal, labelsTestVal, thresholds, plots, verbose)
            %TRAININGWRAPPER Main wrapper function for model training

            fprintf("Training: %s ...\n", obj.instanceInfo.label);
            
            % Check learning type and fit if "semi-supervised" or
            % "supervised"
            if ~strcmp(obj.modelInfo.learningType, "unsupervised")
                    if isempty(dataTrain)
                        error("The %s model requires prior training, but the dataset doesn't contain training data (fit folder).", obj.instanceInfo.label);
                    end
                    
                    % Save dimensionality of data
                    obj.trainedDimensionality = size(dataTrain{1}, 2);
                    
                    % fit model
                    [XTrain, YTrain, XVal, YVal] = obj.dataTrainPreparationWrapper(dataTrain, labelsTrain);
                    if strcmp(obj.modelInfo.dimensionality, "multivariate")
                        % fit single model on entire data if model is
                        % multivariate

                        mdl = obj.fit(XTrain{1}, YTrain{1}, XVal{1}, YVal{1}, plots, verbose);

                        obj.Mdl = {mdl};
                    else
                        % Else fit the same model for each channel seperately
                        
                        numChannels = numel(XTrain);
                        mdl = cell(numChannels, 1);
                    
                        for channel_idx = 1:numChannels
                            mdl{channel_idx} = obj.fit(XTrain{channel_idx}, YTrain{channel_idx}, XVal{channel_idx}, YVal{channel_idx}, plots, verbose);
                        end
                        obj.Mdl = mdl;
                    end
                    
                    % Get static thresholds and training anomaly scores
                    if strcmp(obj.modelInfo.outputType, "anomaly-scores")
                        obj.getTrainingAnomalyScoreFeatures(dataTrain, labelsTrain);
                        
                        % Compute thresholds for semi-supervised models
                        if strcmp(obj.modelInfo.learningType, "semi-supervised")
                            obj.getStaticThresholds(dataTestVal, labelsTestVal, thresholds);
                        end
                    end
            end
            
            % Training finished
            obj.isTrained = true;
            
            fprintf("Successfully trained: %s!\n", obj.instanceInfo.label);
        end
        
        function [anomalyScores, TSTest, labelsTest, computationTime] = detectionWrapper(obj, data, labels, getComputationTime, applyScoringFunction)
            %DETECTIONWRAPPER Main detection wrapper function
            
            if ~exist("getComputationTime", "var")
                getComputationTime = false; % Don't get computation time by default
            end
            if ~exist("applyScoringFunction", "var")
                applyScoringFunction = true; % Apply scoring function by default
            end

            % Prepare data
            [XTest, TSTest, labelsTest] = obj.dataTestPreparationWrapper(data, labels);
            
            % Handle detection
            if strcmp(obj.modelInfo.dimensionality, "multivariate")
                % For multivariate models
                
                if ~isempty(obj.Mdl)
                    Mdl_tmp = obj.Mdl{1};
                else
                    Mdl_tmp = [];
                end
            
                [anomalyScores, computationTime] = obj.predict(Mdl_tmp, XTest{1}, TSTest{1}, labelsTest, getComputationTime);
            else
                % For univariate models which are trained separately for each channel
                numChannels = numel(XTest);
            
                anomalyScores = [];
                compTimes = [];

                for channel_idx = 1:numChannels
                    if ~isempty(obj.Mdl)
                        Mdl_tmp = obj.Mdl{channel_idx};
                    else
                        Mdl_tmp = [];
                    end
                    
                    [anomalyScores_tmp, compTime_tmp] = obj.predict(Mdl_tmp, XTest{channel_idx}, TSTest{channel_idx}, labelsTest, getComputationTime);
                    anomalyScores = [anomalyScores, anomalyScores_tmp];
                    compTimes = [compTimes, compTime_tmp];
                end
                
                computationTime = sum(compTimes);
            end

            
            % Bypass scoring function for models which output binary
            % classification instead of anomaly scores
            if ~strcmp(obj.modelInfo.outputType, "anomaly-scores")
                anomalyScores = any(anomalyScores, 2);
                return;
            end
            
            % Apply optional scoring function
            if applyScoringFunction
                anomalyScores = obj.applyScoringFunction(anomalyScores);
            end
        end
        
        function obj = updateHyperparameters(obj, newHyperparameters)
            %UPDATEHYPERPARAMETERS Converts the hyperparameters provided by
            %the newHyperparameters
            
            newHyperparameterNames = newHyperparameters.Properties.VariableNames;
            for i = 1:numel(newHyperparameterNames)
                if isfield(obj.hyperparameters, newHyperparameterNames{i})
                    if iscategorical(newHyperparameters{1, i})
                        if isnumeric(obj.hyperparameters.(newHyperparameterNames{i}))
                            newValue = double(string(newHyperparameters{1, i}(1)));
                        else
                            newValue = string(newHyperparameters{1, i}(1));
                        end
                    else
                        newValue = newHyperparameters{1, i};
                    end
            
                    obj.hyperparameters.(newHyperparameterNames{i}) = newValue;
                    continue;
                else
                    warning("Your trying to optimize a hyperparameter which is not defined in the hyperparameters struct of your model");
                end
            end
        end

        function obj = setModelInfo(obj, modelInfo)
            obj.modelInfo = modelInfo;
        end
    
        function modelInfo = getModelInfo(obj)
            %GETMODELINFO Returns the modelInfo of the model

            modelInfo = obj.modelInfo;
        end

        function layers = getNeuralNetworkLayers(obj)
            %GETNEURALNETWORKLAYERS If the model is a neural network, it
            %will return the layers (if getLayers function is implemented
            %in subclass)

            layers = obj.getLayers([], []);
        end
    end

    %% Private methods. Only called from within the class
    methods (Access = private)
        function [XTrain, YTrain, XVal, YVal] = dataTrainPreparationWrapper(obj, data, labels)
            %DATATRAINPREPARATIONWRAPPER Main wrapper function for training
            %data preparation

            if strcmp(obj.modelInfo.dimensionality, "multivariate")
                % Prepare data for multivariate model

                [XTrain, YTrain, XVal, YVal] = obj.prepareDataTrain(data, labels);
                XTrain = {XTrain};
                YTrain = {YTrain};
                XVal = {XVal};
                YVal = {YVal};
            else
                % Prepare data for univariate model (separte for every
                % channel)

                numChannels = size(data{1}, 2);
            
                XTrain = cell(1, numChannels);
                YTrain = cell(1, numChannels);
                XVal = cell(1, numChannels);
                YVal = cell(1, numChannels);
            
                for channel_idx = 1:numChannels
                    % Get same channel from all files
                    data_tmp = cell(numel(data), 1);
                    for file_idx = 1:numel(data)
                        data_tmp{file_idx} = data{file_idx}(:, channel_idx);
                    end
            
                    [XTrain{channel_idx}, YTrain{channel_idx}, XVal{channel_idx}, YVal{channel_idx}] = obj.prepareDataTrain(data_tmp, labels);
                end
            end
        end
        
        function [XTest, TSTest, labelsTest] = dataTestPreparationWrapper(obj, data, labels)
            %DATATESTPREPARATIONWRAPPER Main wrapper function for testing
            %data preparation
            
            if strcmp(obj.modelInfo.dimensionality, "multivariate")
                % Prepare data for multivariate model

                [XTest, TSTest, labelsTest] = obj.prepareDataTest(data, labels);
                XTest = {XTest};
                TSTest = {TSTest};
            else
                % Prepare data for univariate model (separte for every
                % channel)

                numChannels = size(data{1}, 2);
                XTest = cell(1, numChannels);
                TSTest = cell(1, numChannels);
            
                for channel_idx = 1:numChannels
                    % Get same channel from all files
                    data_tmp = cell(numel(data), 1);
                    for j = 1:numel(data)
                        data_tmp{j} = data{j}(:, channel_idx);
                    end
            
                    [XTest{channel_idx}, TSTest{channel_idx}, labelsTest] = obj.prepareDataTest(data_tmp, labels);
                end
            end
        end

        function obj = getStaticThresholds(obj, data, labels, thresholds)
            %GETSTATICTHRESHOLDS Computes static thresholds
                        
            obj.staticThresholds = [];
            
            if ~isempty(data)
                % Count anomalies
                numAnoms = 0;
            
                for file_idx = 1:numel(data)            
                    numAnoms = numAnoms + sum(labels{file_idx} == 1);
                end
            
                anomalyScoresTest = [];
                labelsTest = [];
                
                % Merge anomaly scores for all files in data
                for file_idx = 1:numel(data)
                    [anomalyScores_tmp, ~, labelsTest_tmp, ~] = obj.detectionWrapper(data(file_idx), labels(file_idx), false, true);
                    anomalyScoresTest = [anomalyScoresTest; anomalyScores_tmp];
                    labelsTest = [labelsTest; labelsTest_tmp];
                end
                
                % Compute all thresholds which are set using anomaly scores for test validation data
                if numAnoms ~= 0
                    if ismember("bestF1ScorePointwise", thresholds)
                        obj.staticThresholds.bestF1ScorePointwise = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScorePointwise", obj.modelInfo.name);
                    end
                    if ismember("bestF1ScoreEventwise", thresholds)
                        obj.staticThresholds.bestF1ScoreEventwise = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScoreEventwise", obj.modelInfo.name);
                    end
                    if ismember("bestF1ScorePointAdjusted", thresholds)
                        obj.staticThresholds.bestF1ScorePointAdjusted = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScorePointAdjusted", obj.modelInfo.name);
                    end
                    if ismember("bestF1ScoreComposite", thresholds)
                        obj.staticThresholds.bestF1ScoreComposite = calcStaticThreshold(anomalyScoresTest, labelsTest, "bestF1ScoreComposite", obj.modelInfo.name);
                    end            
                else
                    warning("Warning! Anomalous validation set doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
                end
        
                if ismember("topK", thresholds)
                    obj.staticThresholds.topK = calcStaticThreshold(anomalyScoresTest, labelsTest, "topK", obj.modelInfo.name);
                end
            end
            
            % Get all thresholds which are set using anomaly scores for fit data
            if ~isempty(obj.trainingAnomalyScoresRaw)
                if ismember("meanStdTrain", thresholds) || ismember("maxTrainAnomalyScore", thresholds)    
                    anomalyScoresTrain = obj.applyScoringFunction(obj.trainingAnomalyScoresRaw);
                end
                
                if ismember("meanStdTrain", thresholds)
                    obj.staticThresholds.meanStdTrain = mean(mean(anomalyScoresTrain)) + 4 * mean(std(anomalyScoresTrain));
                end
                if ismember("maxTrainAnomalyScore", thresholds)
                    obj.staticThresholds.maxTrainAnomalyScore = max(max(anomalyScoresTrain));
                end
            end
            
            % Get all thresholds which don't require anomaly scores
            if ismember("pointFive", thresholds)
                obj.staticThresholds.pointFive = calcStaticThreshold([], [], "pointFive", obj.modelInfo.name);
            end
            if ismember("custom", thresholds)
                obj.staticThresholds.custom = calcStaticThreshold([], [], "custom", obj.modelInfo.name);
            end
        end
    
        function obj = getTrainingAnomalyScoreFeatures(obj, data, labels)
            %GETTRAININGANOMALYSCOREFEATURES Get the raw anomaly scores and their
            %statistical features for the training data
                        
            obj.trainingAnomalyScoresRaw = [];
            obj.trainingLabels = [];
            
            % Get anomaly scores for every file of training data
            for file_idx = 1:numel(data)                            
                % Get raw anomaly scores and store in one array
                [trainingAnomalyScores_tmp, ~, trainingLabels_tmp, ~] = obj.detectionWrapper(data, labels, false, false);
                obj.trainingAnomalyScoresRaw = [obj.trainingAnomalyScoresRaw; trainingAnomalyScores_tmp];
                
                % Store labels in one array
                obj.trainingLabels = [obj.trainingLabels; trainingLabels_tmp];
            end
    
            obj.trainingAnomalyScoreFeatures.mu = mean(obj.trainingAnomalyScoresRaw, 1);
            obj.trainingAnomalyScoreFeatures.covar = cov(obj.trainingAnomalyScoresRaw);
        end

        function anomalyScores = applyScoringFunction(obj, anomalyScores)
            %APPLYSCORINGFUNCTION Applys a scoring function to the anomaly scores
            
            if ~isfield(obj.hyperparameters, "scoringFunction")
                return
            end

            switch obj.hyperparameters.scoringFunction
                case "Aggregated"
                    anomalyScores = aggregatedScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu);
                case "Channel-wise"
                    anomalyScores = channelwiseScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu);
                case "Gauss"
                    anomalyScores = gaussianScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu, obj.trainingAnomalyScoreFeatures.covar);
                case "Gauss (aggregated)"
                    anomalyScores = aggregatedGaussianScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu, obj.trainingAnomalyScoreFeatures.covar);
                case "Gauss (channel-wise)"
                    anomalyScores = channelwiseGaussianScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu, obj.trainingAnomalyScoreFeatures.covar);
                case "EWMA"
                    anomalyScores = EWMAScoring(anomalyScores, 0.3);
                otherwise
                    error("Undefined scoring function");
            end
        end        
    end

    %% Protected methods. Must be overwritten by subclass according to model
    methods (Access = protected)
        function obj = initModelInfo(obj)
            obj.modelInfo.name = "You forgot to implement the initModelInfo function";
        end

        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            XTrain = [];
            YTrain = [];
            XVal = [];
            YVal = [];
        end

        function [XTest, TSTest, labelsTest] =  prepareDataTest(obj, data, labels)
            XTest = [];
            TSTest = [];
            labelsTest = [];
        end

        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            Mdl = [];
        end

        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, TSTest, labelsTest, getComputationTime)
            anomalyScores = [];
            computationTime = NaN;
        end

        function layers = getLayers(obj, XTrain, YTrain)
            layers = [];
        end
    end
end

