function [noise,dtx] = process_noise_spectrum(noise_filename)
%
% Function to process noise spectrum of noise scan.
%
% Inputs:
%       -noise_filename   :          : Filename of h5 noise data
% Outputs:
%       -noise      [Nc Ns*Nav Nm]   : Noise data; Nav=number of averages
%       -dtx        [Nc Nc]          : Noise decorrelation matrix 
%

%% Read noise data:

flag.concatenate = 0;
flag.remove_noise = 0;
%flag.removeOS =0;

% read noise data: Output is of size [Ns Nav Nm Nc]
[noise,~] = read_h5_data(noise_filename,flag);
% reshape noise to [Ns*Nav Nm Nc]:
noise = reshape(noise, [size(noise,1)*size(noise,2),size(noise,3),size(noise,4)]);
% "rescale noise":
noise = sqrt(20)*noise;
                           
% reshape noise to [Nc Ns*Nav Nm];                                
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