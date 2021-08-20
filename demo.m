
addpath('sunrise_matlab_functions/')
% Script to perform SNR unit reconstruction on 3D imaging and noise data.
% Takes in imaging data and noise data, and ouputs SNR recon in RSS and B1
% Weighted. 

% The data in this demo is located in: 
% speech_coil_eval/data_speech_coil.mat

% Read data and noise files:
% Loads: dmtx : decorrelation matrix
%        kdata: kspace data with speech coil, 3D GRE
%        Noise: Noise measurements from all coils. 

load('data_speech_coil.mat');


%% Estimate coils sensitivities from 26 center lines:
[csm,cal_images] = estimate_sensitivities(kdata,26);
% sanity check: display coil sensitivities 

%% Apply decorrelation matrix to data and csm:
kdata_pw = ismrm_apply_noise_decorrelation_mtx(kdata,dmtx);
csm_pw   = ismrm_apply_noise_decorrelation_mtx(csm,dmtx);
% sanity check: display the noise cov matrix before and after decorrelation

%% Apply FT. 
image_pw = ismrm_transform_kspace_to_image(kdata_pw,[1 2 3]);
% sanity check: display the k-space matrix and image space image

%% SNR with RSS combination; eq [5] of Kellman Erratum
snr_rss = sqrt(2)*sqrt((sum(abs(image_pw).^2,4)));

%% SNR with optimal B1- weighting; eq [6] of Kellman Erratum
den = abs( sum(conj(csm_pw) .* image_pw, 4 ) ) ; 
den = sqrt(2)*den;
num = sqrt( sum(abs(csm_pw).^2,4) ); 
snr_b1 = den./num; 

%% Plot Results
figure;
sgtitle('Signal-to-Noise Ratio (SNR)')
subplot(1,3,1);
imshow(log10(snr_rss(:,:,18)),[log10(1) log10(100)]); 
title('log10(SNR) of RSS reconstruction'); 
colormap(jet); 
colorbar; 

subplot(1,3,2), 
imshow(log10(snr_b1(:,:,18)),[log10(1) log10(100)]);  
title('log10(SNR) of optimal B1 reconstruction'); 
colormap(jet); 
colorbar; 

subplot(1,3,3);
imshow(log10(snr_b1(:,:,18) - snr_rss(:,:,18)),[-1 0]);  
title('SNR_b_1 - SNR_r_s_s');
colormap(jet); 
colorbar; 


