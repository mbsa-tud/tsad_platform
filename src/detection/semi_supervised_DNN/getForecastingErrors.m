function errors = getForecastingErrors(prediction, TSTest, dataType)
%GETFORECASTINGERRORS Computes errors for forecasting models

% Convert cell predictions to normal array
if dataType ~= 1
    pred_tmp = zeros(numel(prediction), size(prediction{1}, 1));
    for i = 1:numel(prediction)
            pred_tmp(i, :) = prediction{i}';
    end
    prediction = pred_tmp;
end

errors = abs(prediction - TSTest);
end