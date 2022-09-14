function [Mdls, MdlInfos] = trainDNN(options, XTrain, YTrain, XVal, YVal, plots)
switch options.model
    case 'Your model'
    otherwise
        numChannels = size(XTrain, 2);

        if numChannels == 1
            % Train single model
            XTrain_c = XTrain{1};
            YTrain_c = YTrain{1};
            XVal_c = XVal{1};
            YVal_c = YVal{1};

            if options.dataType == 1
                numResponses = size(YTrain_c, 2);
            else
                if strcmp(options.modelType, 'Reconstructive')
                    numResponses = size(YTrain_c{1, 1}, 1);
                else
                    numResponses = 1;
                end
            end
        
            if options.dataType == 1
                numFeatures = size(XTrain_c, 2);
            else
                numFeatures = size(XTrain_c{1, 1}, 1);
            end

            layers = getLayers(options, numFeatures, numResponses);
            trainOptions = getOptions(options, XVal_c, YVal_c, size(XTrain_c, 1), plots);
            
            [Mdls, MdlInfos] = trainNetwork(XTrain_c, YTrain_c, layers, trainOptions);
        else
            % Train the same model for each channel seperately
            % but parrallel
            trainParallel = true;
            
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
    
                    if options.dataType == 1
                        numResponses = size(YTrain_c, 2);
                    else
                        if strcmp(options.modelType, 'Reconstructive')
                            numResponses = size(YTrain_c{1, 1}, 1);
                        else
                            numResponses = 1;
                        end
                    end
                
                    if options.dataType == 1
                        numFeatures = size(XTrain_c, 2);
                    else
                        numFeatures = size(XTrain_c{1, 1}, 1);
                    end
        
                    layers = getLayers(options, numFeatures, numResponses);
                    trainOptions = getOptions(options, XVal_c, YVal_c, size(XTrain_c, 1), plots);
                    
                    [model_c, modelInfo_c] = trainNetwork(XTrain_c, YTrain_c, layers, trainOptions);
                    Mdls = [Mdls model_c];
                    MdlInfos = [MdlInfos modelInfo_c];
                end
            end
        end
end
end