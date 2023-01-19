function augmentedData = shiftData(data, intensity)
    augmentedData = cell(size(data));
    for i = 1:numel(data)
        fileData = data{i};
        shift = intensity * (randn(1) -0.5);
        augmentedData{i} = fileData + shift;
    end
end
