%% Add paths:
addpath('sunrise_matlab_functions'); 

%% Read kspace data,noise and decorrelation matrices for both coils:
cd tse_data/
filenames = {'dmtx_body.mat','dmtx_head.mat','kdata_body','kdata_head','noise_body','noise_head'};
for k = 1:numel(filenames)
    load(filenames{k});
end
clear filenames k 
cd ..
%% Output snr reconstruction parameters for the body coil:
[~,~,~,~,psi,psi_pw,image_pw_body,snr_rss_body,snr_b1_body]= snr_2d_tse(kdata_body,noise_body,dmtx_body);

%% Plot snr parameters for body coil:

% Show covariance matrix before and after pre-whitening:
figure; ax3 = axes;
imagesc(abs(psi)); axis equal; axis off; colormap(jet); colorbar
title(ax3,'Body Coil Covariance Matrix Before Pre-Whitening');

figure; ax4 = axes;
imagesc(abs(psi_pw)); axis equal; axis off; colormap(jet); colorbar
title(ax4,'Body Coil Covariance Matrix After Pre-Whitening');

% Display images:
figure; ax1 = axes;
montage(squeeze(abs(image_pw_body(:,:,16,:))),'Size',[1,size(kdata_body,4)],'ThumbnailSize',[size(kdata_body,1),...
size(kdata_body,2)],'DisplayRange',[])
title(ax1,'Body Coil Image data');

% Display SNR maps: 
figure;
sgtitle('SNR Body Coil')
subplot(1,3,1), imshow(log10(snr_rss_body(:,:,18)),[log10(1) log10(100)]); title('SNR RSS'); colormap(jet); colorbar; 
subplot(1,3,2), imshow(log10(snr_b1_body(:,:,18)), [log10(1) log10(100)]);  title('SNR B1'); colormap(jet); colorbar; 
subplot(1,3,3), imshow(real(log10(snr_b1_body(:,:,18) - snr_rss_body(:,:,18))),[-1 0]);  title('Difference');colormap(jet); colorbar; 


%% Output snr reconstruction parameters for the head coil:
[csm,cal_images,kdata_pw,csm_pw,psi,psi_pw,image_pw_head,snr_rss_head,snr_b1_head]= snr_2d_tse(kdata_head,noise_head,dmtx_head);


%% Plot SNR parameters for head coil:

figure; ax3 = axes;
imagesc(abs(psi)); axis equal; axis off; colormap(jet); colorbar
title(ax3,'Head Coil Covariance Matrix Before Pre-Whitening');

figure; ax4 = axes;
imagesc(abs(psi_pw)); axis equal; axis off; colormap(jet); colorbar
title(ax4,'Head Coil Covariance Matrix After Pre-Whitening');

% Display images:
figure; ax1 = axes;
montage(squeeze(abs(image_pw_head(:,:,16,:))),'Size',[1,size(kdata_head,4)],'ThumbnailSize',[size(kdata_head,1),...
size(kdata_head,2)],'DisplayRange',[])
title(ax1,'Head Coil Image data');

% Display SNR maps: 
figure;
sgtitle('SNR Head Coil')
subplot(1,3,1), imshow(log10(snr_rss_head(:,:,18)),[log10(1) log10(100)]); title('SNR RSS'); colormap(jet); colorbar; 
subplot(1,3,2), imshow(log10(snr_b1_head(:,:,18)), [log10(1) log10(100)]);  title('SNR B1'); colormap(jet); colorbar; 
subplot(1,3,3), imshow(real(log10(snr_b1_head(:,:,18) - snr_rss_head(:,:,18))),[-1 0]);  title('Difference');colormap(jet); colorbar; 

%% Get ratio of SNR's:
snr_rss_ratio = snr_rss_head./snr_rss_body;
snr_b1_ratio = snr_b1_head./snr_b1_body;

% Plot SNR ratios:
figure;
sgtitle('SNR Ratios')
subplot(1,2,1), imshow(log10(snr_rss_ratio(:,:,18)),[log10(1) log10(30)]);  title('SNR RSS Ratio');colormap(jet); colorbar;
subplot(1,2,2), imshow(log10(snr_b1_ratio(:,:,18)), [log10(1) log10(30)]);  title('SNR b1 Ratio') ;colormap(jet); colorbar;

clear ax* data_filename flag 


