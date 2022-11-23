function trainedModels_S = trainModels_S(models, dataTrain, dataValTest, labelsValTest, ratioValTest, thresholds)
%TRAINMODELS_S
%
% Trains all statistical models and calculates the thresholds

for i = 1:length(models)
    options = models(i).options;

    switch options.learningType
        case 'unsupervised'
            options.calcThresholdLast = true;
            Mdl = [];
            staticThreshold = [];
        case 'semisupervised'
            if ratioValTest == 1
                options.calcThresholdLast = true;
            else
                options.calcThresholdLast = false;
            end
    
            XTrain = prepareDataTrain_S(options, dataTrain);
            Mdl = trainCML(options, XTrain);
            if ~options.calcThresholdLast
                staticThreshold = getStaticThreshold_S(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds);
            else
                staticThreshold = [];
            end
        case 'supervised'
            if ratioValTest == 1
                options.calcThresholdLast = true;
            else
                options.calcThresholdLast = false;
            end
    
            % TODO: what if anomalous data in trian folder?
            XTrain = prepareDataTrain_S(options, dataValTest);
            Mdl = trainCML(options, XTrain);
            if ~options.calcThresholdLast
                staticThreshold = getStaticThreshold_S(options, Mdl, XTrain, dataValTest, labelsValTest, thresholds);
            else
                staticThreshold = [];
            end
    end

    trainedModel.staticThreshold = staticThreshold;
    trainedModel.options = options;
    trainedModel.Mdl = Mdl;    
    
    trainedModels_S.(models(i).options.id) = trainedModel;
end
end
