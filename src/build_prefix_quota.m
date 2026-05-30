function prefixQuota = build_prefix_quota(pivotGain)
%BUILD_PREFIX_QUOTA Compute the cumulative information quota.

totalGain = sum(pivotGain);
if totalGain <= eps
    prefixQuota = zeros(size(pivotGain));
else
    prefixQuota = cumsum(pivotGain) / totalGain;
end

end
