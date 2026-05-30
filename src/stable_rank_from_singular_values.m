function stableRank = stable_rank_from_singular_values(singularValues)
%STABLE_RANK_FROM_SINGULAR_VALUES Compute stable rank from singular values.

if isempty(singularValues) || singularValues(1) <= eps
    stableRank = 0;
else
    stableRank = sum(singularValues.^2) / max(singularValues(1)^2, eps);
end

end
