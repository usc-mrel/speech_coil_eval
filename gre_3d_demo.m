%% This scripts reads in the speech, head, and body coil data, and performs an SNR reconstruction
%  for all the coils. It then outputs the SNR gain over the body coil for
%  both, the speech and the head coil.

% Please run this script from the ../speech_coil_eval folder (home folder of the repo).

addpath(genpath(cd));

% Load data for the speech, noise_speech, head, noise_head: (change vol_x
% to whichever volunteer is desired. Defaut is 3.)
cd ./data/vol_3
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

% Speech and head coil images:
fig = figure;
fig.Position = [1713 488 1286 630];
tile = tiledlayout(1,2);
tile.TileSpacing = 'none';

nexttile
montage(abs(image_pw_sp(:,:,18,:)),'DisplayRange',[],'Size',[4 2],'ThumbnailSize',[2*size(image_pw_sp,1),2*size(image_pw_sp,2)])
title('Speech Coil Images');
nexttile
montage(abs(image_pw_hd(:,:,18,:)),'DisplayRange',[],'Size',[4 4],'ThumbnailSize',[2*size(image_pw_hd,1),2*size(image_pw_hd,2)])
title('Head Coil Images');

% Body coil images:
fig = figure;
fig.Position = [1328 858 682  191];
tile = tiledlayout(1,2);

nexttile
montage(abs(image_pw_body_sp(:,:,18,:)),'DisplayRange',[],'Size',[1 2],'ThumbnailSize',[2*size(image_pw_sp,1),2*size(image_pw_sp,2)])
title('Body Coil Images With Speech Coil In');
nexttile
montage(abs(image_pw_body_hd(:,:,18,:)),'DisplayRange',[],'Size',[1 2],'ThumbnailSize',[2*size(image_pw_hd,1),2*size(image_pw_hd,2)])
title('Body Coil Images With Head Coil In');


%% Display SNR images;
f = figure; 
f.Position = [500 500 1500 500];
sgtitle('SNR Images','FontSize',15,'FontWeight','bold');


subplot(1,4,1)
imshow(snr_b1_sp(:,:,18),[0 30]); 
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
f.Position = [500 500 1500 500];
s =sgtitle('SNR Ratios (rSNR)','FontSize',15,'FontWeight','bold');

subplot(1,2,1)
imshow(snr_ratio_speech(:,:,18),[0,30]); colormap(jet); colorbar;
title('\textbf{SNR Gain Speech $\mathrm{rSNR_{UA}}$}','Interpreter','latex')

subplot(1,2,2)
imshow(snr_ratio_head(:,:,18),[0,30]); colormap(jet); colorbar;
title('\textbf{SNR Gain Head $\mathrm{rSNR_{HD}}$}','Interpreter','latex')

cd ../..



