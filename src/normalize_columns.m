function Z = normalize_columns(H)
%NORMALIZE_COLUMNS Normalize each column to unit norm.

columnNorm = sqrt(sum(H.^2, 1)) + eps;
Z = H ./ columnNorm;

end
