
addpath(genpath(cd));
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
% mask csm to remove low signal areas:
mask = double(mask);
mask(mask==0)=nan; 
csm = csm .* mask;

%% sanity check: display coil sensitivities 
f = figure;
f.Position = [1629  486  1143  641];
tile = tiledlayout(2,1);
tile.TileSpacing = 'none';



% Display magnitude:
h(1) = nexttile;
montage(squeeze(abs(csm(:,:,18,:))),'Size', [1,8],'ThumbnailSize',[size(csm,1),size(csm,2)],'DisplayRange',[]);
title('Magnitude of Coil Sensitivities (Mid-Sagittal Slice)');

% Display Phase:
h(2)=nexttile;
montage(squeeze(angle(csm(:,:,18,:))),'Size', [1,8],'ThumbnailSize',[size(csm,1),size(csm,2)],'DisplayRange',[]);
title('Phase of Coil Sensitivities (Relative to first coil)');

colormap(h(2),jet)
colorbar(h(2))




%% Apply decorrelation matrix to data and csm:
kdata_pw = ismrm_apply_noise_decorrelation_mtx(kdata,dmtx);
csm_pw   = ismrm_apply_noise_decorrelation_mtx(csm,dmtx);

% sanity check: display the noise cov matrix before and after decorrelation
% output the covariance matrix before and after pre-whitening:
[psi,psi_pw] = calculate_cov(noise,dmtx);

% Display the covariance matrices before and after pre-whitening:
f = figure;
f.Position = [1440 971 794 366];
tile = tiledlayout(1,2);

h(1) = nexttile;
imagesc(abs(psi)); axis off; colormap(jet); colorbar
title('Covariance Matrix Before Pre-Whitening');

h(2) = nexttile;
imagesc(abs(psi_pw));  axis off; colormap(jet); colorbar
title('Covariance Matrix After Pre-Whitening');

%% Apply FT. 
image_pw = ismrm_transform_kspace_to_image(kdata_pw,[1 2 3]);
%% Display k-space data:

f = figure;
f.Position = [1629  486  1143  641];
tile = tiledlayout(2,1);
tile.TileSpacing = 'none';

h(1) = nexttile;
montage(squeeze(abs(kdata_pw(:,:,18,:))),'Size', [1,8],'ThumbnailSize',[size(kdata,1),size(kdata,2)],'DisplayRange',[]);
title('Magnitude of K-space data');

% Display Phase:
h(2)=nexttile;
montage(squeeze(angle(kdata_pw(:,:,18,:))),'Size', [1,8],'ThumbnailSize',[size(kdata,1),size(kdata,2)],'DisplayRange',[]);
title('Phase of K-space data');

colormap(h(2),jet)
colorbar(h(2))
%% Display images:

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
imshow(log10(snr_rss([1:size(snr_rss,1)/2]+size(snr_rss,1)/4,:,18)),[log10(1) log10(100)]); 
title('log10(SNR) of RSS reconstruction'); 
colormap(jet); 
colorbar; 

subplot(1,3,2), 
imshow(log10(snr_b1([1:size(snr_b1,1)/2]+size(snr_b1,1)/4,:,18)),[log10(1) log10(100)]);  
title('log10(SNR) of optimal B1 reconstruction'); 
colormap(jet); 
colorbar; 

subplot(1,3,3);
imshow(log10(snr_b1([1:size(snr_rss,1)/2]+size(snr_rss,1)/4,:,18) - snr_rss([1:size(snr_rss,1)/2]+size(snr_rss,1)/4,:,18)),[-1 0]);  
title('SNR_b_1 - SNR_r_s_s');
colormap(jet); 
colorbar; 


