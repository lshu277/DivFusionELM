function plot_similarity_matrices(candidateSimilarity, retainedSimilarity, candidateWidth, retainedWidth)
%PLOT_SIMILARITY_MATRICES Plot similarity matrices before and after subset selection.

figure('Color', 'w', 'Name', 'Similarity matrices');
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
imagesc(candidateSimilarity); axis image; colorbar; caxis([-1, 1]);
xlabel('Candidate node index');
ylabel('Candidate node index');
title(sprintf('Candidate similarity matrix, width = %d', candidateWidth));

nexttile;
imagesc(retainedSimilarity); axis image; colorbar; caxis([-1, 1]);
xlabel('Retained node index');
ylabel('Retained node index');
title(sprintf('Retained similarity matrix, width = %d', retainedWidth));

end
