function plot_column_pivot_overview(pivotGain, prefixQuota, quotaTarget, candidateWidth)
%PLOT_COLUMN_PIVOT_OVERVIEW Plot pivot gains and prefix information quota.

figure('Color', 'w', 'Name', 'Column pivot ordering overview');
tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
bar(pivotGain, 'EdgeColor', 'none');
hold on; grid on;
xline(candidateWidth, '--', sprintf('Candidate width = %d', candidateWidth), ...
    'LineWidth', 1.2, 'LabelOrientation', 'horizontal');
xlabel('Pivot order index');
ylabel('Pivot increment');
title('Column pivot increment sequence');

nexttile;
plot(1:numel(prefixQuota), prefixQuota, '-o', 'LineWidth', 1.2, 'MarkerSize', 4);
hold on; grid on;
yline(quotaTarget, '--', sprintf('Quota threshold = %.3f', quotaTarget), 'LineWidth', 1.2);
xline(candidateWidth, '--', sprintf('Candidate width = %d', candidateWidth), ...
    'LineWidth', 1.2, 'LabelOrientation', 'horizontal');
xlabel('Number of retained prefix pivots');
ylabel('Prefix information quota');
title('Prefix information quota curve');
ylim([0, 1.05]);

end
