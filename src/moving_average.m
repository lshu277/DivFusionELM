function smoothed = moving_average(x, windowLength)
%MOVING_AVERAGE Compute a causal moving average.

sequenceLength = numel(x);
smoothed = zeros(size(x));

for i = 1:sequenceLength
    firstIndex = max(1, i - windowLength + 1);
    smoothed(i) = mean(x(firstIndex:i));
end

end
