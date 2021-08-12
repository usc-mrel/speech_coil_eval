addpath(genpath('/Users/felix/Research_Local'))


% read experiments from speech/body coil scan:

%% Speech coil GRE and TSE

% speech GRE:

%

% filename = 'meas_MID00156_FID10956_3D_GRE_speechcoil.h5';
% flag.concatenate = 0; % this is used for TSE
% [kspace_speech_gre,~] = read_h5_data(filename,flag);


% speech TSE:

filename = 'meas_MID00162_FID10962_T2_2D_TSE_SAG_speechcoil.h5';
flag.concatenate = 1; % this is used for TSE
[kspace_speech_TSE,~] = read_h5_data(filename,flag);
image_speech_TSE = ismrm_transform_kspace_to_image(kspace_speech_TSE,[1,2]);
image_speech_TSE_rss = sqrt(sum(image_speech_TSE.^2,4));




%% Body coil GRE and TSE 

% body GRE:

filename = 'meas_MID00155_FID10955_3D_GRE.h5';
flag.concatenate = 0; % this is used for TSE
[kspace_body_gre,~] = read_h5_data(filename,flag); 
image_body_gre = ismrm_transform_kspace_to_image(kspace_body_gre,[1,2]);
image_body_gre_rss = sqrt(sum(image_body_gre.^2,4));



% body TSE:

filename = 'meas_MID00161_FID10961_T2_2D_TSE_SAG_bodycoil.h5';
flag.concatenate = 1; % this is used for TSE
[kspace_body_TSE,~] = read_h5_data(filename,flag);
image_body_TSE = ismrm_transform_kspace_to_image(kspace_body_TSE,[1,2]);
image_body_TSE_rss = sqrt(sum(image_body_TSE.^2,4));

