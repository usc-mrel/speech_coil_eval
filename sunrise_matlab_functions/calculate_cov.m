function [psi, psi_pw] = calculate_cov(noise,dmtx)
% This functions calculates the correlation before and after prewhitening.
% 
% INPUT:
%           Noise [Nc Ns Nr]            : Noise samples
%           dmtx  [Nc Nc]               : Decorrelation Matrix

% Reshape the noise:

noise = reshape(noise, size(noise,1), numel(noise)/size(noise,1));
% Number of elements per coil:
M = size(noise,2);

% Covariance matrix:
psi = (1/(M-1))*(noise*noise');

% Applying decorrelation to noise:
noise_pw = dmtx*noise;

% Pre-whitened covariance matrix:
psi_pw = (1/(M-1))*(noise_pw*noise_pw');

end