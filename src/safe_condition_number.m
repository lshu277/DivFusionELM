function conditionNumber = safe_condition_number(H)
%SAFE_CONDITION_NUMBER Compute a stable condition number estimate.

singularValues = svd(H, 'econ');
if isempty(singularValues) || singularValues(1) <= eps
    conditionNumber = inf;
else
    conditionNumber = singularValues(1) / max(singularValues(end), eps);
end

end
