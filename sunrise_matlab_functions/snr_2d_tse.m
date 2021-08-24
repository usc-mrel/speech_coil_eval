function [csm,cal_images,kdata_pw,csm_pw,psi,psi_pw,image_pw,snr_rss,snr_b1]= snr_2d_tse(kdata,noise,dmtx)


%% Estimate coils sensitivities from 34 center lines:
[csm,cal_images] = estimate_sensitivities_2D(kdata,34);


%% Apply decorrelation matrix to data and csm:
kdata_pw = ismrm_apply_noise_decorrelation_mtx(kdata,dmtx);
csm_pw   = ismrm_apply_noise_decorrelation_mtx(csm,dmtx);

%% Output covariance matrix before and after pre-whitening:
[psi,psi_pw] = calculate_cov(noise,dmtx);

%% Apply FT:
image_pw = ismrm_transform_kspace_to_image(kdata_pw,[1 2]);

%% SNR maps:

% SNR without coil sensitivities; eq [5] of Kellman Erratum
snr_rss = sqrt(2)*sqrt((sum(abs(image_pw).^2,4)));

% SNR with B1 weighting; eq [6] of Kellman Erratum
den = abs( sum(conj(csm_pw) .* image_pw, 4 ) ) ; 
den = sqrt(2)*den;
num = sqrt( sum(abs(csm_pw).^2,4) ); 
snr_b1 = den./num;

end