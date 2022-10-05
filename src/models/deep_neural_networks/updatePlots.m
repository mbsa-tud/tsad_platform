function updatePlots(handles, data)
%UPDATEPLOTS
%
% Updates the plots in handles, created by PREPAREPLOTS, with
% training progress information.

info = data.info;
if info.State == "iteration"
    addpoints(handles.RMSELines(data.experimentNumber), info.Iteration, info.TrainingRMSE);
    if ~isempty(info.ValidationRMSE)
        addpoints(handles.validationRMSELines(data.experimentNumber), info.Iteration, info.ValidationRMSE);
    end
    addpoints(handles.lossLines(data.experimentNumber), info.Iteration, info.TrainingLoss);
    if ~isempty(info.ValidationLoss)
        addpoints(handles.validationLossLines(data.experimentNumber), info.Iteration, info.ValidationLoss);
    end
end
end
