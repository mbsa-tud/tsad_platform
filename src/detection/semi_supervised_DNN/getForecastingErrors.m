function errors = getForecastingErrors(prediction, timeSeriesTest, dataType)
%GETFORECASTINGERRORS Computes errors for forecasting models

if (~ismember(dataType, ["CBT", "BC"]))
    error("invalid dataType, must be either CBT or BC");
end

% Convert cell predictions to normal array
if iscell(prediction)
    pred_tmp = zeros(numel(prediction), size(prediction{1}, 1));
    for i = 1:numel(prediction)
            pred_tmp(i, :) = prediction{i}';
    end
    prediction = pred_tmp;
end

errors = abs(prediction - timeSeriesTest);
end