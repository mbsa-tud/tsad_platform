function threshold = fixed_threshold(errors)
%     Calculate the threshold.
%     The fixed threshold is defined as k standard deviations away from the mean.
    k = 4;    
    meann = mean(errors);
    stdd = std(errors);

    threshold = meann + k * stdd;
end

