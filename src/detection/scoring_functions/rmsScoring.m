function anomalyScores = rmsScoring(anomalyScores)
%RMSSCORING Computes the rms across the channels (2nd dimension) of the
%anomaly scores. If the scores only have one channel, it does nothing.

if (size(anomalyScores, 2) > 1)
    anomalyScores = rms(anomalyScores, 2);
end
end

