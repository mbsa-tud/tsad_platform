function Y = convertYForTesting(Y, type)
% CONVERTYFORTESTING % convert Y to enable calculation of anomaly Scores
%
% Description: This is only needed for calculating thresholds with the
%              Validation or Training dataset
%
% Input:  Y: Data to be converted
%         type: string - Possible values: Reconstructive, Predictive
%
% Output: Y: converted Y

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