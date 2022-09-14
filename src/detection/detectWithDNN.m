function [anomalyScores, YTest, labels] = detectWithDNN(options, Mdl, XTest, YTest, labels)
switch options.model
    case 'Your model'
    otherwise
        anomalyScores = [];
        % Get anomaly scores for each channel
        for i = 1:length(Mdl)
            if iscell(Mdl)
                net_tmp = Mdl{i};
            else
                net_tmp = Mdl(i);
            end

            pred = predict(net_tmp, XTest{i});
            
            if strcmp(options.modelType, 'Reconstructive')
                pred = reshapeReconstructivePrediction(pred, options.hyperparameters.data.windowSize.value);
                YTest_tmp = YTest{i};
                YTest{i} = YTest_tmp(1:(end - options.hyperparameters.data.windowSize.value), 1);
            else
                if iscell(pred)
                    pred = cell2mat(pred);
                end
            end   

%             %% Plot prediction and ground truth
%             f = figure;
%             hold on
%             plot(YTest{i});
%             plot(pred);
%             xlabel('Timestamp', FontSize=14)
%             ylabel('Value', FontSize=14)
%             legend('Ground Truth', "Reconstruction", FontSize=14)
%             xlim([0, 1000])
%             hold off
%             %%
            
            anomalyScores(:, i) = abs(pred - YTest{i});
            if length(Mdl) > 1
                anomalyScores(:, i) = anomalyScores(:, i) - mean(anomalyScores(:, i));
            end
        end
        
        aggregateScores = false;
        if aggregateScores
            anomalyScores = rms(anomalyScores, 2);
        end

        % Crop labels for reconstructive models
        if strcmp(options.modelType, 'Reconstructive')
            labels = labels(1:(end - options.hyperparameters.data.windowSize.value), 1);
        end
        
        %% Plot labels
%         f = figure;
%         f.Position = [100 100 1000 200];
%         plot(labels);
%         %xlabel('Timestamp', FontSize=14);
%         ylim([-0.1 1.1]);
%         xlim([0 3300]);
%         set(gca, xtick=[]);
%         set(gca, ytick=[0 1]);
        %%
end
end
