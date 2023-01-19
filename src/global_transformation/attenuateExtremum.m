function augmentedData = attenuateExtremum(data, intensity)
    augmentedData = cell(size(data));
    for i = 1:numel(data)
        fileData = data{i};
        meanValue = mean(fileData);
        fileData(fileData > meanValue) = fileData(fileData > meanValue) * intensity;
        fileData(fileData < meanValue) = fileData(fileData < meanValue) / intensity;
        augmentedData{i} = fileData;
    end
end
