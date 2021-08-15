function [noise,dtx] = process_noise_ismrmrd_data(noise_fullpath)


%% Read an ismrmrd file
tic; fprintf('Reading an ismrmrd file: %s... ', noise_fullpath);
if exist(noise_fullpath, 'file')
    dset2 = ismrmrd.Dataset(noise_fullpath, 'dataset'); %
    fprintf('done! (%6.4f sec)\n', toc);
else
    error('File %s does not exist.  Please generate it.' , noise_fullpath);
end
raw_data = dset2.readAcquisition();

%% Sort noise data
is_noise = raw_data.head.flagIsSet('ACQ_IS_NOISE_MEASUREMENT');
meas = raw_data.select(find(is_noise)); % ouputs sets of 512x8 measurements
nr_repetitions = length(meas.data); % number of repetitions
[nr_samples,nr_channels] = size(meas.data{1});
noise = complex(zeros(nr_channels, nr_samples, nr_repetitions, 'double'));
for idx = 1:nr_repetitions
    noise(:,:,idx) = meas.data{idx}.'; % nr_samples x nr_channels => nr_channels x nr_samples
end

%% Calculate noise covariance matrix:

[nr_channels,nr_samples,nr_repetitions] = size(noise);

Nc = nr_channels;
Ns = nr_samples * nr_repetitions;
eta = reshape(noise, [Nc Ns]);
Psi = eta * eta' / Ns; % Equation B1

%% Calculate noise equivalent bandwidth:

noise_vec = permute(reshape(noise, [Nc Ns]),[2,1]);

for k =1:size(noise_vec,2)
    [p(:,k),f(:,k)] = pspectrum(noise_vec(:,k).','FrequencyLimits',[-pi pi]);
end
flat_mag_noise = mean(p(910:3115,:),1); % flat portion of spectrum
all_mag_noise = mean(p,1);
noise_ratio = mean(all_mag_noise./flat_mag_noise);
% 3 digit precision 
sprintf('The equivalent noise bandwidth is %.3f ', noise_ratio)

% Scale covariance matrix by this ratio:

Psi = Psi/noise_ratio;

%% Calculate decorrelation matrix 

L = chol(Psi, 'lower'); % Equation B4
dtx = inv(L);








end

