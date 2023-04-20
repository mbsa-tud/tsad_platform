function features = diagnosticFeatures(inputData)
%DIAGNOSTICFEATURES Computes statistical features of time series data

features = [];

for channel_idx = 1:size(inputData, 2)
    % For every channel of the dataset compute the same features
    try
        data = inputData(:, channel_idx);

        % Compute signal features
        ClearanceFactor = max(abs(data))/(mean(sqrt(abs(data)))^2);
        CrestFactor = peak2rms(data);
        ImpulseFactor = max(abs(data))/mean(abs(data));
        Kurtosis = kurtosis(data);
        Mean = mean(data,"omitnan");
        PeakValue = max(abs(data));
        SINAD = sinad(data);
        SNR = snr(data);
        ShapeFactor = rms(data,"omitnan")/mean(abs(data),"omitnan");
        Skewness = skewness(data);
        Std = std(data,"omitnan");
    
        % Concatenate signal features.
        features = [features, ClearanceFactor, ...
                    CrestFactor, ...
                    ImpulseFactor,...
                    Kurtosis,...
                    Mean, ...
                    PeakValue, ...
                    SINAD,...
                    SNR,...
                    ShapeFactor,...
                    Skewness,...
                    Std];
    catch
        % Package computed features into a table.
        features = [features, NaN(1, 11)];
    end
end

features = array2table(features);
% features.Properties.VariableNames = ["ClearanceFactor", ...
%                                         "CrestFactor", ...
%                                         "ImpulseFactor", ...
%                                         "Kurtosis", ...
%                                         "Mean", ...
%                                         "PeakValue", ...
%                                         "SINAD", ...
%                                         "SNR", ...
%                                         "ShapeFactor", ...
%                                         "Skewness", ...
%                                         "Std"];
end
