% This script performs an SNR recon on 3D GRE data:
% Input: kdata; dmtx; noise

function [csm,cal_images,kdata_pw,csm_pw,image_pw,snr_rss,snr_b1]= snr_3d_gre(kdata,dmtx)

%% Estimate coil sensitivities (Walsh) from 26 center lines:
[csm,cal_images] = estimate_sensitivities(kdata,26);

%% Apply decorrelation matrix to data and csm:
kdata_pw = ismrm_apply_noise_decorrelation_mtx(kdata,dmtx);
csm_pw   = ismrm_apply_noise_decorrelation_mtx(csm,dmtx);

%% output the covariance matrix before and after pre-whitening:
%% [psi,psi_pw] = calculate_cov(noise,dmtx);

%% Apply FT. 
image_pw = ismrm_transform_kspace_to_image(kdata_pw,[1 2 3]);

%% SNR with RSS combination; eq [5] of Kellman Erratum
snr_rss = sqrt(2)*sqrt((sum(abs(image_pw).^2,4)));

%% SNR with optimal B1- weighting; eq [6] of Kellman Erratum
den = abs( sum(conj(csm_pw) .* image_pw, 4 ) ) ; 
den = sqrt(2)*den;
num = sqrt( sum(abs(csm_pw).^2,4) ); 
snr_b1 = den./num; 

end