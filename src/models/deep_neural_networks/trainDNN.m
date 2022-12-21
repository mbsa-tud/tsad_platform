function [Mdls, MdlInfos] = trainDNN(options, XTrain, YTrain, XVal, YVal, trainingPlots)
%TRAINDNN
%
% Train DL models

switch options.model
    case 'Your model'
    otherwise
        if ~options.isMultivariate
            numChannels = size(XTrain, 2);
    
            if numChannels == 1
                % Train single model
                XTrain_c = XTrain{1};
                YTrain_c = YTrain{1};
                XVal_c = XVal{1};
                YVal_c = YVal{1};
    
                [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain_c, YTrain_c, options.isMultivariate, options.modelType, options.dataType);
    
                layers = getLayers(options, numFeatures, numResponses);
                trainOptions = getOptions(options, XVal_c, YVal_c, size(XTrain_c, 1), trainingPlots);
                
                [Mdls, MdlInfos] = trainNetwork(XTrain_c, YTrain_c, layers, trainOptions);
            else
                % Train the same model for each channel seperately
                % if trainParallel is set to true, training is done in
                % parallel
                trainParallel = false;

                if trainParallel
                    models = [];
                    for i = 1:numChannels
                        modelInfo.options = options;
                        models = [models modelInfo];
                    end
                    [Mdls, MdlInfos] = trainDNN_Parallel(models, XTrain, YTrain, XVal, YVal, true);
                else
                    Mdls = [];
                    MdlInfos = [];
        
                    for i = 1:numChannels
                        XTrain_c = XTrain{i};
                        YTrain_c = YTrain{i};
                        XVal_c = XVal{i};
                        YVal_c = YVal{i};
        
                        [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain_c, YTrain_c, options.isMultivariate, options.modelType, options.dataType);
            
                        layers = getLayers(options, numFeatures, numResponses);
                        trainOptions = getOptions(options, XVal_c, YVal_c, size(XTrain_c, 1), trainingPlots);
                        
                        [model_c, modelInfo_c] = trainNetwork(XTrain_c, YTrain_c, layers, trainOptions);
                        Mdls = [Mdls model_c];
                        MdlInfos = [MdlInfos modelInfo_c];
                    end
                end
            end
        else
            XTrain = XTrain{1};
            YTrain = YTrain{1};
            XVal = XVal{1};
            YVal = YVal{1};
        
            [numFeatures, numResponses] = getNumFeaturesAndResponses(XTrain, YTrain, options.isMultivariate, options.modelType, options.dataType);

            layers = getLayers(options, numFeatures, numResponses);
            trainOptions = getOptions(options, XVal, YVal, size(XTrain, 1), trainingPlots);
            
            [Mdls, MdlInfos] = trainNetwork(XTrain, YTrain, layers, trainOptions);
        end
end
end