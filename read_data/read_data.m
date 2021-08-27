addpath(genpath('../speech_coil_eval/')); %genpath generates a list of subfolders. Added ../
%% Read kspace data and noise for the body coil:
cd ./data
% read kspace data:
data_filename = 'meas_MID00180_FID10980_T2_2D_TSE_SAG_bodycoil_headin.h5'; 
flag.concatenate = 1;
flag.remove_noise = 1;
flag.removeOS = 0; 
[kdata_body,~] = read_h5_data(data_filename,flag);
% Reorder interlaved acquisition:
kdata_body = reorder_slices(kdata_body); 

% reading and processing the noise scan:
data_filename = 'meas_MID00184_FID10984_rf_noise_spectrum_150HzPx_body.h5'; 
[noise_body, dmtx_body] = process_noise_spectrum(data_filename);

clear data_filename flag 