function plot_krylov_readout_overview(candidateInfo, retainedInfo, candidateWidth, retainedWidth)
%PLOT_KRYLOV_READOUT_OVERVIEW Plot truncated Krylov readout diagnostics.

figure('Color', 'w', 'Name', 'Krylov readout overview');
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
bar([candidateInfo.meanIterations, retainedInfo.meanIterations], 'EdgeColor', 'none');
grid on;
set(gca, 'XTickLabel', {'Candidate pool', 'Retained subset'});
ylabel('Mean iteration count');
title('Readout iteration count');

nexttile;
bar([candidateInfo.meanRelativeResidual, retainedInfo.meanRelativeResidual], 'EdgeColor', 'none');
grid on; set(gca, 'YScale', 'log');
set(gca, 'XTickLabel', {'Candidate pool', 'Retained subset'});
ylabel('Mean relative residual');
title('Readout residual');

sgtitle(sprintf('Krylov readout diagnostics: candidate width = %d, retained width = %d', candidateWidth, retainedWidth));

end
