thresholds = ["a", "b", "dynamic"];

[r, idx] = ismember("dynamic", thresholds);
thresholds(idx) = [];