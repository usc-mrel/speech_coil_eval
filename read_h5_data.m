function [ kdata, info ] = read_h5_data(filename,flag)

% Read one h5 dataset
% 
% Input:
%   - filename of h5 file
%
% Output: 
%   - Kspace data, experiment info


dset = ismrmrd.Dataset( filename , 'dataset');

%% parse XML header:

header = ismrmrd.xml.deserialize(dset.readxml);

% get experiment information from header:

 % ---- Sequence parameters ----
 
 
    info.TR         = header.sequenceParameters.TR;     % [msec]
    info.TE         = header.sequenceParameters.TE;     % [msec]
    %info.flip_angle = header.sequenceParameters.flipAngle_deg; % [degrees]
    

    
    % ---- Ecoding info ----
    
    info.field_of_view_mm(1) = header.encoding.reconSpace.fieldOfView_mm.x; % RO
    info.field_of_view_mm(2) = header.encoding.reconSpace.fieldOfView_mm.y; % PE
    info.field_of_view_mm(3) = header.encoding.reconSpace.fieldOfView_mm.z; % SS
    
    info.Nkx = header.encoding.encodedSpace.matrixSize.x; 
    info.Nky = header.encoding.encodedSpace.matrixSize.y; 
    info.Nkz = header.encoding.encodedSpace.matrixSize.z; 
    info.Nx  = header.encoding.reconSpace.matrixSize.x;   
    info.Ny  = header.encoding.reconSpace.matrixSize.y;   
    info.Nz  = header.encoding.reconSpace.matrixSize.z;   

    %% Parse Acquisition Header:
    
    acqs = dset.readAcquisition();
    
   
    
     % --- Remove Noise measurements ----% 
    
     
     is_noise = acqs.head.flagIsSet('ACQ_IS_NOISE_MEASUREMENT');
     not_noise = ~is_noise; 
     acqs = acqs.select(find(not_noise));
     
     
    %%
   
    
    
    info.rawData.number_of_samples  = single(max(acqs.head.number_of_samples));
    info.rawData.nr_samples         = info.rawData.number_of_samples ;
    info.rawData.nr_channels        = single(max(acqs.head.active_channels));
    info.rawData.nr_phase_encodings = single(max(acqs.head.idx.kspace_encode_step_1)) + 1; % nr_interleaves for spiral imaging
    info.rawData.nr_slice_encodings = single(max(acqs.head.idx.kspace_encode_step_2)) + 1;
    info.rawData.nr_averages        = single(max(acqs.head.idx.average)) + 1;
    info.rawData.nr_slices          = single(max(acqs.head.idx.slice)) + 1; % imaging slice number
    info.rawData.nr_contrasts       = single(max(acqs.head.idx.contrast)) + 1; % echo number in multi-echo
    info.rawData.nr_phases          = single(max(acqs.head.idx.phase)) + 1; % cardiac phase
    info.rawData.nr_repetitions    = single(max(acqs.head.idx.repetition)) + 1; % dynamic number for dynamic scanning
    info.rawData.nr_sets            = single(max(acqs.head.idx.set)) + 1; % flow encoding set
    info.rawData.nr_segments        = single(max(acqs.head.idx.segment)) + 1; % for TSE this is the number of echos acquired in each TR 
    info.rawData.trajectory_dimensions = single(max(acqs.head.trajectory_dimensions)); % Get the dimensionality of the trajectory vector (0 means no trajectory)
   
    
    
    % Initialize kspace:
    
        kdata = complex(zeros(info.rawData.nr_samples, info.rawData.nr_phase_encodings, info.rawData.nr_slice_encodings,...
        info.rawData.nr_averages, info.rawData.nr_slices, info.rawData.nr_contrasts, info.rawData.nr_phases,...
        info.rawData.nr_repetitions, info.rawData.nr_sets, info.rawData.nr_segments, info.rawData.nr_channels, 'double'));
    
    
    % Fill Kspace
      
    info.rawData.nr_profiles = length(acqs.data);
    
    for idx = 1:info.rawData.nr_profiles
        % ---- Get information about the current profile ----
        phase_encoding_nr = single(acqs.head.idx.kspace_encode_step_1(idx)) + 1;
        slice_encoding_nr = single(acqs.head.idx.kspace_encode_step_2(idx)) + 1;
        average_nr        = single(acqs.head.idx.average(idx)) + 1;
        slice_nr          = single(acqs.head.idx.slice(idx)) + 1;
        contrast_nr       = single(acqs.head.idx.contrast(idx)) + 1;
        phase_nr          = single(acqs.head.idx.phase(idx)) + 1;
        repetition_nr     = single(acqs.head.idx.repetition(idx)) + 1;
        set_nr            = single(acqs.head.idx.set(idx)) + 1;
        segment_nr        = single(acqs.head.idx.segment(idx)) + 1;
        
        % ---- Set the index range of a profile ----
        number_of_samples = single(acqs.head.number_of_samples(idx));
        discard_pre       = single(acqs.head.discard_pre(idx));
        discard_post      = single(acqs.head.discard_post(idx));
        start_index       = discard_pre + 1;
        end_index         = number_of_samples - discard_post;
        index_range       = (start_index:end_index).';
        
    
        
        % ---- Get k-space data ----
        full_profile = acqs.data{idx}; % number_of_samples x nr_channels
        kdata(index_range, phase_encoding_nr, slice_encoding_nr, average_nr, slice_nr,...
            contrast_nr, phase_nr, repetition_nr, set_nr, segment_nr, :) = full_profile(index_range,:); % nr_samples x nr_channels
    end
    
    %% concatenate K-space segments: (TSE)
    
    if flag.concatenate
    
    ESP = header.sequenceParameters.echo_spacing; %echo spacing 
    
    effectTE_idx = round(info.TE / ESP); % obtain center segment 
         
    seg_idx = 1:info.rawData.nr_segments; % array with segment numbers
         
    seg_idx = seg_idx(seg_idx~=effectTE_idx); %array with all segments except center
         
    temp_kdata = sum(kdata(:, :, :, :, :, :, :, :, :,seg_idx, :), 10);  % concatenate segments, except center segment 
         
    temp_kdata(:, acqs.head.idx.kspace_encode_step_1(1) + 1,:,:,:,:,:,:,:,:,:) = 0; % set middle line to zero 
          
    temp_kdata = temp_kdata + kdata(:, :, :, :, :, :, :, :, :,effectTE_idx, :); % add center segment 
    
    kdata = temp_kdata;
    
    kdata = squeeze(kdata);
    %temp_kdata(:, acq.head.idx.kspace_encode_step_1(1) + 1, :, :, :, :, :, :, :,:, :) = 0 ; % set center line to zero 
          
    %temp_kdata(:, 35, :, :, :, :, :, :, :,:, :) = data(:, 35, :, :, :, :, :, :, :,17, :); % subst with center line of last segment 
    else
        
        kdata = squeeze(kdata); 
        
    end
         
    
  
       
    
    
    
end 