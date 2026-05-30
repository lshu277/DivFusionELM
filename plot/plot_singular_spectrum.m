function plot_singular_spectrum(singularFull, singularCandidate, singularRetained)
%PLOT_SINGULAR_SPECTRUM Plot singular value spectra of hidden-layer matrices.

figure('Color', 'w', 'Name', 'Singular value spectrum');
semilogy(1:numel(singularFull), singularFull, '-o', 'LineWidth', 1.2, 'MarkerSize', 4, 'MarkerFaceColor', 'none');
hold on; grid on;
semilogy(1:numel(singularCandidate), singularCandidate, '-s', 'LineWidth', 1.2, 'MarkerSize', 4, 'MarkerFaceColor', 'none');
semilogy(1:numel(singularRetained), singularRetained, '-^', 'LineWidth', 1.2, 'MarkerSize', 4, 'MarkerFaceColor', 'none');
xlabel('Singular value index');
ylabel('Singular value');
title('Singular value spectrum comparison');
legend({'Full hidden layer', 'Candidate pool', 'Retained subset'}, 'Location', 'best');
box on;

end
