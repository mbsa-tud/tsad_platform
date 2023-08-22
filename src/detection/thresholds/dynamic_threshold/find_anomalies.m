function [anomalies, thresholdEnd] = find_anomalies(errors, varargin)
% Find sequences of error values that are anomalous.
% We first define the window of errors, that we want to analyze. We then find the anomalous
% sequences in that window and store the start/stop index pairs that correspond to each
% sequence, along with its score. Optionally, we can flip the error sequence around the mean
% and apply the same procedure, allowing us to find unusually low error sequences.
% We then move the window and repeat the procedure.
% Lastly, we combine overlapping or consecutive sequences.

index = 1:length(errors);
z_range_base = 1:10;
window_size_base = length(errors);
window_step_size_base = window_size_base;
min_percent_base = 0.1;
anomaly_padding_base = 50;
lower_threshold_base = false;
fixed_threshold_base = false;

p = inputParser;
addRequired(p,'errors');
addParameter(p,'z_range',z_range_base);
addParameter(p,'window_size',window_size_base);
addParameter(p,'window_step_size',window_step_size_base);
addParameter(p, 'min_percent', min_percent_base);
addParameter(p, 'anomaly_padding', anomaly_padding_base);
addParameter(p, 'lower_threshold', lower_threshold_base);
addParameter(p, 'fixed_thresh', fixed_threshold_base);
parse(p,errors,varargin{:});

z_range = p.Results.z_range;
window_size = p.Results.window_size;
window_step_size = p.Results.window_step_size;
if window_step_size > window_size
    window_step_size = window_size;
end
min_percent = p.Results.min_percent;
anomaly_padding = p.Results.anomaly_padding;
lower_threshold = p.Results.lower_threshold;
fixed_thresh = p.Results.fixed_thresh;


window_start = 1;
window_end = 0;
sequences = [];

thresholdEnd = [];

% while window_end < length(errors)
%     window_end = min(window_start + window_size-1, length(errors));        
%     window = errors(window_start:window_end);
%     [window_sequences, threshold] = find_window_sequences(window, z_range, anomaly_padding, min_percent, window_start, fixed_thresh);
%     sequences = [sequences; window_sequences];   
%     thresholdEnd = [thresholdEnd threshold];
%     if lower_threshold
%         %Flip errors sequence around mean        
%         meann = mean(window);
%         inverted_window = meann - (window - meann);
%         [inverted_window_sequences, threshold] = find_window_sequences(inverted_window, z_range,anomaly_padding, min_percent, window_start, fixed_thresh);
%         sequences = [sequences; inverted_window_sequences];
%     end
%     window_start = window_start + window_step_size;
% end
while window_start < length(errors)-round(0.05*length(errors))
    window_end = min(window_start + window_size-1, length(errors));        
    window = errors(window_start:window_end);
    [window_sequences, threshold] = find_window_sequences(window, z_range, anomaly_padding, min_percent, window_start, fixed_thresh);
    sequences = [sequences; window_sequences];   
    thresholdEnd = [thresholdEnd threshold];
    if lower_threshold
        %Flip errors sequence around mean        
        meann = mean(window);
        inverted_window = meann - (window - meann);
        [inverted_window_sequences, threshold] = find_window_sequences(inverted_window, z_range,anomaly_padding, min_percent, window_start, fixed_thresh);
        sequences = [sequences; inverted_window_sequences];
    end
    window_start = window_start + window_step_size;
end
sequences = merge_sequences(sequences);

anomalies = [];
for i = 1:size(sequences,1) 
    seq = [sequences(i,1) sequences(i,2) sequences(i,3)];
    anomalies(i,:) = seq;    
end


end