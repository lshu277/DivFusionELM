function H = hidden_layer_forward(P, IW, B, TF)
%HIDDEN_LAYER_FORWARD Compute hidden-layer responses.
%
%   H = hidden_layer_forward(P, IW, B, TF) computes the hidden-layer
%   pre-activation matrix and applies the specified activation function.
%
%   Inputs:
%       P  - Input matrix, samples by features
%       IW - Input weight matrix, features by hidden nodes
%       B  - Bias row vector, 1 by hidden nodes
%       TF - Activation function name
%
%   Output:
%       H  - Hidden-layer response matrix

numSamples = size(P, 1);
preActivation = P * IW + repmat(B, numSamples, 1);
H = elm_activation(preActivation, TF);

end
