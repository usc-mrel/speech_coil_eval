function [dtx] = process_noise_spectrum(noise)
%
% Function to process noise spectrum of noise scan.
%
% Inputs:
%       -noise_data [Ns Nav Nm Nc]   : Noise kdata with averages
% Outputs:
%       -dtx        [Nc Nc]          : Noise decorrelation matrix 
%
Nav = size(noise,2);            % Number of averages 

noise = squeeze(mean(noise,2)); % Average the averages. New size [ Ns Nm Nc]
                                % This will change the variance of the
                                % noise. Correct by multiplying by
                                % sqrt(N_averages)

noise = noise*sqrt(Nav);        % unscale the variance                             
                                
noise = permute(noise,[3,1,2]);

[nr_channels,nr_samples,nr_repetitions] = size(noise);

Nc = nr_channels;
Ns = nr_samples * nr_repetitions;
eta = reshape(noise, [Nc Ns]);
Psi = eta * eta' / Ns; % Equation B1

%% Calculate noise equivalent bandwidth:

noise_vec = permute(reshape(noise, [Nc Ns]),[2,1]);

for k =1:size(noise_vec,2)
    [p(:,k),f(:,k)] = pspectrum(noise_vec(:,k).','FrequencyLimits',[-pi pi]);
end
flat_mag_noise = mean(p(910:3115,:),1); % flat portion of spectrum
all_mag_noise = mean(p,1);
noise_ratio = mean(all_mag_noise./flat_mag_noise);
% 3 digit precision 
sprintf('The equivalent noise bandwidth is %.3f ', noise_ratio)

% Scale covariance matrix by this ratio:

Psi = Psi/noise_ratio;

%% Calculate decorrelation matrix 

L = chol(Psi, 'lower'); % Equation B4
dtx = inv(L);


end 