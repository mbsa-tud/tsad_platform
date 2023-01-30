function augmentedData = addRandomWalk(rawData, maximum, minimum, level)
%ADDRANDOMWALK
%
% Add random walk noise to the data
level=level/10;
numChannels = size(rawData{1, 1}, 2);

for i = 1:size(rawData, 1)
    currentData = rawData{i, 1};
    for j = 1:numChannels
        % Generate random walk noise scaled by the amplitude of the signal
        noise = cumsum(randn(size(currentData, 1), 1) * level * (maximum(j) - minimum(j)));
        % Add noise to current channel
        currentData(:, j) = currentData(:, j) + noise;
    end
    rawData{i, 1} = currentData;
end

augmentedData = rawData;
end