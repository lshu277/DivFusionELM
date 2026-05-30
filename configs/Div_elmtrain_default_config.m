function CFG = Div_elmtrain_default_config()
%DIV_ELMTRAIN_DEFAULT_CONFIG Default configuration for DivFusionELM training.
%
%   CFG = Div_elmtrain_default_config() returns the default configuration
%   used by elmtrain_DivFusionELM.
%
%   The configuration includes parameters for:
%       1. Column pivot ordering and gated candidate construction
%       2. Information volume based subset selection
%       3. Pruned contribution reinjection and fusion compensation
%       4. Truncated Krylov stable readout
%       5. Optional diagnostic plotting
%
%   Output:
%       CFG - Configuration structure for DivFusionELM training

%% General settings
CFG.verbose = true;
CFG.randomSeed = [];

%% Column pivot ordering and gated candidate construction
CFG.gate.quotaTarget = 0.99;
CFG.gate.sampleCap   = 0.90;
CFG.gate.minKeep     = 1;

%% Information volume based subset selection
CFG.subset.kernelRegularization = 1e-6;
CFG.subset.smoothWindow         = 5;
CFG.subset.minCheckRatio        = 0.57;
CFG.subset.slopeThreshold       = 0.004;
CFG.subset.noveltyFloor         = 0.03;
CFG.subset.patience             = 4;
CFG.subset.maxSelect            = inf;

%% Pruned contribution reinjection and fusion compensation
CFG.fusion.regularization       = 1e-3;
CFG.fusion.reinjectionStrength  = 0.30;
CFG.fusion.weightMode           = 'explainability';

%% Truncated Krylov stable readout
CFG.readout.tolerance           = 1e-10;
CFG.readout.maxIterationRatio   = 0.80;
CFG.readout.minIterations       = 8;
CFG.readout.maxIterations       = 60;
CFG.readout.initialization      = 'zero';

%% Optional diagnostic plotting
CFG.plot.enable = false;
CFG.plot.columnPivotOverview     = true;
CFG.plot.subsetSelectionOverview = true;
CFG.plot.nodeSelectionOverview   = true;
CFG.plot.similarityMatrices      = true;
CFG.plot.singularSpectrum        = true;
CFG.plot.fusionCompensation      = true;
CFG.plot.krylovReadoutOverview   = true;

end
