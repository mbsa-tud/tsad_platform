function [f, handles] = preparePlots(netLabels)
%PREPAREPLOTS
%
% Creates a figure to display training progress information.

numNets = length(netLabels);
colors = lines(numNets);
f = figure('Units', 'normalized', 'Position', [0.1 0.1 0.5 0.5]);
f.Visible = true;
subplot(2, 1, 1), ylabel('RMSE'), grid on;
subplot(2, 1, 2), ylabel('Loss'), xlabel('Iteration'), grid on;
for i=1:numNets
    subplot(2, 1, 1);
    handles.RMSELines(i) = animatedline('Color', colors(i, :), 'LineStyle', '-');
    handles.validationRMSELines(i) = animatedline('Color', colors(i, :), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 14);
    subplot(2, 1, 2)
    handles.lossLines(i) = animatedline('Color', colors(i, :), 'LineStyle', '-');
    handles.validationLossLines(i) = animatedline('Color', colors(i, :), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 14);
end
subplot(2, 1, 1), legend(handles.RMSELines, netLabels);
subplot(2, 1, 2), legend(handles.lossLines, netLabels);
end
