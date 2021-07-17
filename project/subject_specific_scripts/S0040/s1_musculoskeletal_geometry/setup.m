function session = setup()

% the setup file should set up logistical/organizational items related to
% all possible scripts for a given analysis pipeline. This information is
% stored in the session struct

% preliminary information on all trials to be imported is stored in the
% trial struct

% this includes, for example, subject details (ID, sex, where to store
% results), gravitationalAcceleration for all analyses, trials, to be
% analyzed, marker importer and options, force plate importer and options,
% emg/accelerometer/gyroscope importer and options

% name session and date
session.name = 'nmsdyn_exampleProject';
session.date = date;

% subject details
session.subject.ID = 'S0040';
session.subject.sex = 'female'; % male/female
session.subject.height = 1.7526; % meters
session.subject.resultsDirectory = replace(cd,fullfile('s1_musculoskeletal_geometry'),''); % THIS ASSUMES ALL PROJECT SCRIPTS ARE WITHIN THEIR OWN FOLDER AND EACH FOLDER IS WITHIN THE RESULTS DIRECTORY
session.subject.resultsName = ['nmsdyn_' session.subject.ID '.mat'];

% some global analysis settings
session.gravitationalAcceleration = 9.81;
session.kinematicLowPassCutoff = 6;  % Hz

% specify trials to analyze: overground walk 1
session.trial.walk_1.trialName = 'Force Plate Walk 1';
session.trial.walk_1.useForcePlates = 1; % force plate number
session.trial.walk_1.task = 'gait';

% specify trials to analyze: overground walk 2
session.trial.walk_2.trialName = 'Force Plate Walk 2';
session.trial.walk_2.useForcePlates = 1; % force plate number
session.trial.walk_2.task = 'gait';

% specify trials to analyze: overground walk 3
session.trial.walk_3.trialName = 'Force Plate Walk 3';
session.trial.walk_3.useForcePlates = 1; % force plate number
session.trial.walk_3.task = 'gait';

% specify trials to analyze: overground walk 4
session.trial.walk_4.trialName = 'Force Plate Walk 4';
session.trial.walk_4.useForcePlates = 1; % force plate number
session.trial.walk_4.task = 'gait';

% specify trials to analyze: overground walk 5
session.trial.walk_5.trialName = 'Force Plate Walk 5';
session.trial.walk_5.useForcePlates = 1; % force plate number
session.trial.walk_5.task = 'gait';

% specify trials to analyze: overground walk 6
session.trial.walk_6.trialName = 'Force Plate Walk 6';
session.trial.walk_6.useForcePlates = 1; % force plate number
session.trial.walk_6.task = 'gait';

% specify trials to analyze: overground walk 7
session.trial.walk_7.trialName = 'Force Plate Walk 7';
session.trial.walk_7.useForcePlates = 1; % force plate number
session.trial.walk_7.task = 'gait';

% specify trials to analyze: overground walk 8
session.trial.walk_8.trialName = 'Force Plate Walk 8';
session.trial.walk_8.useForcePlates = 1; % force plate number
session.trial.walk_8.task = 'gait';

% specify trials to analyze: overground walk 9
session.trial.walk_9.trialName = 'Force Plate Walk 9';
session.trial.walk_9.useForcePlates = 1; % force plate number
session.trial.walk_9.task = 'gait';

% specify trials to analyze: overground walk 10
session.trial.walk_10.trialName = 'Force Plate Walk 10';
session.trial.walk_10.useForcePlates = 1; % force plate number
session.trial.walk_10.task = 'gait';

% specify marker importer and import options
session.dataImport.marker.importer = @importTRC;
session.dataImport.marker.options.directory = replace(cd,fullfile('subject_specific_scripts','S0040','s1_musculoskeletal_geometry'),fullfile('subject_data','S0040','VICON'));  % contains .trc files
session.dataImport.marker.options.renameMarkers = {0};
session.dataImport.marker.options.transferMatrix = {diag([-1 1 -1])};
session.dataImport.marker.options.lowPassCutoff = {0};
session.dataImport.marker.options.missingDataThreshold = {0};
session.dataImport.marker.options.deleteData = {'none'};
session.dataImport.marker.options.newStartTime = {0};
session.dataImport.marker.options.newEndTime = {inf};
session.dataImport.marker.options.resample = {100};
session.dataImport.marker.options.reportStatus = {0};

% specify force plate data importer and import options
session.dataImport.forcePlate.importer = @importMOT;
session.dataImport.forcePlate.options.directory = replace(cd,fullfile('subject_specific_scripts','S0040','s1_musculoskeletal_geometry'),fullfile('subject_data','S0040','AMTI'));  % contains .mot files
session.dataImport.forcePlate.options.transferMatrix = diag([-1 1 -1]);
session.dataImport.forcePlate.options.newStartTime = {0};
session.dataImport.forcePlate.options.newEndTime = {inf};
session.dataImport.forcePlate.options.resample = {100}; % must match marker sf
session.dataImport.forcePlate.options.lowPassCutoff = {0};

% specify emg data importer and import options
session.dataImport.emg.importer = @importMC10x;
session.dataImport.emg.options.directory = replace(cd,fullfile('subject_specific_scripts','S0040','s1_musculoskeletal_geometry'),fullfile('subject_data','S0040','MC10'));  % contains .elec.csv files
session.dataImport.emg.options.sensors = {'elec'};
session.dataImport.emg.options.storeSameTrials = 'appendName';

% specify accelerometer data import and options
session.dataImport.accel.importer = @importMC10x;
session.dataImport.accel.options.directory = replace(cd,fullfile('subject_specific_scripts','S0040','s1_musculoskeletal_geometry'),fullfile('subject_data','S0040','MC10'));  % contains .accel.csv files
session.dataImport.accel.options.locations = {'anterior_thigh_right', 'distal_lateral_shank_right'};
session.dataImport.accel.options.trialNames = {'Static_Calibration','Star_Calibration','Force_Plate_Walk'};
session.dataImport.accel.options.renameTrials = horzcat(session.dataImport.accel.options.trialNames',{'static','star','walk'}');
session.dataImport.accel.options.sensors = {'accel'};
session.dataImport.accel.options.resample = 100;
session.dataImport.accel.options.storeSameTrials = 'appendName';

% specify gyroscope data import and options
session.dataImport.gyro.importer = @importMC10x;
session.dataImport.gyro.options.directory = replace(cd,fullfile('subject_specific_scripts','S0040','s1_musculoskeletal_geometry'),fullfile('subject_data','S0040','MC10')); % contains .gyro.csv files
session.dataImport.gyro.options.locations = {'anterior_thigh_right', 'distal_lateral_shank_right'};
session.dataImport.gyro.options.trialNames = {'Static_Calibration','Star_Calibration','Force_Plate_Walk'};
session.dataImport.gyro.options.renameTrials = horzcat(session.dataImport.accel.options.trialNames',{'static','star','walk'}');
session.dataImport.gyro.options.sensors = {'gyro'};
session.dataImport.gyro.options.resample = 100;
session.dataImport.gyro.options.storeSameTrials = 'appendName';

% specify APDM data import (for MC10 IMU + EMG synchronization) and options
session.dataImport.apdm.importer = @importAPDM;
session.dataImport.apdm.options.directory = replace(cd,fullfile('subject_specific_scripts','S0040','s1_musculoskeletal_geometry'),fullfile('subject_data','S0040','APDM','monitorData'));  % contain .h5 files
session.dataImport.apdm.options.locations = {'right_lower_leg'};
session.dataImport.apdm.options.renameLocations = {'right_lower_leg','right_shank'};

% trialnames here should match all those specified in session.trial.()
session.dataImport.apdm.options.trialNames = {'VICON_Force_Plate_Walk_1','VICON_Force_Plate_Walk_2','VICON_Force_Plate_Walk_3','VICON_Force_Plate_Walk_4','VICON_Force_Plate_Walk_5','VICON_Force_Plate_Walk_6','VICON_Force_Plate_Walk_7','VICON_Force_Plate_Walk_8','VICON_Force_Plate_Walk_9','VICON_Force_Plate_Walk_10'};
session.dataImport.apdm.options.renameTrials = {'*VICON_Force_Plate_Walk','walk'};
session.dataImport.apdm.options.sensors = {'gyro','accel'};
session.dataImport.apdm.options.resample = 100;
session.dataImport.apdm.options.storeSameTrials = 'appendName';

end