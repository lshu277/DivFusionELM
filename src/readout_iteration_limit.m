function maxIterations = readout_iteration_limit(H, readoutCfg)
%READOUT_ITERATION_LIMIT Determine the maximum number of Krylov iterations.

baseSize = min(size(H));
maxIterations = max(readoutCfg.minIterations, ceil(readoutCfg.maxIterationRatio * baseSize));
maxIterations = min(maxIterations, readoutCfg.maxIterations);
maxIterations = max(1, maxIterations);

end
