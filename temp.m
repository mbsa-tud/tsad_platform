file = "C:\Ich\Studium\Bachelorarbeit\Inhalt\Git\tsad_platform\datasets\OtherDatasets\Univariate\AVS/AVS_highway_all\test\noise_12.csv";
file1 = "C:\Ich\Studium\Bachelorarbeit\Inhalt\Git\tsad_platform\datasets\OtherDatasets\Univariate\AVS/AVS_highway_all\test\offset_12.csv";
file2 = "C:\Ich\Studium\Bachelorarbeit\Inhalt\Git\tsad_platform\datasets\OtherDatasets\Univariate\AVS/AVS_highway_all\test\stuck_69.csv";


f = figure(Position=[0 0 900 400]);
subplot(3,1,1);
data = readtable(file);
testingData = data{:, 2:(end - 1)};
labels = data{:, end};
plot(testingData, LineWidth=1);
% ylabel("Value", Rotation=0, HorizontalAlignment="right");
% xlabel("Timestamp");
set(gca, ytick=[]);
set(gca, "XTick", [], "XTickLabel", []);
xlim([0 800]);
ylim([min(testingData) max(testingData)]);
trueIndices = getIndexes(labels);
trueLims=zeros(4, size(trueIndices, 2));
YLims = [min(testingData) max(testingData)];
for i = 1:size(trueIndices, 2)
    trueLims(1,i) = YLims(1);
    trueLims(2, i) = YLims(1);
    trueLims(3, i) = YLims(2);
    trueLims(4, i) = YLims(2);
end


if ~isempty(trueIndices) && ~isempty(trueLims)
    patch(trueIndices, trueLims, 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
end
legend("Data", "Anomaly");


subplot(3,1,2);
data = readtable(file1);
testingData = data{:, 2:(end - 1)};
labels = data{:, end};
plot(testingData, LineWidth=1);
% ylabel("Value", Rotation=0, HorizontalAlignment="right");
% xlabel("Timestamp");
set(gca, ytick=[]);
set(gca, "XTick", [], "XTickLabel", []);
xlim([0 800]);
ylim([min(testingData) max(testingData)]);
trueIndices = getIndexes(labels);
trueLims=zeros(4, size(trueIndices, 2));
YLims = [min(testingData) max(testingData)];
for i = 1:size(trueIndices, 2)
    trueLims(1,i) = YLims(1);
    trueLims(2, i) = YLims(1);
    trueLims(3, i) = YLims(2);
    trueLims(4, i) = YLims(2);
end


if ~isempty(trueIndices) && ~isempty(trueLims)
    patch(trueIndices, trueLims, 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
end
legend("Data", "Anomaly");


subplot(3,1,3);
data = readtable(file2);
testingData = data{:, 2:(end - 1)};
labels = data{:, end};
plot(testingData, LineWidth=1);
% ylabel("Value", Rotation=0, HorizontalAlignment="right");
xlabel("Timestamp");
set(gca, ytick=[]);
set(gca, "XTick", [], "XTickLabel", []);
xlim([0 800]);
ylim([min(testingData) max(testingData)]);
trueIndices = getIndexes(labels);
trueLims=zeros(4, size(trueIndices, 2));
YLims = [min(testingData) max(testingData)];
for i = 1:size(trueIndices, 2)
    trueLims(1,i) = YLims(1);
    trueLims(2, i) = YLims(1);
    trueLims(3, i) = YLims(2);
    trueLims(4, i) = YLims(2);
end


if ~isempty(trueIndices) && ~isempty(trueLims)
    patch(trueIndices, trueLims, 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
end
legend("Data", "Anomaly");