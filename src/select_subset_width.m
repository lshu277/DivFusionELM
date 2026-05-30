function finalWidth = select_subset_width(absoluteSlope, smoothedNovelty, candidateWidth, fullSubsetOrder, subsetCfg)
%SELECT_SUBSET_WIDTH Select the final subset width using a plateau criterion.

startIndex = max(ceil(subsetCfg.minCheckRatio * candidateWidth), subsetCfg.smoothWindow + 1);
patience = subsetCfg.patience;
finalWidth = [];

lastPossibleIndex = numel(absoluteSlope) - patience + 1;
for i = startIndex:lastPossibleIndex
    slopeSegment = absoluteSlope(i:i + patience - 1);
    noveltySegment = smoothedNovelty(i:i + patience - 1);

    isPlateau = all(slopeSegment <= subsetCfg.slopeThreshold);
    isLowNovelty = all(noveltySegment <= subsetCfg.noveltyFloor);

    if isPlateau && isLowNovelty
        finalWidth = i;
        break;
    end
end

if isempty(finalWidth)
    finalWidth = numel(fullSubsetOrder);
end

finalWidth = max(1, min(numel(fullSubsetOrder), finalWidth));

end
