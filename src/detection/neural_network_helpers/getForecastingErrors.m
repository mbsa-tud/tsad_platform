function errors = getForecastingErrors(prediction, timeSeriesTest)
%GETFORECASTINGERRORS Computes errors for forecasting models

errors = abs(prediction - timeSeriesTest);
end