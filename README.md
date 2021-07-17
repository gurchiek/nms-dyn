# nms-dyn

Author: Reed Gurchiek

Contact: rgurchiek@gmail.com

Dependencies:

## Description

This toolbox provides MATLAB code for analyzing joint and muscle mechanics using only wearable sensors. We utilize a hybrid approach (referred to as IMC-GP) combining both physics-based simulation (IMU-driven musculoskeletal kinematics and EMG-driven muscle contraction dynamics) and machine learning (Gaussian process models of muscle synergy functions). More details about IMC-GP can be found in this [publication: Gurchiek et al. (2021)](https://www.biorxiv.org/content/10.1101/2021.06.16.448524v1). Details about Gaussian process models of muscle synergy functions can be found in this [publication: Gurchiek et al. (2020)](https://ieeexplore.ieee.org/document/9210846) and the [syner-gp toolbox](https://github.com/M-SenseResearchGroup/syner-gp).

Also included are tools for constrained and unconstrained inverse kinematics using marker-based optical motion capture (OMC), inverse dynamics using OMC and force plate data, and EMG-driven simulation of muscle contraction using OMC.

## Try it yourself

An example subject dataset is provided in the repository with a set of subject-specific scripts for processing those data within the scope of a specific project. Scripts and functions that are subject-general, but specific to this project are also included. This project was focused on characterizing the mechanics of the knee joint and the associated muscles using two IMUs and three surface electrodes (more details [here: Gurchiek et al. (2021)](https://www.biorxiv.org/content/10.1101/2021.06.16.448524v1)). Here are step-by-step instructions:

**A. Download:** download the nms-dyn package

**B. Download:** download the [GPML toolbox](http://www.gaussianprocess.org/gpml/code/matlab/doc/)

**C. Add path:** add the nms-dyn folder to the MATLAB path (with subfolders)

**D. Run the scripts:** each script lives within a script-specific folder uniquely written for the example subject. These folders are listed below for each step and can be found in nms-dyn/project/subject_specific_scripts/S0040.

* **Script 1: Calibrate MSK model:** navigate to script-specific folder s1_musculoskeletal_geometry. Run calibrate_musculoskeletal_geometry.m. When prompted to save, select 'Yes'.

* **Script 2: Inverse dynamics:** navigate to script-specific folder s2_inverse_dynamics. Run inverse_dynamics.m. When prompted to save, select 'Yes'.

* **Script 3: Inertial motion capture:** navigate to script-specific folder s3_inertial_motion_capture. Run forward_kinematics_imu.m. When prompted to save, select 'Yes'.

* **Script 4: Hill model calibration:** navigate to script-specific folder s4_mtu_parameter_identification.

  * Option 1 (not recommended): run optimize_mtu_parameters_s1a5.m. This runs the Bayesian optimization routine and can take a long time. However, this has already been done for you. To use the precalibrated model see option 2.
  
  * Option 2 (recommended): run update_model_shortcut.m.
  
* **Script 5: OMC-Full:** navigate to script-specific folder s5_omc_full. Run forward_dynamics_omc_fullemg.m. When prompted to save, select 'Yes'.

* **Script 6: IMC-GP:** navigate to script-specific folder s6_imc_gp. Run forward_dynamics_imu_synergp_3muscle.m. When prompted, select the GPML folder (from step B). When prompted to save, select 'Yes'.

**E. Visualize results:** there are 4 visualization scripts included in script-specific folder s7_visualization.

  1. **Single frame visualization of MSK model:** run vis1_plot_body.m to visualize the musculoskeletal system configuration solved using inertial motion capture (from Script 3) at three different frames: foot contact, mid-stance, and foot off.

  2. **Create a gif:** run vis2_gif.m to create a gif of the inertial motion capture solution to the musculoskeletal system kinematics during the stance phase.

  3. **Compare IMC and OMC:** run vis3_imc_ensembling.m to visualize and compare ensemble average time-series of joint and MTU kinematics.

  4. **Compare kinetic variables:** run vis4_imcgp_ensembling.m to visualize and compare ensemble average time-series of joint and muscle kinetic variables including joint moment, individual muscle moment, muscle fiber power, and muscle fiber force.
