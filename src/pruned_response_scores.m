function [explainedRatio, relativeError, cosineSimilarity] = pruned_response_scores(H_pruned, H_reconstructed, residual)
%PRUNED_RESPONSE_SCORES Compute reconstruction quality scores for pruned responses.

numPruned = size(H_pruned, 2);
explainedRatio = zeros(1, numPruned);
relativeError = zeros(1, numPruned);
cosineSimilarity = zeros(1, numPruned);

for j = 1:numPruned
    originalVector = H_pruned(:, j);
    reconstructedVector = H_reconstructed(:, j);
    residualVector = residual(:, j);

    originalNorm = max(norm(originalVector), eps);
    reconstructedNorm = max(norm(reconstructedVector), eps);

    relativeError(j) = norm(residualVector) / originalNorm;
    explainedRatio(j) = 1 - (norm(residualVector)^2 / max(norm(originalVector)^2, eps));
    cosineSimilarity(j) = (originalVector' * reconstructedVector) / ...
        max(originalNorm * reconstructedNorm, eps);
end

end
