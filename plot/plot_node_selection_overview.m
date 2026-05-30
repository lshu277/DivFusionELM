function plot_node_selection_overview(candidateIndex, retainedIndex, initialWidth, candidateWidth, retainedWidth, conditionFull, conditionCandidate, conditionRetained)
%PLOT_NODE_SELECTION_OVERVIEW Plot retained node masks and condition numbers.

maskCandidate = zeros(1, initialWidth);
maskRetained = zeros(1, initialWidth);
maskCandidate(candidateIndex) = 1;
maskRetained(retainedIndex) = 1;

figure('Color', 'w', 'Name', 'Node selection overview');
tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
stem(1:initialWidth, maskCandidate, 'LineWidth', 1.0); hold on;
stem(1:initialWidth, maskRetained, 'LineWidth', 1.0); grid on;
xlabel('Original hidden node index');
ylabel('Selection status');
title(sprintf('Candidate pool width = %d, retained width = %d', candidateWidth, retainedWidth));
legend({'Candidate pool', 'Retained subset'}, 'Location', 'best');
ylim([-0.1, 1.2]);

nexttile;
plot(1:numel(candidateIndex), candidateIndex, 'o-', 'LineWidth', 1.0, 'MarkerSize', 4); hold on;
plot(1:numel(retainedIndex), retainedIndex, 's-', 'LineWidth', 1.0, 'MarkerSize', 4); grid on;
xlabel('Selection order');
ylabel('Original hidden node index');
title('Selected node index mapping');
legend({'Candidate pool', 'Retained subset'}, 'Location', 'best');

nexttile;
barValues = [conditionFull, conditionCandidate, conditionRetained];
bar(barValues, 'EdgeColor', 'none');
grid on; set(gca, 'YScale', 'log');
set(gca, 'XTick', 1:3, 'XTickLabel', {'Full', 'Candidate', 'Retained'});
ylabel('Condition number');
title('Condition number comparison');

end
