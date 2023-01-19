function augmentedData = addWhiteNoise(data, intensity)
    augmentedData = cell(size(data));
    for i = 1:numel(data)
        fileData = data{i};
        noise = intensity * randn(size(fileData));
        augmentedData{i} = fileData + noise;
    end
end
