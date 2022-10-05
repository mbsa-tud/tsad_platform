function Y = convertYForTesting(Y, type)
%CONVERTYFORTESTING
% Convert Y to enable calculation of anomaly Scores, this is needed for the
% validation data for DL models


if strcmp(type, 'Reconstructive')
    for i = 1:length(Y)
        if iscell(Y{1, i})
            Y{1, i} = cell2mat(Y{1, i});
            Y{1, i} = Y{1, i}(:, end);
        else
            Y{1, i} = Y{1, i}(:, end);
        end
    end
else
    for i = 1:length(Y)
        if iscell(Y{1, i})
            Y{1, i} = cell2mat(Y{1, i});
        end
    end
end
end