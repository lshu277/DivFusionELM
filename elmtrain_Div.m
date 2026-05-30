function [IW, B, LW, TF, TYPE, Info] = elmtrain_Div(P, T, N, TF, TYPE, cfg)
%ELMTRAIN_DIVFUSIONELM Train the DivFusionELM model.
%
%   [IW, B, LW, TF, TYPE, Info] = elmtrain_DivFusionELM(P, T, N, TF, TYPE, cfg)
%   trains a DivFusionELM model for regression or classification.
%
%   Inputs
%   ------
%   P    : Input matrix. Rows are samples and columns are features.
%   T    : Target matrix. Rows are samples.
%   N    : Initial hidden layer width.
%   TF   : Activation function, including 'sig', 'sin', or 'hardlim'.
%   TYPE : 0 for regression and 1 for classification.
%   cfg  : Optional configuration structure.
%
%   Outputs
%   -------
%   IW   : Input weights of the retained hidden nodes.
%   B    : Biases of the retained hidden nodes.
%   LW   : Output weights after pruned contribution reinjection and
%          reweighted fusion compensation.
%   TF   : Activation function name.
%   TYPE : Task type.
%   Info : Diagnostic information for model structure and readout solution.
%
%   The implementation follows the main components of DivFusionELM:
%   column pivot ordering, information volume based subset selection,
%   pruned contribution reinjection, reweighted fusion compensation, and
%   truncated Krylov stable readout.

%% Input settings
if nargin < 2
    error('DivFusionELM:InputError', 'Not enough input arguments.');
end
if nargin < 3 || isempty(N)
    N = size(P, 1);
end
if nargin < 4 || isempty(TF)
    TF = 'sig';
end
if nargin < 5 || isempty(TYPE)
    TYPE = 0;
end
defaultCfg = Div_elmtrain_default_config();
if nargin < 6 || isempty(cfg)
    cfg = defaultCfg;
else
    cfg = merge_structs(defaultCfg, cfg);
end

if ~isempty(cfg.randomSeed)
    rng(cfg.randomSeed);
end

if size(P, 1) ~= size(T, 1)
    error('DivFusionELM:InputError', 'P and T must have the same number of rows.');
end

[numSamples, numFeatures] = size(P);

%% Target encoding for classification
if TYPE == 1
    T = one_hot_encode_targets(T);
end

%% Random hidden layer construction
IW_full = rand(numFeatures, N) * 2 - 1;
B_full  = rand(1, N);
H_full  = hidden_layer_forward(P, IW_full, B_full, TF);

%% Column pivot ordering and gated candidate pool construction
[pivotOrder, triangularFactor] = column_pivot_order(H_full);
pivotGain   = build_pivot_gain(triangularFactor, N);
prefixQuota = build_prefix_quota(pivotGain);

quotaIndex = find(prefixQuota >= cfg.gate.quotaTarget, 1, 'first');
if isempty(quotaIndex)
    quotaIndex = N;
end

sampleLimitedWidth = max(cfg.gate.minKeep, floor(cfg.gate.sampleCap * numSamples));
candidateWidth = min([quotaIndex, sampleLimitedWidth, N]);
candidateWidth = max(cfg.gate.minKeep, candidateWidth);

candidateIndex = pivotOrder(1:candidateWidth);
H_candidate  = H_full(:, candidateIndex);
IW_candidate = IW_full(:, candidateIndex);
B_candidate  = B_full(:, candidateIndex);

%% Information volume based subset selection
normalizedCandidate = normalize_columns(H_candidate);
subsetKernel = normalizedCandidate' * normalizedCandidate + ...
    cfg.subset.kernelRegularization * eye(candidateWidth);

maxSubsetLength = min(candidateWidth, cfg.subset.maxSelect);
[fullSubsetOrder, marginalGain, cumulativeVolume] = ...
    greedy_information_volume_subset(subsetKernel, maxSubsetLength);

normalizedNovelty = exp(marginalGain) / (1 + cfg.subset.kernelRegularization);
smoothedNovelty   = moving_average(normalizedNovelty, cfg.subset.smoothWindow);
absoluteSlope     = [0, abs(diff(smoothedNovelty))];

finalWidth = select_subset_width(absoluteSlope, smoothedNovelty, ...
    candidateWidth, fullSubsetOrder, cfg.subset);

selectedLocalIndex = fullSubsetOrder(1:finalWidth);
prunedLocalIndex   = setdiff(1:candidateWidth, selectedLocalIndex, 'stable');

H_retained  = H_candidate(:, selectedLocalIndex);
H_pruned    = H_candidate(:, prunedLocalIndex);
IW_retained = IW_candidate(:, selectedLocalIndex);
B_retained  = B_candidate(:, selectedLocalIndex);

%% Reference readout over the candidate pool
[referenceReadout, referenceInfo] = solve_readout_krylov(H_candidate, T, cfg.readout);

retainedReference = referenceReadout(selectedLocalIndex, :);
prunedReference   = referenceReadout(prunedLocalIndex, :);

%% Direct readout on the retained subspace
[directReadout, retainedInfo] = solve_readout_krylov(H_retained, T, cfg.readout);

%% Pruned contribution reinjection and reweighted fusion compensation
if isempty(H_pruned)
    fusionMapping = zeros(size(H_retained, 2), 0);
    reweightingMatrix = zeros(0, 0);
    compensatedReadout = directReadout;
    explainedRatio = [];
    reconstructionError = [];
    cosineSimilarity = [];
    H_prunedReconstructed = zeros(size(H_retained, 1), 0);
    contributionReference = zeros(size(H_retained, 1), size(T, 2));
    contributionTransferred = zeros(size(H_retained, 1), size(T, 2));
else
    fusionMapping = (H_retained' * H_retained + ...
        cfg.fusion.regularization * eye(size(H_retained, 2))) \ (H_retained' * H_pruned);

    H_prunedReconstructed = H_retained * fusionMapping;
    reconstructionResidual = H_pruned - H_prunedReconstructed;

    [explainedRatio, reconstructionError, cosineSimilarity] = ...
        pruned_response_scores(H_pruned, H_prunedReconstructed, reconstructionResidual);

    fusionWeights = min(max(explainedRatio(:), 0), 1);
    reweightingMatrix = diag(fusionWeights);

    reinjectedReadout = retainedReference + fusionMapping * reweightingMatrix * prunedReference;
    compensatedReadout = (1 - cfg.fusion.reinjectionStrength) * directReadout + ...
        cfg.fusion.reinjectionStrength * reinjectedReadout;

    contributionReference = H_pruned * prunedReference;
    contributionTransferred = cfg.fusion.reinjectionStrength * ...
        (H_retained * (fusionMapping * reweightingMatrix * prunedReference));
end

%% Final output
IW = IW_retained;
B  = B_retained;
LW = compensatedReadout;

%% Diagnostics
singularFull = svd(H_full, 'econ');
singularCandidate = svd(H_candidate, 'econ');
singularRetained = svd(H_retained, 'econ');

Info = struct();
Info.initialWidth = N;
Info.candidateWidth = candidateWidth;
Info.retainedWidth = finalWidth;
Info.prunedWidth = candidateWidth - finalWidth;
Info.candidateIndex = candidateIndex;
Info.selectedLocalIndex = selectedLocalIndex;
Info.prunedLocalIndex = prunedLocalIndex;
Info.pivotGain = pivotGain;
Info.prefixQuota = prefixQuota;
Info.marginalGain = marginalGain;
Info.cumulativeVolume = cumulativeVolume;
Info.normalizedNovelty = normalizedNovelty;
Info.smoothedNovelty = smoothedNovelty;
Info.absoluteSlope = absoluteSlope;
Info.fusionMapping = fusionMapping;
Info.reweightingMatrix = reweightingMatrix;
Info.explainedRatio = explainedRatio;
Info.reconstructionError = reconstructionError;
Info.cosineSimilarity = cosineSimilarity;
Info.referenceReadout = referenceInfo;
Info.retainedReadout = retainedInfo;
Info.condition.full = safe_condition_number(H_full);
Info.condition.candidate = safe_condition_number(H_candidate);
Info.condition.retained = safe_condition_number(H_retained);
Info.singularValues.full = singularFull;
Info.singularValues.candidate = singularCandidate;
Info.singularValues.retained = singularRetained;
Info.stableRank.full = stable_rank_from_singular_values(singularFull);
Info.stableRank.candidate = stable_rank_from_singular_values(singularCandidate);
Info.stableRank.retained = stable_rank_from_singular_values(singularRetained);
Info.H.full = H_full;
Info.H.candidate = H_candidate;
Info.H.retained = H_retained;
Info.H.pruned = H_pruned;
Info.H.prunedReconstructed = H_prunedReconstructed;
Info.contribution.reference = contributionReference;
Info.contribution.transferred = contributionTransferred;

%% Optional diagnostic plots
if cfg.plot.enable
    if cfg.plot.columnPivotOverview
        plot_column_pivot_overview(pivotGain, prefixQuota, cfg.gate.quotaTarget, candidateWidth);
    end
    if cfg.plot.subsetSelectionOverview
        plot_subset_selection_overview(marginalGain, normalizedNovelty, smoothedNovelty, ...
            absoluteSlope, cumulativeVolume, cfg.subset, finalWidth, candidateWidth);
    end
    if cfg.plot.nodeSelectionOverview
        plot_node_selection_overview(candidateIndex, candidateIndex(selectedLocalIndex), ...
            N, candidateWidth, finalWidth, Info.condition.full, Info.condition.candidate, Info.condition.retained);
    end
    if cfg.plot.similarityMatrices
        plot_similarity_matrices(normalizedCandidate' * normalizedCandidate, ...
            normalize_columns(H_retained)' * normalize_columns(H_retained), candidateWidth, finalWidth);
    end
    if cfg.plot.singularSpectrum
        plot_singular_spectrum(singularFull, singularCandidate, singularRetained);
    end
    if cfg.plot.fusionCompensation
        plot_fusion_compensation(explainedRatio, reconstructionError, cosineSimilarity, H_pruned, H_prunedReconstructed);
    end
    if cfg.plot.krylovReadoutOverview
        plot_krylov_readout_overview(referenceInfo, retainedInfo, candidateWidth, finalWidth);
    end
end

end
