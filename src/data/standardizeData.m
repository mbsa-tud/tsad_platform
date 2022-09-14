function standardizedData = standardizeData(data, mu, sigma)
% STANDARDIZEDATA % standardize data
%
% Description: standardize data
%
% Input:  maximum: double - used for standardizing
%         minimum: double - used for standardizing
%
% Output: standardizedData: standardized data

numChannels = size(data{1, 1}, 2);

for j = 1:numChannels
    for i = 1:size(data, 1)
        newData = data{i, 1};
        newData(:, j) = (newData(:, j) - mu(j)) / sigma(j);
        data{i, 1} = newData;
    end
end

standardizedData = data;
end