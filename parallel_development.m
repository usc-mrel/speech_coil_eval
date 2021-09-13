%% This code starts form the prewhitened kspace and coil sensitivities from the speech and the head coil.
%  Perform analysis for acceleration of 2 3 4 and 6. 

%% Load the kspace data and make it 2d by FT in the slice encoding dir:
% Speech:
kdata_2d_sp = permute(kdata_sp_pw,[3 1 2 4]);
kdata_2d_sp = ismrm_transform_kspace_to_image(kdata_2d_sp,1);
kdata_2d_sp = permute(kdata_2d_sp,[2 3 1 4]);
% Head:
kdata_2d_hd = permute(kdata_hd_pw,[3 1 2 4]);
kdata_2d_hd = ismrm_transform_kspace_to_image(kdata_2d_hd,1);
kdata_2d_hd = permute(kdata_2d_hd,[2 3 1 4]);

%% Retrospectively undersample data for R = 2,3,4, and 5:

for a=[2 3 4 6]
    
acc_factor = a;
% size of sampling pattern matrix:
imsize = size(kdata_2d_sp,[1 2]);
% generate undersampling pattern:
sp = ismrm_generate_sampling_pattern(imsize, acc_factor, 0);
% generate accelerated data:
data_accel_sp = kdata_2d_sp .* repmat(sp ,[1 1 size(kdata_2d_sp,3),size(kdata_2d_sp,4)]);
data_accel_hd = kdata_2d_hd .* repmat(sp ,[1 1 size(kdata_2d_hd,3),size(kdata_2d_hd,4)]);

%% Generate alias images:
img_alias_sp = sqrt(acc_factor)*ismrm_transform_kspace_to_image(data_accel_sp,[1,2]);
img_alias_hd = sqrt(acc_factor)*ismrm_transform_kspace_to_image(data_accel_hd,[1,2]);

%% Calculate unmixing coefficients u:

% Initialize unmixing and g-map matrices:
u_sp = zeros(size(kdata_2d_sp));
u_hd = zeros(size(kdata_2d_hd));
g_sp = zeros(size(kdata_2d_sp,[1 2 3]));
g_hd = zeros(size(kdata_2d_hd,[1 2 3]));

% speech:
for i = 1:size(data_accel_sp,3)
    
    [u_sp(:,:,i,:),g_sp(:,:,i)]= ismrm_calculate_sense_unmixing(acc_factor,squeeze(csm_sp_pw(:,:,i,:)));
    
end
% head:
for i = 1:size(data_accel_hd,3)
    
    [u_hd(:,:,i,:),g_hd(:,:,i)]= ismrm_calculate_sense_unmixing(acc_factor,squeeze(csm_hd_pw(:,:,i,:)));
    
end
%% Perform SNR recon:[eq 7 of Kellman Erratum]:
snr_sp = sum(img_alias_sp .* u_sp,4);
snr_sp = snr_sp ./ sqrt(sum(abs(u_sp).^2,4));
snr_sp =sqrt(2)*snr_sp;

snr_hd = sum(img_alias_hd .* u_hd,4);
snr_hd = snr_hd ./ sqrt(sum(abs(u_hd).^2,4));
snr_hd =sqrt(2)*snr_hd;

%% Store values intro structure for later plotting:

if a == 6
    
    datap.img.sp{a-2}  = img_alias_sp((1:size(img_alias_sp,1)/2)+ size(img_alias_sp,1)/4,:,:,:);
    datap.img.hd{a-2}  = img_alias_hd((1:size(img_alias_hd,1)/2)+ size(img_alias_hd,1)/4,:,:,:);
    datap.gmap.sp{a-2} = g_sp((1:size(g_sp,1)/2) + size(g_sp,1)/4,:,:);
    datap.gmap.hd{a-2} = g_hd((1:size(g_hd,1)/2) + size(g_hd,1)/4,:,:);
    datap.snr.sp{a-2}  = snr_sp((1:size(snr_sp,1)/2) + size(snr_sp,1)/4,:,:);
    datap.snr.hd{a-2}  = snr_hd((1:size(snr_hd,1)/2) + size(snr_hd,1)/4,:,:);

else

    datap.img.sp{a-1}  = img_alias_sp((1:size(img_alias_sp,1)/2)+ size(img_alias_sp,1)/4,:,:,:);
    datap.img.hd{a-1}  = img_alias_hd((1:size(img_alias_hd,1)/2)+ size(img_alias_hd,1)/4,:,:,:);
    datap.gmap.sp{a-1} = g_sp((1:size(g_sp,1)/2) + size(g_sp,1)/4,:,:);
    datap.gmap.hd{a-1} = g_hd((1:size(g_hd,1)/2) + size(g_hd,1)/4,:,:);
    datap.snr.sp{a-1}  = snr_sp((1:size(snr_sp,1)/2) + size(snr_sp,1)/4,:,:);
    datap.snr.hd{a-1}  = snr_hd((1:size(snr_hd,1)/2) + size(snr_hd,1)/4,:,:);


end

end

%% Extract mean and max values of gmap for each acceleration factor for a drawn roi for one slice:

% speech:

% Display image for ROI drawing:
f = figure;
imshow(abs(datap.snr.sp{1}(:,:,18)),[0 10]);
f.Position = [1144  85  1385  1105];
% Draw ROI and create mask:
title('Speech coil: Please select ROI, double click when done.')
roi = drawfreehand('StripeColor','y');
customWait(roi);
position_roi_sp = roi.Position;
mask_sp = createMask(roi);
close;

% calculate and max and mean:
for i = 1:size(datap.gmap.sp,2)
    
    datap.gstat.sp.mean{i} = mean(nonzeros(mask.* datap.gmap.sp{i}(:,:,18)));
    datap.gstat.sp.max{i}  = max(nonzeros(mask.* datap.gmap.sp{i}(:,:,18)));
    
end



% head:

% Display image for ROI drawing:
f = figure;
imshow(abs(datap.snr.hd{1}(:,:,18)),[0 10]);
f.Position = [1144  85  1385  1105];
% Draw ROI and create mask:
title('Speech coil: Please select ROI, double click when done.')
roi = drawfreehand('StripeColor','y');
customWait(roi);
position_roi_hd = roi.Position;
mask_hd = createMask(roi);
close;

% calculate and max and mean:
for i = 1:size(datap.gmap.hd,2)
    
    datap.gstat.hd.mean{i} = mean(nonzeros(mask.* datap.gmap.hd{i}(:,:,18)));
    datap.gstat.hd.max{i}  = max(nonzeros(mask.* datap.gmap.hd{i}(:,:,18)));
    
end

%% Plot images and gmaps:

%% speech:

fig = figure;
fig.Position = [1440 966  1150 240];

tiledlayout(1,5,'TileSpacing', 'compact')

nexttile
%subplot(1,5,1)
imshow(snr_b1_sp((1:size(snr_b1_sp,1)/2)+size(snr_b1_sp,1)/4,:,18),[])
hold on
xy = position_roi_sp;
x = xy(:,1);
y = xy(:,2);
plot(x,y,'-r')
title('R = 1')

nexttile
%subplot(1,5,2)
imshow(abs(datap.snr.sp{1}(:,:,18)),[])
title('R = 2')

nexttile
%subplot(1,5,3)
imshow(abs(datap.snr.sp{2}(:,:,18)),[])
title('R = 3')

nexttile
%subplot(1,5,4)
imshow(abs(datap.snr.sp{3}(:,:,18)),[])
title('R = 4')

nexttile
%subplot(1,5,5)
imshow(abs(datap.snr.sp{4}(:,:,18)),[])
title('R = 6')

exportgraphics(fig,'sp_snr.tif','BackgroundColor','none')



% gmaps:

fig = figure;
fig.Position = [1440 966  1150 240];

tiledlayout(1,5,'TileSpacing', 'compact');

nexttile
imshow(ones(size(abs(datap.gmap.sp{1}(:,:,18)))),[0 10])

nexttile
%subplot(4,5,7)
imshow(abs(datap.gmap.sp{1}(:,:,18)),[0 10])
title('max g = 2.24, avg g = 1.25')

nexttile
%subplot(4,5,8)
imshow(abs(datap.gmap.sp{2}(:,:,18)),[0 10])
title('max g = 3.85, avg g = 1.67')

nexttile
%subplot(4,5,9)
imshow(abs(datap.gmap.sp{3}(:,:,18)),[0 10])
title('max g = 5.16, avg g = 2.11')

nexttile
%subplot(4,5,10)
imshow(abs(datap.gmap.sp{4}(:,:,18)),[0 10])
title('max g = 21.1, avg g = 4.43')

colormap('jet')
colorbar 


exportgraphics(fig,'sp_g.tif','BackgroundColor','none')

%% Head:

fig = figure;
fig.Position = [1440 966  1150 240];

tiledlayout(1,5,'TileSpacing', 'compact')

nexttile
%subplot(1,5,1)
imshow(snr_b1_hd((1:size(snr_b1_hd,1)/2)+size(snr_b1_hd,1)/4,:,18),[])
hold on
xy = position_roi_hd;
x = xy(:,1);
y = xy(:,2);
plot(x,y,'-r')
title('R = 1')

nexttile
%subplot(1,5,2)
imshow(abs(datap.snr.hd{1}(:,:,18)),[])
title('R = 2')

nexttile
%subplot(1,5,3)
imshow(abs(datap.snr.hd{2}(:,:,18)),[])
title('R = 3')

nexttile
%subplot(1,5,4)
imshow(abs(datap.snr.hd{3}(:,:,18)),[])
title('R = 4')

nexttile
%subplot(1,5,5)
imshow(abs(datap.snr.hd{4}(:,:,18)),[])
title('R = 6')

exportgraphics(fig,'hd_snr.tif','BackgroundColor','none')

% gmaps:

fig = figure;
fig.Position = [1440 966  1150 240];

tiledlayout(1,5,'TileSpacing', 'compact');

nexttile
imshow(ones(size(abs(datap.gmap.hd{1}(:,:,18)))),[0 10])

nexttile
%subplot(4,5,7)
imshow(abs(datap.gmap.hd{1}(:,:,18)),[0 10])
title('max g = 1.48, avg g = 1.10')

nexttile
%subplot(4,5,8)
imshow(abs(datap.gmap.hd{2}(:,:,18)),[0 10])
title('max g = 2.18, avg g = 1.30')

nexttile
%subplot(4,5,9)
imshow(abs(datap.gmap.hd{3}(:,:,18)),[0 10])
title('max g = 4.71, avg g = 1.96')

nexttile
%subplot(4,5,10)
imshow(abs(datap.gmap.hd{4}(:,:,18)),[0 10])
title('max g = 11.2, avg g = 4.30')


colormap('jet')
colorbar

exportgraphics(fig,'hd_g.tif','BackgroundColor','none')


