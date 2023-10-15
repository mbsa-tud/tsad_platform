classdef TSADModel
    %TSADMODEL Abstract parent class for models which can be used within the TSAD
    %platform
    %   TODO: write detailed summary here
    
    properties (GetAccess = public, SetAccess = protected)
        % Contains information about model like: name, dimensionality,
        % learning-type, etc.
        
        % Contains static and configurable parameters of the model
        parameters; % Struct

        % Required to differentiate between multiple instances of same
        % model
        instanceInfo; % Struct

        % Trained model (empty for unsupervised models)
        Mdl = [];
        
        % Static thresholds, possibly learned during training (if anomalous
        % validation data is used)
        staticThresholds; % Struct

        % Determines wether model has been trained and is ready for
        % tetsting
        isTrained; % Bool

        % Determines input dimension model was trained on (Avoids errors
        % later on)
        trainedDimensionality; % Int

        % Training anomaly scores, possibly required for scoring functions,
        % threshold calculation, etc.
        trainingAnomalyScoresRaw; % Nxd double array
        trainingAnomalyScoreFeatures; % Struct
        trainingLabels; % Nx1 logical array
    end
    
    %% Public methods which can be called outside of the class
    methods (Access = public)
        function obj = TSADModel(parameters, instanceInfo)
            %TSADMODEL Construct an instance of this class

            % If provided, assign parameters
            obj.parameters = parameters;
            
            % Assign instance info
            obj.instanceInfo = instanceInfo;

            % For unsupervised models, set isTrained to True to enable
            % testing right away (no training step needed)
            if strcmp(obj.parameters.learningType, "unsupervised")
                obj.isTrained = true;
            else
                obj.isTrained = false;
            end
        end
    
        function obj = trainingWrapper(obj, dataTrain, labelsTrain, dataTestVal, labelsTestVal, plots, verbose)
            %TRAININGWRAPPER Main wrapper function for model training
            
            % Check learning type and fit if "semi_supervised" or
            % "supervised"
            if ~strcmp(obj.parameters.learningType, "unsupervised")
                    if isempty(dataTrain)
                        error("The %s model requires prior training, but the dataset doesn't contain training data (fit folder).", obj.instanceInfo.label);
                    end
                    
                    % Save dimensionality of data
                    obj.trainedDimensionality = size(dataTrain{1}, 2);
                    
                    % fit model
                    [XTrain, YTrain, XVal, YVal] = obj.dataTrainPreparationWrapper(dataTrain, labelsTrain);
                    if strcmp(obj.parameters.dimensionality, "multivariate")
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
                    if strcmp(obj.parameters.outputType, "anomaly_scores")
                        [obj.trainingAnomalyScoreFeatures, obj.trainingLabels] = obj.computeAnomalyScoreFeatures(dataTrain, labelsTrain);
                        
                        % Compute thresholds for semi-supervised models
                        if strcmp(obj.parameters.learningType, "semi_supervised")
                            obj.staticThresholds = obj.computeStaticThresholds(dataTestVal, labelsTestVal);
                        end
                    end
            end
            
            % Training finished
            obj.isTrained = true;
        end

        function obj = optimizationWrapper(obj, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, metric, threshold, dynamicThresholdSettings, iterations, trainingPlots, parallelEnabled)
            %OPTIMIZATIONWRAPPER Runs the auto optimization using bayesian
            %optimization
            
            optVars = obj.loadOptimizationVariables();

            if isempty(fieldnames(optVars))
                % Nothing to optimize, just train
                warning("No optimizable parameters found. Maybe check TSADConfig_optimization.json");
            else
                % Optimization
                results = obj.optimize(optVars, dataTrain, labelsTrain, ...
                                       dataValTest, labelsValTest, ...
                                       dataTest, labelsTest, threshold, ...
                                       dynamicThresholdSettings, ...
                                       metric, iterations, trainingPlots, ...
                                       parallelEnabled);
            
                optimumVars = results.XAtMinObjective;
                
                if isempty(optimumVars)
                    warning("No optimal parameters found.");
                else
                    obj.updateParameters(optimumVars);
                end
            end
            
            % Train model with optimal parameters
            obj.trainingWrapper(dataTrain, labelsTrain, dataValTest, ...
                                labelsValTest, trainingPlots, true);
        end
        
        function [anomalyScores, timeSeriesTest, labelsTest, computationTime] = detectionWrapper(obj, data, labels, getComputationTime, applyScoringFunction)
            %DETECTIONWRAPPER Main detection wrapper function
            
            if ~exist("getComputationTime", "var")
                getComputationTime = false; % Don't get computation time by default
            end
            if ~exist("applyScoringFunction", "var")
                applyScoringFunction = true; % Apply scoring function by default
            end

            % Prepare data
            [XTest, timeSeriesTest, labelsTest] = obj.dataTestPreparationWrapper(data, labels);
            
            % Handle detection
            if strcmp(obj.parameters.dimensionality, "multivariate")
                % For multivariate models
                
                if ~isempty(obj.Mdl)
                    Mdl_tmp = obj.Mdl{1};
                else
                    Mdl_tmp = [];
                end
            
                [anomalyScores, computationTime] = obj.predict(Mdl_tmp, XTest{1}, timeSeriesTest{1}, labelsTest, getComputationTime);
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
                    
                    [anomalyScores_tmp, compTime_tmp] = obj.predict(Mdl_tmp, XTest{channel_idx}, timeSeriesTest{channel_idx}, labelsTest, getComputationTime);
                    anomalyScores = [anomalyScores, anomalyScores_tmp];
                    compTimes = [compTimes, compTime_tmp];
                end
                
                computationTime = sum(compTimes);
            end

            
            % Bypass scoring function for models which output binary
            % classification instead of anomaly scores
            if ~strcmp(obj.parameters.outputType, "anomaly_scores")
                anomalyScores = any(anomalyScores, 2);
                return;
            end
            
            % Apply optional scoring function
            if applyScoringFunction
                anomalyScores = obj.applyScoringFunction(anomalyScores);
            end
        end

        function [predictedLabels, threshold] = applyThreshold(obj, anomalyScores, labels, thresholdName, dynamicThresholdSettings, storedThresholdValue)
            %APPLYTHRESHOLD Transform anomaly scores to binary labels by
            %applying a threshold
            
            % Retrun immediately if model already outputs labels
            if ~strcmp(obj.parameters.outputType, "anomaly_scores")
                predictedLabels = anomalyScores;
                threshold = NaN;
                return;
            end
            
            % The threshold gets selected as follows:
            % If (storedThresholdsValue is passed and is not empty): its value is used as the threshold.
            % Else if (thresholdName is found obj.staticThresholds): use learned threshold stored in this model.
            % Else compute threshold according to selected thresholdName

            % Check if stored threshold is passed
            if ~exist("storedThresholdValue", "var")
                storedThresholdValue = [];
            end

            % Apply stored threshold
            if ~isempty(storedThresholdValue)
                threshold = storedThresholdValue;

                % Apply threshold. the outer any(..., 2) is used to merge
                % multi-channel anomaly scores
                predictedLabels = any(anomalyScores > threshold, 2);
                return;
            end
            
            % Apply learned threshold
            if isfield(obj.staticThresholds, thresholdName)
                threshold = obj.staticThresholds.(thresholdName);
                
                % Apply threshold. the outer any(..., 2) is used to merge
                % multi-channel anomaly scores
                predictedLabels = any(anomalyScores > threshold, 2);
                return;
            end
            
            % Compute new threshold

            % Dynamic threshold
            if strcmp(thresholdName, "dynamic")
                % TODO: move this outside        
                padding = dynamicThresholdSettings.anomalyPadding;
                windowSize = max(1, floor(length(anomalyScores) * (dynamicThresholdSettings.windowSize / 100)));
                min_percent = dynamicThresholdSettings.minPercent;
                z_range = 1:dynamicThresholdSettings.zRange;
                
                [anom_times, threshold] = applyDynamicThreshold(anomalyScores, "anomaly_padding", padding, ...
                    "window_size", windowSize, "min_percent", min_percent, "z_range", z_range);
                
                predictedLabels = false(length(labels), 1);
                for i = 1:size(anom_times, 1)
                    begIdx = anom_times(i, 1);
                    endIdx = anom_times(i, 2);
                    if endIdx > length(predictedLabels)
                        endIdx = length(predictedLabels);
                    end
                    if isnan(begIdx) || isnan(endIdx) || (begIdx > endIdx)
                        return;
                    end
                    predictedLabels(begIdx:endIdx, 1) = 1;
                end
                
                return;
            end

            % Other static thresholds
            threshold = computeStaticThreshold(anomalyScores, labels, thresholdName, obj.parameters.name);
            
            % Apply threshold. the outer any(..., 2) is used to merge
            % multi-channel anomaly scores
            predictedLabels = any(anomalyScores > threshold, 2);
            return;
        end
        
        function obj = updateParameters(obj, newParameters)
            %UPDATEPARAMETERS Converts the parameters provided by
            %the newParameters table (used for optimization only)
            
            newParameterNames = newParameters.Properties.VariableNames;
            for i = 1:numel(newParameterNames)
                if isfield(obj.parameters, newParameterNames{i})
                    if iscategorical(newParameters{1, i})
                        if isnumeric(obj.parameters.(newParameterNames{i}))
                            newValue = double(string(newParameters{1, i}(1)));
                        else
                            newValue = string(newParameters{1, i}(1));
                        end
                    else
                        newValue = newParameters{1, i};
                    end
            
                    obj.parameters.(newParameterNames{i}) = newValue;
                    continue;
                else
                    warning("Your trying to optimize a parameter which is not defined in the parameters struct of your model");
                end
            end
        end

        function obj = setParameters(obj, parameters)
            %SETPARAMETERS Sets the parameters of the model

            obj.parameters = parameters;
        end
    
        function parameters = getParameters(obj)
            %GETPARAMETERS Returns the parameters of the model

            parameters = obj.parameters;
        end

        function layers = getNeuralNetworkLayers(obj)
            %GETNEURALNETWORKLAYERS If the model is a neural network, it
            %will return the layers (if getLayers function is implemented
            %in subclass)

            dummyXTrain = cell(1, 1);
            dummyXTrain{1} = 1;

            dummyYTrain = cell(1, 1);
            dummyYTrain{1} = 1;

            layers = obj.getLayers(dummyXTrain, dummyYTrain);
        end
    end

    %% Private methods. Only called from within the class
    methods (Access = private)
        function [XTrain, YTrain, XVal, YVal] = dataTrainPreparationWrapper(obj, data, labels)
            %DATATRAINPREPARATIONWRAPPER Main wrapper function for training
            %data preparation

            if strcmp(obj.parameters.dimensionality, "multivariate")
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
        
        function [XTest, timeSeriesTest, labelsTest] = dataTestPreparationWrapper(obj, data, labels)
            %DATATESTPREPARATIONWRAPPER Main wrapper function for testing
            %data preparation
            
            if strcmp(obj.parameters.dimensionality, "multivariate")
                % Prepare data for multivariate model

                [XTest, timeSeriesTest, labelsTest] = obj.prepareDataTest(data, labels);
                XTest = {XTest};
                timeSeriesTest = {timeSeriesTest};
            else
                % Prepare data for univariate model (separte for every
                % channel)

                numChannels = size(data{1}, 2);
                XTest = cell(1, numChannels);
                timeSeriesTest = cell(1, numChannels);
            
                for channel_idx = 1:numChannels
                    % Get same channel from all files
                    data_tmp = cell(numel(data), 1);
                    for j = 1:numel(data)
                        data_tmp{j} = data{j}(:, channel_idx);
                    end
            
                    [XTest{channel_idx}, timeSeriesTest{channel_idx}, labelsTest] = obj.prepareDataTest(data_tmp, labels);
                end
            end
        end

        function staticThresholds = computeStaticThresholds(obj, data, labels)
            %COMPUTESTATICTHRESHOLDS Computes static thresholds using training-
            %and anomalous validation set anomaly scores
                        
            staticThresholds = [];
            
            if ~isempty(data)
                % Count anomalies
                numAnoms = 0;
            
                for file_idx = 1:numel(data)            
                    numAnoms = numAnoms + sum(labels{file_idx} == 1);
                end
            
                anomalyScoresMerged = [];
                labelsMerged = [];
                
                % Merge anomaly scores for all files in data
                for file_idx = 1:numel(data)
                    [anomalyScores_tmp, ~, labels_tmp, ~] = obj.detectionWrapper(data(file_idx), labels(file_idx), false, true);
                    anomalyScoresMerged = [anomalyScoresMerged; anomalyScores_tmp];
                    labelsMerged = [labelsMerged; labels_tmp];
                end
                
                % Compute all thresholds which are set using anomalous
                % validation data
                if numAnoms ~= 0
                    staticThresholds.best_pointwise_f1_score = computeStaticThreshold(anomalyScoresMerged, labelsMerged, "best_pointwise_f1_score", obj.parameters.name);
                    staticThresholds.best_eventwise_f1_score = computeStaticThreshold(anomalyScoresMerged, labelsMerged, "best_eventwise_f1_score", obj.parameters.name);
                    staticThresholds.best_pointadjusted_f1_score = computeStaticThreshold(anomalyScoresMerged, labelsMerged, "best_pointadjusted_f1_score", obj.parameters.name);
                    staticThresholds.best_composite_f1_score = computeStaticThreshold(anomalyScoresMerged, labelsMerged, "best_composite_f1_score", obj.parameters.name);
                else
                    warning("Warning! Anomalous validation set doesn't contain anomalies, possibly couldn't calculate some static thresholds.");
                end
                
                staticThresholds.topK = computeStaticThreshold(anomalyScoresMerged, labelsMerged, "top_k", obj.parameters.name);
            end
            
            % Get all thresholds which are set using anomaly scores for fit data
            if ~isempty(obj.trainingAnomalyScoresRaw)
                anomalyScoresTrain = obj.applyScoringFunction(obj.trainingAnomalyScoresRaw);
                
                staticThresholds.max_train = max(max(anomalyScoresTrain));
            end
            
            % Get all thresholds which don't require anomaly scores
            staticThresholds.custom = computeStaticThreshold([], [], "custom", obj.parameters.name);
        end
    
        function [anomalyScoreFeatures, labelsTrain] = computeAnomalyScoreFeatures(obj, data, labels)
            %COMPUTEANOMALYSCOREFEATURES Get the raw anomaly scores and their
            %statistical features
                        
            anomalyScoresTrain = [];
            labelsTrain = [];
            
            % Get anomaly scores for every file of training data
            for file_idx = 1:numel(data)                            
                % Get raw anomaly scores and store in one array
                [trainingAnomalyScores_tmp, ~, trainingLabels_tmp, ~] = obj.detectionWrapper(data, labels, false, false);
                anomalyScoresTrain = [anomalyScoresTrain; trainingAnomalyScores_tmp];
                
                % Store labels in one array
                labelsTrain = [labelsTrain; trainingLabels_tmp];
            end
    
            anomalyScoreFeatures.mu = mean(obj.trainingAnomalyScoresRaw, 1);
            anomalyScoreFeatures.covar = cov(obj.trainingAnomalyScoresRaw);
        end

        function anomalyScores = applyScoringFunction(obj, anomalyScores)
            %APPLYSCORINGFUNCTION Applys a scoring function to the anomaly scores
            
            if ~isfield(obj.parameters, "scoringFunction")
                return
            end

            switch obj.parameters.scoringFunction
                case "aggregated"
                    anomalyScores = aggregatedScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu);
                case "channelwise"
                    anomalyScores = channelwiseScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu);
                case "gauss"
                    anomalyScores = gaussianScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu, obj.trainingAnomalyScoreFeatures.covar);
                case "gauss_aggregated"
                    anomalyScores = aggregatedGaussianScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu, obj.trainingAnomalyScoreFeatures.covar);
                case "gauss_channelwise"
                    anomalyScores = channelwiseGaussianScoring(anomalyScores, obj.trainingAnomalyScoreFeatures.mu, obj.trainingAnomalyScoreFeatures.covar);
                case "ewma"
                    anomalyScores = EWMAScoring(anomalyScores, 0.3);
                otherwise
                    error("Undefined scoring function");
            end
        end
        
        function scores = detectAndEvaluate(obj, dataTest, labelsTest, threshold, dynamicThresholdSettings)
            %DETECTANDEVALUATE Runs the detection and returns the scores (not anomaly scores but performance metrics) for the model

            [anomalyScores, ~, labels, ~] = obj.detectionWrapper(dataTest, labelsTest, false, false);
            
            [predictedLabels, ~] = obj.applyThreshold(anomalyScores, labels, threshold, dynamicThresholdSettings);
            
            scores = computeMetrics(anomalyScores, predictedLabels, labels);
        end

        function scoresCell = fullTrainTestPipeline(obj, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, verbose)
            %FULLTRAINTESTPIPELINE Train and test this model and return scores
            
            scoresCell = cell(numel(dataTest), 1);
                        
            % Train model
            trainedModel = obj.trainingWrapper(dataTrain, ...
                                               labelsTrain, dataValTest, ...
                                               labelsValTest, trainingPlots, verbose);
            
            % Run detection for all test files
            for data_idx = 1:numel(dataTest)
                [anomalyScores, ~, labels, ~] = trainedModel.detectionWrapper(dataTest(data_idx), labelsTest(data_idx), false, false);
                [predictedLabels, ~] = trainedModel.applyThresholdToAnomalyScores(anomalyScores, labels, threshold, dynamicThresholdSettings);
                
                scores = computeMetrics(anomalyScores, predictedLabels, labels);

                scoresCell{data_idx} = scores;
            end
        end

        function score = objectiveFunction(obj, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, metric, optVars, trainingPlots)
            %OBJECTIVE_FUNCTION Objective function for the bayesian optimization
            %   The objective function runs the training and testing pipeline and
            %   returns the specified metric (/score)
            
            convertedModel = obj.updateParameters(optVars);
            
            scoresCell = convertedModel.fullTrainTestPipeline(dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, trainingPlots, false);
            
            avgScores = calcAverageScores(scoresCell);
            
            % Get specified score
            [~, score_idx] = ismember(metric, METRIC_NAMES);
            avgScore = avgScores(score_idx);
            score = 1 - avgScore;
        end

        function results = optimize(obj, optVars, dataTrain, labelsTrain, dataValTest, labelsValTest, dataTest, labelsTest, threshold, dynamicThresholdSettings, metric, iterations, trainingPlots, parallelEnabled)
            %OPTIMIZE Runs the byesian optimization
            %   Sets the optVars, defines the opt_fun and calls the bayesopt function
            
            optVariables = [];
            optVarNames = fieldnames(optVars);
            for opt_idx = 1:numel(optVarNames)
                optVariables = [optVariables, ...
                                optimizableVariable(optVarNames{opt_idx}, ...
                                optVars.(optVarNames{opt_idx}).value, ...
                                "Type", optVars.(optVarNames{opt_idx}).type)];
            end
            
            fun = @(x)obj.objectiveFunction(dataTrain, ...
                                            labelsTrain, ...
                                            dataValTest, ...
                                            labelsValTest, ...
                                            dataTest, ...
                                            labelsTest, ...
                                            threshold, ...
                                            dynamicThresholdSettings, ...
                                            metric, ...
                                            x, ...
                                            trainingPlots);
            
            results = bayesopt(fun, optVariables, Verbose=0,...
                                AcquisitionFunctionName="expected-improvement-plus", ...
                                MaxObjectiveEvaluations=iterations, ...
                                IsObjectiveDeterministic=false, UseParallel=parallelEnabled);
        end

        function optVars = loadOptimizationVariables(obj)
            %LOADOPTIMIZATIONVARIABLES Load the optimization variables from
            %the TSADConfig_optimization.json file
            
            % Convert model name to valid matlab struct fieldname
            className = obj.parameters.className;
            
            % Load parameter optimization configuration
            fid = fopen("TSADConfig_optimization.json");
            raw = fread(fid, inf);
            str = char(raw');
            fclose(fid);
            config = jsondecode(str);
            
            vars = fieldnames(config.(className));

            % Return empty struct if no optimization config found
            if isempty(vars)
                optVars = struct();
                return;
            end
            
            % Load optimizable parameters
            for i = 1:numel(vars)
                optVars.(vars{i}).value = config.(modelName).(vars{i}).value;
                optVars.(vars{i}).type = config.(modelName).(vars{i}).type;
            end

            % Check for each optVar if it matches a parameter of this
            % model. Only parameters defined by this model can be
            % optimized.
            if ~isempty(fieldnames(optVars))
                varNames = fieldnames(optVars);
                for i = 1:numel(varNames)
                    flag = false;
                    if isfield(obj.parameters, varNames{i})
                        flag = true;
                    end
        
                    if ~flag
                        optVars = rmfield(optVars, varNames{i});
                    end
                end
            end
        end
    end

    %% Protected methods. Must be overwritten by subclass according to model
    methods (Access = protected)
        function [XTrain, YTrain, XVal, YVal] = prepareDataTrain(obj, data, labels)
            XTrain = [];
            YTrain = [];
            XVal = [];
            YVal = [];
        end

        function [XTest, timeSeriesTest, labelsTest] =  prepareDataTest(obj, data, labels)
            XTest = [];
            timeSeriesTest = [];
            labelsTest = [];
        end

        function Mdl = fit(obj, XTrain, YTrain, XVal, YVal, plots, verbose)
            Mdl = [];
        end

        function [anomalyScores, computationTime] = predict(obj, Mdl, XTest, timeSeriesTest, labelsTest, getComputationTime)
            anomalyScores = [];
            computationTime = NaN;
        end

        function layers = getLayers(obj, XTrain, YTrain)
            layers = [];
        end
    end
end

