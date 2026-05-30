function encodedTarget = one_hot_encode_targets(T)
%ONE_HOT_ENCODE_TARGETS Convert class labels to one-hot targets.

if isrow(T)
    labels = T(:);
else
    labels = T;
end

if size(labels, 2) > 1
    encodedTarget = labels;
    return;
end

classes = unique(labels(:))';
numSamples = numel(labels);
numClasses = numel(classes);
encodedTarget = zeros(numSamples, numClasses);

for i = 1:numClasses
    encodedTarget(labels == classes(i), i) = 1;
end

end
