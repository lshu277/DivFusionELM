function [selectedSet, marginalGain, cumulativeVolume] = greedy_information_volume_subset(kernelMatrix, maxSelect)
%GREEDY_INFORMATION_VOLUME_SUBSET Greedy MAP subset construction by log determinant gain.

numCandidates = size(kernelMatrix, 1);
maxSelect = min(maxSelect, numCandidates);

selectedSet = [];
remainingSet = 1:numCandidates;
marginalGain = zeros(1, maxSelect);
cumulativeVolume = zeros(1, maxSelect);
currentVolume = 0;

for step = 1:maxSelect
    bestGain = -inf;
    bestCandidate = [];
    bestVolume = currentVolume;

    for idx = 1:numel(remainingSet)
        candidate = remainingSet(idx);
        trialSet = [selectedSet, candidate]; %#ok<AGROW>
        trialVolume = logdet_positive_semidefinite(kernelMatrix(trialSet, trialSet));
        trialGain = trialVolume - currentVolume;

        if trialGain > bestGain
            bestGain = trialGain;
            bestCandidate = candidate;
            bestVolume = trialVolume;
        end
    end

    selectedSet = [selectedSet, bestCandidate]; %#ok<AGROW>
    remainingSet(remainingSet == bestCandidate) = [];
    marginalGain(step) = bestGain;
    cumulativeVolume(step) = bestVolume;
    currentVolume = bestVolume;

    if isempty(remainingSet)
        marginalGain = marginalGain(1:step);
        cumulativeVolume = cumulativeVolume(1:step);
        break;
    end
end

end
