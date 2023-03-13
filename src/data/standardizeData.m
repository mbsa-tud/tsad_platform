function standardizedData = standardizeData(data, mu, sigma)
%STANDARDIZEDATA
%
% Standardizes the data to have a mean of 0 and std of 1


numChannels = size(data{1, 1}, 2);

for j = 1:numChannels
    if sigma(j) == 0
        % If data is a flat line, set mean to 0
        for i = 1:size(data, 1)
            newData = data{i, 1}(:, j);
            newData = newData - mu(j);
            data{i, 1}(:, j) = newData;
        end
    else
        for i = 1:size(data, 1)
            newData = data{i, 1}(:, j);
            newData = (newData - mu(j)) / sigma(j);
            data{i, 1}(:, j) = newData;
        end
    end
end

standardizedData = data;
end