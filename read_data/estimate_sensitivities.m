% estimate coil sensitivities from center lines:
function [ csm, cal_images ] = estimate_sensitivities(k,extent)

% Function to estimate coil sensitivities of 3D k space data:
%
% Input:  - k      [Nx Ny Nz Coils]     : k-space data
%         - extent scalar               : extent of center lines
%
% Output: - csm    [Nx Ny Nz Coils]     : Coil sensitivities 
%         - cal_images                  : Calibration Images 



N_slices = size(k,3);


% Initialize zero matrix:
cal = zeros(size(k));

%% crop k space to extract center lines:

% Get center indices:

for i = 1:3
dim = i;
indices{i} = (1:extent)+bitshift(size(k, dim)-extent+1,-1);
end


% Extract center indices:
crop_k = k(indices{1},indices{2},indices{3},:);

% Smooth kspace with a 3D hamming window:
filter = hamming_3d(size(crop_k,1),size(crop_k,2),size(crop_k,3));
% Divide by root mean square of Hamming filter to keep SD=1
filter_r = rms(filter(:));
filter = filter/filter_r;

filter = repmat(filter,[1,1,1,size(crop_k,4)]);
crop_k   = crop_k .* filter; 

% Insert into zero matrix for zero padding:
cal(indices{1},indices{2},indices{3},:) = crop_k; 

%% Get calibration images:

cal_images = ismrm_transform_kspace_to_image(cal,[1,2,3]); 


%% Get Walsh sensitivity maps:

csm = zeros(size(cal_images));

for i = 1:N_slices
csm(:,:,i,:) = ismrm_estimate_csm_walsh(squeeze(cal_images(:,:,i,:)));
end



