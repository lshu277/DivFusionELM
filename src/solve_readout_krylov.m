function [readout, solverInfo] = solve_readout_krylov(H, T, readoutCfg)
%SOLVE_READOUT_KRYLOV Solve output weights with truncated Krylov iterations.

[numSamples, numHidden] = size(H);
numOutputs = size(T, 2);
maxIterations = readout_iteration_limit(H, readoutCfg);

readout = zeros(numHidden, numOutputs);
iterationEach = zeros(1, numOutputs);
relativeResidualEach = zeros(1, numOutputs);
flagEach = zeros(1, numOutputs);

for outputIndex = 1:numOutputs
    targetVector = T(:, outputIndex);
    [solutionVector, flag, relativeResidual, iterationCount] = ...
        lsqr(H, targetVector, readoutCfg.tolerance, maxIterations);

    readout(:, outputIndex) = solutionVector;
    flagEach(outputIndex) = flag;
    relativeResidualEach(outputIndex) = relativeResidual;
    iterationEach(outputIndex) = iterationCount;
end

solverInfo = struct();
solverInfo.numSamples = numSamples;
solverInfo.numHidden = numHidden;
solverInfo.maxIterations = maxIterations;
solverInfo.tolerance = readoutCfg.tolerance;
solverInfo.iterationEach = iterationEach;
solverInfo.relativeResidualEach = relativeResidualEach;
solverInfo.flagEach = flagEach;
solverInfo.meanIterations = mean(iterationEach);
solverInfo.meanRelativeResidual = mean(relativeResidualEach);

end
