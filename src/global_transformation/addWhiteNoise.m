function augmentedData = addWhiteNoise(data, maximum, minimum, level)
%WHITENOISE
%
% Adds white noise to the data using maximum and minimum parameters and a specified noise level

numChannels = size(data{1, 1}, 2);

for i = 1:size(data, 1)
newData = data{i, 1};
for j = 1:numChannels
% Génération de bruit blanc pour chaque canal
noise = (maximum(j) - minimum(j)) * level/100 * randn(size(newData(:, j)));
newData(:, j) = newData(:, j) + noise;
end
data{i, 1} = newData;
end

augmentedData = data;
end