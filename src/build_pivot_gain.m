function pivotGain = build_pivot_gain(triangularFactor, totalWidth)
%BUILD_PIVOT_GAIN Build the pivot increment sequence.

diagonalValues = abs(diag(triangularFactor));
pivotGain = zeros(1, totalWidth);
validLength = min(numel(diagonalValues), totalWidth);
pivotGain(1:validLength) = diagonalValues(1:validLength)';

if sum(pivotGain) <= eps
    pivotGain(1:validLength) = pivotGain(1:validLength) + eps;
end

end
