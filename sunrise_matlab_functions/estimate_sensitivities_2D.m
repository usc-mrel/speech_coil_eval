function [ csm, cal_images ] = estimate_sensitivities_2D(k,extent)

% Function to estimate coil sensitivities of 2D k space data:
%
% Input:  - k       [Nx Ny Ns Coils]        : k-space data
%         - extent  scalar                  : extent of center lines
%
% Output: - csm     [Nx Ny Ns Coils]        : Coil sensitivities 
%         - cal_images                      : Calibration Images 



N_slices = size(k,3);


% Initialize zero matrix:
cal = zeros(size(k));

%% crop k space to extract center lines:

% Get center indices:

for i = 1:2
dim = i;
indices{i} = (1:extent)+bitshift(size(k, dim)-extent+1,-1);
end


% Extract center indices:
crop_k = k(indices{1},indices{2},:,:);

% Smooth kspace with a 2D hamming window:
filter = hamming(size(crop_k,1)) * hamming(size(crop_k,2))';
filter_rms = rms(filter(:));
filter2 = filter/filter_rms;
filter2 = repmat(filter2,[1,1,size(crop_k,3),size(crop_k,4)]);
crop_k   = crop_k .* filter2; 

% Insert into zero matrix for zero padding:
cal(indices{1},indices{2},:,:) = crop_k; 

%% Get calibration images:

cal_images = ismrm_transform_kspace_to_image(cal,[1,2]); 


%% Get Walsh sensitivity maps:

csm = zeros(size(cal_images));

for i = 1:N_slices
csm(:,:,i,:) = ismrm_estimate_csm_walsh(squeeze(cal_images(:,:,i,:)));
end
