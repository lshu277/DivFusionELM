function rmseValue = rmse_samplewise(Yhat, Ytrue)
%RMSE_SAMPLEWISE Compute sample-wise root mean square error.

residual = Yhat - Ytrue;
rmseValue = sqrt(mean(sum(residual.^2, 2)));

end
