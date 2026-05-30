function plot_fusion_compensation(explainedRatio, reconstructionError, cosineSimilarity, H_pruned, H_reconstructed)
%PLOT_FUSION_COMPENSATION Plot pruned contribution reinjection diagnostics.

figure('Color', 'w', 'Name', 'Fusion compensation diagnostics');

if isempty(explainedRatio)
    text(0.5, 0.5, 'No pruned node exists. Fusion compensation is not activated.', ...
        'HorizontalAlignment', 'center', 'FontSize', 12);
    axis off;
    return;
end

tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nodeRank = 1:numel(explainedRatio);

nexttile;
plot(nodeRank, sort(explainedRatio, 'descend'), '-o', 'LineWidth', 1.1, 'MarkerSize', 4);
grid on; xlabel('Pruned node rank index'); ylabel('Explainability score');
title('Single node explainability');

nexttile;
plot(nodeRank, sort(reconstructionError, 'ascend'), '-s', 'LineWidth', 1.1, 'MarkerSize', 4);
grid on; xlabel('Pruned node rank index'); ylabel('Relative reconstruction error');
title('Reconstruction error');

nexttile;
plot(nodeRank, sort(cosineSimilarity, 'descend'), '-^', 'LineWidth', 1.1, 'MarkerSize', 4);
grid on; xlabel('Pruned node rank index'); ylabel('Cosine similarity');
title('Directional consistency');

nexttile;
barh([norm(H_pruned, 'fro'), norm(H_reconstructed, 'fro'), norm(H_pruned - H_reconstructed, 'fro')], 'EdgeColor', 'none');
grid on;
set(gca, 'YTick', 1:3, 'YTickLabel', {'Original', 'Reconstructed', 'Residual'});
xlabel('Frobenius norm');
title('Energy fidelity of pruned responses');

end
