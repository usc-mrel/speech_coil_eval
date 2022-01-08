function [snr_ratio_sp,snr_ratio_hd] = ratio_output
% This script does the following:
% - reads all the h5 files (speech, head, body coils) [i]
% - obtains the decorelation matrices from the noise data [ii]
% - does an SNR recon for speech, head, and body coils [iii]
% - calculates and outputs the ratio of speech/body and head/body [iv] 

%% load speech, body, and noise: [i,ii]
data_filename = 'gre_speech.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_sp,~] = read_h5_data(data_filename,flag);
kdata_sp = flip(kdata_sp,2);

data_filename = 'noise_speech.h5'; 
[~,dmtx_sp] = process_noise_spectrum(data_filename);

%load body and its noise:
data_filename = 'gre_body_sp.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_body_sp,~] = read_h5_data(data_filename,flag);
kdata_body_sp = flip(kdata_body_sp,2);

data_filename = 'noise_body_sp.h5'; %vol52 noise_body_hd ->> sp
[~,dmtx_body_sp] = process_noise_spectrum(data_filename);

%% load head, body and noise: [i,ii]
data_filename = 'gre_head.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_hd,~] = read_h5_data(data_filename,flag);
kdata_hd = flip(kdata_hd,2);

data_filename = 'noise_head.h5'; 
[~,dmtx_hd] = process_noise_spectrum(data_filename);

%load body and its noise:
data_filename = 'gre_body_hd.h5'; 
flag.concatenate = 0;
flag.remove_noise = 1; 
flag.removeOS = 0;
[kdata_body_hd,~] = read_h5_data(data_filename,flag);
kdata_body_hd = flip(kdata_body_hd,2);

data_filename = 'noise_body_hd.h5'; 
[~,dmtx_body_hd] = process_noise_spectrum(data_filename);

%% Perform the SNR reconstruction on speech data: [iii]
[~,~,~,~,~,~,snr_b1_sp]= snr_3d_gre(kdata_sp,dmtx_sp);

%% Perform the SNR reconstruciotn on body data with speech coil in: [iii]
[~,~,~,~,~,~,snr_b1_body_sp]= snr_3d_gre(kdata_body_sp,dmtx_body_sp);

%% Perform the SNR reconstruction on head data: [iii]
[~,~,~,~,~,~,snr_b1_hd]= snr_3d_gre(kdata_hd,dmtx_hd);

%% Perform the SNR reconstruciotn on body data with head coil in: [iii]
[~,~,~,~,~,~,snr_b1_body_hd]= snr_3d_gre(kdata_body_hd,dmtx_body_hd);

%% Obtain the ratios of snr_coil/snr_body: [iv]
snr_ratio_sp = snr_b1_sp./snr_b1_body_sp;
snr_ratio_hd = snr_b1_hd./snr_b1_body_hd;

