

# Read me 
## _SNR Units recon_


### Functions

- **gre_3d_demo**: This is the main demo file. It takes in 3D GRE data for the speech, head, and body coils and performs an SNR recon for all coils. It then displays the SNR gain over the body coil for both, the speech and the head coil.

- **process_all_demo.m**: This demo file takes in data for 3 volunteers and it ouputs the snr gain for the speech and the head coil, for 3 subjects.

- **ratio_output.m**:This script outputs the snr gain for the speech and head coil.

- **snr_demo.m**: This demo file takes in speech coil 3D imaging data and noise information to reconstruct images in SNR units.

- **data_speech_coil.mat**: This is the data used by the snr_demo file. It consists of kspace data from a 3D GRE sequence with the speech coil, noise measurements, and the decorrelation matrix.

- **read_h5_data:** Reads kspace data in ISMRMRD format.
