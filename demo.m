
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
% Display magnitude:
figure;  ax1 = axes;
montage(squeeze(abs(csm(:,:,18,:))),'Size', [1,8],'ThumbnailSize',[size(csm,1),size(csm,2)],'DisplayRange',[]);
title(ax1,'Magnitude of Coil Sensitivities');
% Display Phase:
figure; ax2 = axes;
montage(squeeze(angle(csm(:,:,18,:))),'Size', [1,8],'ThumbnailSize',[size(csm,1),size(csm,2)],'DisplayRange',[]);
title(ax2,'Phase of Coil Sensitivities');


%% Apply decorrelation matrix to data and csm:
kdata_pw = ismrm_apply_noise_decorrelation_mtx(kdata,dmtx);
csm_pw   = ismrm_apply_noise_decorrelation_mtx(csm,dmtx);

% sanity check: display the noise cov matrix before and after decorrelation
% output the covariance matrix before and after pre-whitening:
[psi,psi_pw] = calculate_cov(noise,dmtx);

% Display the covariance matrices before and after pre-whitening:
figure; ax3 = axes;
imagesc(abs(psi)); axis equal; axis off; colormap(jet); colorbar
title(ax3,'Covariance Matrix Before Pre-Whitening');

figure; ax4 = axes;
imagesc(abs(psi_pw)); axis equal; axis off; colormap(jet); colorbar
title(ax4,'Covariance Matrix After Pre-Whitening');

%% Apply FT. 
image_pw = ismrm_transform_kspace_to_image(kdata_pw,[1 2 3]);
% sanity check: display the k-space matrix and image space image
% Display k-space data:
figure; ax5 = axes;
montage(squeeze(abs(kdata_pw(:,:,18,:))),'Size',[1,size(kdata,4)],'ThumbnailSize',[size(kdata,1),...
size(kdata,2)],'DisplayRange',[])
title(ax5,'K-space data')

% Display images:
figure; ax1 = axes;
title('Image data')
montage(squeeze(abs(image_pw(:,:,18,:))),'Size',[1,size(kdata,4)],'ThumbnailSize',[size(kdata,1),...
size(kdata,2)],'DisplayRange',[])
title(ax1,'Image data');

%% SNR with RSS combination; eq [5] of Kellman Erratum
snr_rss = sqrt(2)*sqrt((sum(abs(image_pw).^2,4)));

%% SNR with optimal B1- weighting; eq [6] of Kellman Erratum
den = abs( sum(conj(csm_pw) .* image_pw, 4 ) ) ; 
den = sqrt(2)*den;
num = sqrt( sum(abs(csm_pw).^2,4) ); 
snr_b1 = den./num; 

%% Plot Results
f= figure;
f.Position = [500 500 900 600];
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


