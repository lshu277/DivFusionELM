function H = elm_activation(A, TF)
%ELM_ACTIVATION Apply the hidden-layer activation function.
%
%   H = elm_activation(A, TF) applies the activation function specified by
%   TF to the input matrix A.
%
%   Inputs:
%       A  - Hidden-layer pre-activation matrix, samples by hidden nodes
%       TF - Activation function name:
%            'sig'     sigmoid function
%            'sin'     sine function
%            'hardlim' hard-limit function
%
%   Output:
%       H  - Hidden-layer response matrix

if nargin < 2 || isempty(TF)
    TF = 'sig';
end

switch lower(TF)
    case {'sig', 'sigmoid'}
        H = 1 ./ (1 + exp(-A));

    case {'sin', 'sine'}
        H = sin(A);

    case {'hardlim', 'hardlimiting'}
        H = double(A >= 0);

    otherwise
        error('ELM:Activation', ...
            'Unsupported activation function "%s". Use sig, sin, or hardlim.', TF);
end

end