function plot_subset_selection_overview(marginalGain, novelty, smoothedNovelty, absoluteSlope, cumulativeVolume, subsetCfg, finalWidth, candidateWidth)
%PLOT_SUBSET_SELECTION_OVERVIEW Plot information volume based subset selection diagnostics.

figure('Color', 'w', 'Name', 'Subset selection overview');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

startCheck = max(ceil(subsetCfg.minCheckRatio * candidateWidth), subsetCfg.smoothWindow + 1);

nexttile;
bar(marginalGain, 'EdgeColor', 'none');
hold on; grid on;
xline(finalWidth, '--', sprintf('Final width = %d', finalWidth), 'LineWidth', 1.2);
xlabel('Selection step');
ylabel('Marginal log volume gain');
title('Marginal information volume gain');

nexttile;
plot(novelty, '-o', 'LineWidth', 1.0, 'MarkerSize', 4); hold on;
plot(smoothedNovelty, '-s', 'LineWidth', 1.2, 'MarkerSize', 4); grid on;
yline(subsetCfg.noveltyFloor, '--', sprintf('Novelty floor = %.3f', subsetCfg.noveltyFloor));
xline(startCheck, ':', 'Start checking');
xline(finalWidth, '--', sprintf('Final width = %d', finalWidth));
xlabel('Selection step');
ylabel('Normalized novelty');
title('Novelty curve');
legend({'Raw novelty', 'Smoothed novelty'}, 'Location', 'best');

nexttile;
plot(absoluteSlope, '-^', 'LineWidth', 1.2, 'MarkerSize', 4); grid on; hold on;
yline(subsetCfg.slopeThreshold, '--', sprintf('Slope threshold = %.4f', subsetCfg.slopeThreshold));
xline(startCheck, ':', 'Start checking');
xline(finalWidth, '--', sprintf('Final width = %d', finalWidth));
xlabel('Selection step');
ylabel('Absolute slope');
title('Plateau detection');

nexttile;
plot(cumulativeVolume, '-d', 'LineWidth', 1.2, 'MarkerSize', 4); grid on; hold on;
xline(finalWidth, '--', sprintf('Final width = %d', finalWidth));
xlabel('Selection step');
ylabel('Cumulative log volume');
title('Cumulative information volume');

end
