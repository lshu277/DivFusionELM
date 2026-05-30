% Main script for DivFusionELM
clear; clc; close all;

%% Load dataset
% The variable "data" should contain [features, target].
% Samples are arranged in rows after transposition.
load data.mat
data = data';

X = data(:, 1:end-1);
y = data(:, end);

numSamples  = size(X, 1);
numFeatures = size(X, 2);

%% Parameter settings
numHiddenNodes = 100;
numFolds       = 5;
activationFunc = 'sig';
problemType    = 0;     % 0 = regression, 1 = classification
runID          = 0;     % keep plotting and diagnostic output quiet

rng(1);

%% Build K-fold indices without toolbox dependency
order = randperm(numSamples);
foldID = zeros(numSamples, 1);

for i = 1:numSamples
    foldID(order(i)) = mod(i - 1, numFolds) + 1;
end

%% Metric storage
% Test : RMSE, r, MAE, RPD, RPIQ, MaxRelErr, MinRelErr
% Train: RMSE, r, MAE, RPD, RPIQ, MaxRelErr, MinRelErr
foldMetrics = zeros(numFolds, 14);
foldModels  = cell(numFolds, 1);

%% Cross validation
for fold = 1:numFolds
    fprintf('\n========== Fold %d / %d ==========\n', fold, numFolds);

    testMask  = (foldID == fold);
    trainMask = ~testMask;

    XTrain = X(trainMask, :);
    yTrain = y(trainMask, :);
    XTest  = X(testMask,  :);
    yTest  = y(testMask,  :);

    %% Normalization based only on training data
    [XTrainNorm, inputPS] = mapminmax(XTrain', -1, 1);
    XTrainNorm = XTrainNorm';

    XTestNorm = mapminmax('apply', XTest', inputPS)';

    [yTrainNorm, outputPS] = mapminmax(yTrain', -1, 1);
    yTrainNorm = yTrainNorm';

    %% Train DivFusionELM
    evalc('[IW, B, LW, TF, TYPE] = elmtrain_Div(XTrainNorm, yTrainNorm, numHiddenNodes, activationFunc, problemType, runID);');

    %% Prediction in normalized space
    yTestNormPred  = elmpredict_Div(XTestNorm,  IW, B, LW, TF, TYPE);
    yTrainNormPred = elmpredict_Div(XTrainNorm, IW, B, LW, TF, TYPE);

    %% Reverse normalization
    yTestPred  = mapminmax('reverse', yTestNormPred',  outputPS)';
    yTrainPred = mapminmax('reverse', yTrainNormPred', outputPS)';

    %% Evaluation
    testScores  = evaluate_metrics(yTest,  yTestPred);
    trainScores = evaluate_metrics(yTrain, yTrainPred);

    foldMetrics(fold, :) = [
        testScores.RMSE,  testScores.r,  testScores.MAE,  testScores.RPD,  testScores.RPIQ,  testScores.MaxRelErr,  testScores.MinRelErr, ...
        trainScores.RMSE, trainScores.r, trainScores.MAE, trainScores.RPD, trainScores.RPIQ, trainScores.MaxRelErr, trainScores.MinRelErr
    ];

    %% Save current fold model
    currentModel = struct();
    currentModel.IW = IW;
    currentModel.B = B;
    currentModel.LW = LW;
    currentModel.TF = TF;
    currentModel.TYPE = TYPE;
    currentModel.inputPS = inputPS;
    currentModel.outputPS = outputPS;
    currentModel.fold = fold;

    foldModels{fold} = currentModel;

    fprintf('Test  RMSE = %.4f, r = %.4f\n', testScores.RMSE,  testScores.r);
    fprintf('Train RMSE = %.4f, r = %.4f\n', trainScores.RMSE, trainScores.r);
end

%% Mean results
meanMetrics = mean(foldMetrics, 1);

testRMSE = meanMetrics(1);
testR    = meanMetrics(2);
testMAE  = meanMetrics(3);
testRPD  = meanMetrics(4);
testRPIQ = meanMetrics(5);

trainRMSE = meanMetrics(8);
trainR    = meanMetrics(9);
trainMAE  = meanMetrics(10);
trainRPD  = meanMetrics(11);
trainRPIQ = meanMetrics(12);

fprintf('\n========== Mean Cross Validation Results ==========\n');
fprintf('Test : RMSE = %.4f, r = %.4f, MAE = %.4f, RPD = %.4f, RPIQ = %.4f\n', ...
    testRMSE, testR, testMAE, testRPD, testRPIQ);
fprintf('Train: RMSE = %.4f, r = %.4f, MAE = %.4f, RPD = %.4f, RPIQ = %.4f\n', ...
    trainRMSE, trainR, trainMAE, trainRPD, trainRPIQ);

%% Optional save
% save('DivFusionELM_cv_summary.mat', 'foldMetrics', 'meanMetrics', 'foldModels');
