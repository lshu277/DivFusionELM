function scores = evaluate_metrics(yRef, yEst)
%evaluate_metrics Calculate common regression evaluation indices.
%
%   scores = evaluate_regression(yRef, yEst)
%
%   Inputs:
%       yRef - reference or measured values
%       yEst - predicted values
%
%   Outputs:
%       scores.RMSE      root mean square error
%       scores.MAE       mean absolute error
%       scores.r         Pearson correlation coefficient
%       scores.SD        standard deviation of reference values
%       scores.RPD       ratio of performance to deviation
%       scores.RPIQ      ratio of performance to interquartile distance
%       scores.MaxRelErr maximum relative error
%       scores.MinRelErr minimum relative error

    yRef = yRef(:);
    yEst = yEst(:);

    if numel(yRef) ~= numel(yEst)
        error('evaluate_regression:InputSizeMismatch', ...
              'The reference and predicted vectors must have the same length.');
    end

    if isempty(yRef)
        error('evaluate_regression:EmptyInput', ...
              'Input vectors must not be empty.');
    end

    residual = yEst - yRef;

    % Basic error metrics
    scores.RMSE = sqrt(mean(residual.^2));
    scores.MAE  = mean(abs(residual));

    % Pearson correlation coefficient without toolbox dependency
    refCentered = yRef - mean(yRef);
    estCentered = yEst - mean(yEst);
    corrDen = sqrt(sum(refCentered.^2) * sum(estCentered.^2));

    if corrDen <= eps
        scores.r = NaN;
    else
        scores.r = sum(refCentered .* estCentered) / corrDen;
    end

    % Reference dispersion
    scores.SD = sqrt(mean((yRef - mean(yRef)).^2));

    % RPD and RPIQ
    if scores.RMSE <= eps
        scores.RPD  = Inf;
        scores.RPIQ = Inf;
    else
        scores.RPD = scores.SD / scores.RMSE;

        q25 = local_percentile(yRef, 25);
        q75 = local_percentile(yRef, 75);
        scores.RPIQ = (q75 - q25) / scores.RMSE;
    end

    % Relative error range
    safeDen = yRef;
    safeDen(abs(safeDen) <= eps) = eps;

    relError = residual ./ safeDen;
    scores.MaxRelErr = max(relError);
    scores.MinRelErr = min(relError);
end


function q = local_percentile(x, p)
%LOCAL_PERCENTILE Percentile calculation without requiring Statistics Toolbox.

    x = sort(x(:));
    n = numel(x);

    if n == 1
        q = x;
        return;
    end

    pos = 1 + (n - 1) * p / 100;
    lowerIdx = floor(pos);
    upperIdx = ceil(pos);

    if lowerIdx == upperIdx
        q = x(lowerIdx);
    else
        weight = pos - lowerIdx;
        q = (1 - weight) * x(lowerIdx) + weight * x(upperIdx);
    end
end