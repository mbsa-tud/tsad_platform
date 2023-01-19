function augmentedData = addRandomWalk(data, intensity)
    augmentedData = cell(size(data));
    for i = 1:numel(data)
        fileData = data{i};
        randomWalk = intensity * cumsum(randn(size(fileData)));
        augmentedData{i} = fileData + randomWalk;
    end
end
