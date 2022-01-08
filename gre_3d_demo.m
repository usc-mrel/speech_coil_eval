%% This scripts reads in the speech, head, and body coil data, and performs an SNR reconstruction
%  for all the coils. It then outputs the SNR gain over the body coil for
%  both, the speech and the head coil. It prompts to draw the ROIs and
%  stores ROI information in data structure 'data'.

% Please run this script from the ../speech_coil_eval folder (home folder of the repo).

addpath(genpath('../speech_coil_eval/'));

% Load data for the speech, noise_speech, head, noise_head: (change vol_x
% to whichever volunteer is desired. Defaut is 4.)
cd ./all_data/vol_4/
%% load speech, body, and noise:
data_filename = 'gre_speech.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_sp,~] = read_h5_data(data_filename,flag);
kdata_sp = flip(kdata_sp,2);

data_filename = 'noise_speech.h5'; 
[noise_sp,dmtx_sp] = process_noise_spectrum(data_filename);

%load body and its noise:
data_filename = 'gre_body_sp.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_body_sp,~] = read_h5_data(data_filename,flag);
kdata_body_sp = flip(kdata_body_sp,2);

data_filename = 'noise_body_sp.h5'; 
[noise_body_sp,dmtx_body_sp] = process_noise_spectrum(data_filename);

%% load head, body and noise:
data_filename = 'gre_head.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_hd,~] = read_h5_data(data_filename,flag);
kdata_hd = flip(kdata_hd,2);

data_filename = 'noise_head.h5'; 
[noise_hd,dmtx_hd] = process_noise_spectrum(data_filename);

%load body and its noise:
data_filename = 'gre_body_hd.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_body_hd,~] = read_h5_data(data_filename,flag);
kdata_body_hd = flip(kdata_body_hd,2);

data_filename = 'noise_body_hd.h5'; 
[noise_body_hd,dmtx_body_hd] = process_noise_spectrum(data_filename);

%% Perform the SNR reconstruction on speech data:
[~,~,~,~,image_pw_sp,~,snr_b1_sp]= snr_3d_gre(kdata_sp,dmtx_sp);

%% Perform the SNR reconstruciotn on body data with speech coil in:
[~,~,~,~,image_pw_body_sp,~,snr_b1_body_sp]= snr_3d_gre(kdata_body_sp,dmtx_body_sp);

%% Perform the SNR reconstruction on head data:
[~,~,~,~,image_pw_hd,~,snr_b1_hd]= snr_3d_gre(kdata_hd,dmtx_hd);

%% Perform the SNR reconstruciotn on body data with head coil in:
[~,~,~,~,image_pw_body_hd,~,snr_b1_body_hd]= snr_3d_gre(kdata_body_hd,dmtx_body_hd);

%% Plot some pre-whitened images from all coils:
speech_image  = reshape(squeeze(abs(image_pw_sp(:,:,18,:))),[size(image_pw_sp,1), size(image_pw_sp,2)*size(image_pw_sp,4)]);
head_image    = reshape(squeeze(abs(image_pw_hd(:,:,18,:))),[size(image_pw_hd,1), size(image_pw_hd,2)*size(image_pw_hd,4)]);
body_sp_image = reshape(squeeze(abs(image_pw_body_sp(:,:,18,:))),[size(image_pw_body_sp,1), size(image_pw_body_sp,2)*size(image_pw_body_sp,4)]);
body_hd_image = reshape(squeeze(abs(image_pw_body_hd(:,:,18,:))),[size(image_pw_body_hd,1), size(image_pw_body_hd,2)*size(image_pw_body_hd,4)]);

figure; ax1 = axes; imshow(speech_image,[]);  title(ax1,'Speech Coil Images');
figure; ax2 = axes; imshow(head_image,[]);    title(ax2,'Head Coil Images');
figure; ax3 = axes; imshow(body_sp_image,[]); title(ax3,'Body Coil Images with Speech Coil In');
figure; ax4 = axes; imshow(body_hd_image,[]); title(ax4,'Body Coil Images with head coil in');
clear ax*

%% Display SNR images;
f = figure; 
f.Position = [500 500 1500 500];

subplot(1,4,1)
imshow(log10(snr_b1_sp(:,:,18)),[log10(1) log10(100)]); 
title('log10(SNR) of B1 reconstruction for speech coil'); 
colormap(jet); 
colorbar; 

subplot(1,4,2)
imshow(log10(snr_b1_body_sp(:,:,18)),[log10(1) log10(100)]); 
title('log10(SNR) of B1 reconstruction for body coil (speech in)'); 
colormap(jet); 
colorbar; 

subplot(1,4,3)
imshow(log10(snr_b1_hd(:,:,18)),[log10(1) log10(100)]); 
title('log10(SNR) of B1 reconstruction for head coil'); 
colormap(jet); 
colorbar; 

subplot(1,4,4)
imshow(log10(snr_b1_body_hd(:,:,18)),[log10(1) log10(100)]); 
title('log10(SNR) of B1 reconstruction for body coil (head in)'); 
colormap(jet); 
colorbar; 

%% Display SNR images;
f = figure; 
f.Position = [500 500 1500 500];

subplot(1,4,1)
imshow(snr_b1_sp(:,:,18),[0 50]); 
title('SNR of B1 reconstruction for speech coil'); 
colormap(jet); 
colorbar; 

subplot(1,4,2)
imshow(snr_b1_body_sp(:,:,18),[0 10]); 
title('SNR B1 reconstruction for body coil (speech in)'); 
colormap(jet); 
colorbar; 

subplot(1,4,3)
imshow(snr_b1_hd(:,:,18),[0 30]); 
title('SNR of B1 reconstruction for head coil'); 
colormap(jet); 
colorbar; 

subplot(1,4,4)
imshow(snr_b1_body_hd(:,:,18),[0 10]); 
title('SNR of B1 reconstruction for body coil (head in)'); 
colormap(jet); 
colorbar; 

%% Calculate and display SNR ratios:
snr_ratio_speech = snr_b1_sp./snr_b1_body_sp;
snr_ratio_head  =  snr_b1_hd./snr_b1_body_hd;

f = figure;

subplot(1,2,1)
imshow(snr_ratio_speech(:,:,18),[0,30]); colormap(jet); colorbar;
title('SNR Gain Speech')

subplot(1,2,2)
imshow(snr_ratio_head(:,:,18),[0,30]); colormap(jet); colorbar;
title('SNR Gain Head')

%% Draw ROIs for one slice (There are 8 rois: upper lip, lower lip, front, mid, back tongue, palate, velum, pharyngeal wall);
% Please draw ROIs in the order above.
% Initialize data structure:
data = struct();
% Speech coil:
for i = 1:8 % This is for 8 ROIs
f = figure;
f.Position = [500  115  689  516];
% Display image for ROI drawing:
imshow(snr_b1_sp(:,:,18),[]);
title('Speech coil: Please select ROI, double click when done.')
roi = drawfreehand('StripeColor','y');
customWait(roi);
% Create mask:
data.mask.sp{i} = createMask(roi); 
% Apply mask to the SNR ratio image:
data.masked.sp{i} = data.mask.sp{i}.*squeeze(snr_ratio_speech(:,:,16));
% Obtain mean and variance:
data.mean_array.sp{i} = mean(nonzeros(data.masked.sp{i}));
data.var_array.sp{i}  = var(nonzeros(data.masked.sp{i}),[],'all');
end

% Head coil
for i = 1:8
f = figure;
f.Position = [500  115  689  516];
% Display image for ROI drawing:
imshow(snr_b1_hd(:,:,17),[]);
title('Head coil: Please select ROI, double click when done.')
roi = drawfreehand('StripeColor','y');
customWait(roi);
% Create mask:
data.mask.hd{i} = createMask(roi);
% Apply mask to the SNR ratio image:
data.masked.hd{i} = data.mask.hd{i}.*squeeze(snr_ratio_head(:,:,16));
% Obtain mean and variance:
data.mean_array.hd{i} = mean(nonzeros(data.masked.hd{i}));
data.var_array.hd{i}  = var(nonzeros(data.masked.hd{i}),[],'all');
end

%% Create table to store data:
% These are the names and order of the ROI regions:
roi_list = {'Upper lip';'Lower lip';'Front tongue';'Mid tongue';'Back tongue';'Palate';'Velum';'Pharyngeal Wall'};
% Create table:
table_speech = table(roi_list(:),data.mean_array.sp(:));
table_head   = table(roi_list(:),data.mean_array.hd(:));







