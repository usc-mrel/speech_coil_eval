

# Read me 
## _SNR Units recon_


### Functions

- **snr_recon_3d**: This demo file takes in 3D imaging data and noise information to reconstruct images in SNR units.

- **tse_2d_demo**: This demo file takes in 2D TSE data from a head coil and a body coil located in /tse_data. It calculates and displays the SNR maps for each coil, and displays the ratio.
 
- **data_speech_coil.mat**: This is the data used for the demo. It consists of kspace data from a 3D GRE sequence with the speech coil, noise measurements, and the     decorrelation matrix.

- **estimate_sensitivities.m**: Estimates the coil sensitivities for a 3D volume of kspace data using the Walsh method.

- **read_h5_data:** Reads kspace data in ISMRMRD format.

- **process_noise_ismrmrd_data:** Outputs decorrelation matrix and sorted noise data from pre-scan noise measurements.

- **read_raw_data:** sample script to read ismrmrd raw data.
