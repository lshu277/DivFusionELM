function YPred = elmpredict_Div(X, IW, B, LW, TF, TYPE)
%ELMPREDICT_DIVFUIONELM Prediction function for DivFusionELM.
%
%   YPred = elmpredict_DivFuionELM(X, IW, B, LW, TF, TYPE)
%
%   Inputs:
%       X    - Input samples, rows as samples and columns as features
%       IW   - Input weight matrix of retained hidden nodes
%       B    - Bias vector of retained hidden nodes
%       LW   - Output layer weight matrix
%       TF   - Activation function: 'sig', 'sin', or 'hardlim'
%       TYPE - 0 for regression, 1 for classification
%
%   Output:
%       YPred - Predicted values for regression, or class labels for classification

    if nargin < 6
        error('elmpredict_DivFuionELM:InputError', ...
              'Six input arguments are required.');
    end

    if isempty(TF)
        TF = 'sig';
    end

    if isempty(TYPE)
        TYPE = 0;
    end

    numSamples = size(X, 1);

    % Construct hidden layer response matrix
    hiddenInput = X * IW + repmat(B, numSamples, 1);

    switch lower(TF)
        case 'sig'
            H = 1 ./ (1 + exp(-hiddenInput));

        case 'sin'
            H = sin(hiddenInput);

        case 'hardlim'
            H = double(hiddenInput >= 0);

        otherwise
            error('elmpredict_DivFuionELM:ActivationError', ...
                  'Unsupported activation function: %s', TF);
    end

    % Output response
    outputScore = H * LW;

    if TYPE == 1
        [~, YPred] = max(outputScore, [], 2);
    else
        YPred = outputScore;
    end
end