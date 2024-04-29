function anomalyScores = EWMAScoring(anomalyScores, alpha, channelwise)
%EWMASCORING Applies the Exponetially Weighted Moving Average to the Root
%Mean Square of the raw channel-wise anomaly scores. The
%smoothing-factor alpha can be between 0 and 1 (Higher means LESS
%smoothing)

if ~exist("channelwise", "var")
    channelwise = false;
end

if channelwise
    for i = 1:size(anomalyScores, 2)
        anomalyScores(:, i) = EWMA(anomalyScores(:, i));
    end
else
    anomalyScores = rms(anomalyScores, 2);    
    anomalyScores = EWMA(anomalyScores, alpha);
end
end

function data = EWMA(data, alpha)
    for i = 2:size(data, 1)
        data(i) = alpha * data(i) + (1 - alpha) * data(i - 1);
    end
end

