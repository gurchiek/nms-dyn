%% SCRIPT 1: calibrate musculoskeletal geometry
% this script calibrates a musculoskeletal model for an individual based on
% static calibration marker and force plate data as well as marker data 
% during a functional (star) calibration trial

% also calibrates sensor to segment alignment and imports emg/imu data for
% all trials to be analyzed

% a generic rigid body model (RLB1) is first loaded from which it is
% calibrated.

clear; close all; clc;

% initialize session
session = setup();

% specify static calibration options
staticOptions.trialName = 'Static Calibration'; % .trc filename and .mot filename for static pose trial
staticOptions.useForcePlates = 1;
staticOptions.gravitationalAcceleration = session.gravitationalAcceleration;
staticOptions.nStaticSamples = 50; % at 100 Hz 50 corresponds to 0.5 seconds

% specify functional (star) calibration options
starOptions.trialName = 'Star Calibration';
starOptions.indices = struct();

% NOTE: these indices have already been identified. If a new star
% calibration trial is loaded for which these indices are not known, simply
% uncomment lines 30-32 and run. This will alow you to find the indices
% manually
starOptions.indices.right_hip = 333:1519;
starOptions.indices.right_knee = 1513:2189;
starOptions.indices.right_ankle = 2220:3602;
starOptions.side = 'right';
starOptions.coordinateSystem = 'isb'; % uncInverseKinematics option
starOptions.analysisName = 'unconstrained'; % uncInverseKinematics option
starOptions.lowPassCutoff = session.kinematicLowPassCutoff; % uncInverseKinematics option

% specify emg calibration and options
emgCalibration.calibrator = @calibrateEMG;
emgCalibration.options.locations = {'lateral_gastrocnemius_right', 'biceps_femoris_right','rectus_femoris_right', 'medial_gastrocnemius_right', 'vastus_medialis_right', 'vastus_lateralis_right', 'semitendinosus_right'};
emgCalibration.options.trialNames = {'*Max_Voluntary_Contraction*','Static_Calibration','Star_Calibration','Force_Plate_Walk','Calf_Raises','Air_Squats','Treadmill_Walk_Slow','Treadmill_Walk_Normal','Treadmill_Walk_Fast','Treadmill_Run_Slow','Treadmill_Run_Comfortable','Treadmill_Run_Fast'};
emgCalibration.options.renameTrials = horzcat(emgCalibration.options.trialNames',{'MVC','static','star','walk','raises','squats','treadmillWalkSlow','treadmillWalkNormal','treadmillWalkFast','treadmillRunSlow','treadmillRunNormal','treadmillRunFast'}');
emgCalibration.options.resample = 'mc10';
emgCalibration.options.processor = @emgamp1;
emgCalibration.options.processorOptions.method = 'butter';
emgCalibration.options.processorOptions.highCutoff = 30;
emgCalibration.options.processorOptions.highOrder = 4;
emgCalibration.options.processorOptions.lowCutoff = 6;
emgCalibration.options.processorOptions.lowOrder = 4;
emgCalibration.options.downsample = 100;

% specify imu (accel + gyro) calibration and options
imuCalibration.calibrator = @calibrateIMU;
imuCalibration.options.trialName = {'Static_Calibration','Star_Calibration','Force_Plate_Walk'};
imuCalibration.options.renameTrial = {'Static_Calibration','static';'Star_Calibration','star';'Force_Plate_Walk','walk'};
imuCalibration.options.storeSameTrials = 'appendName';
imuCalibration.options.resample = 100;
imuCalibration.options.nStillSeconds = 0.5;

%% initialize rigid body model

% right lower body version 1 model
model = RLB1();

% specify sex
model.sex = session.subject.sex;

% store calibration name, date, and some details
model.musculoskeletalGeometryCalibration.script = fullfile(session.subject.resultsDirectory,'s1_musculoskeletal_geometry','calibrate_musculoskeletal_geometry.m');
model.musculoskeletalGeometryCalibration.date = datetime;
model.musculoskeletalGeometryCalibration.staticOptions = staticOptions;
model.musculoskeletalGeometryCalibration.starOptions = starOptions;
model.musculoskeletalGeometryCalibration.emgCalibration = emgCalibration;
model.musculoskeletalGeometryCalibration.imuCalibration = imuCalibration;

%% static calibration

% generic marker import and force plate importer information
dataImport = session.dataImport;

% set up options for marker import for static calibration
markerOptions = dataImport.marker.options;
markerOptions.markerNames = model.markerNames;
markerOptions.trialName = staticOptions.trialName;
markerOptions.renameTrials = {staticOptions.trialName,'static'}; % rename static

% import marker data during static trial
fprintf('-importing marker data: %s\n',staticOptions.trialName)
tic
data = dataImport.marker.importer(markerOptions);
fprintf('-import time: %f s\n',toc)

% store static trial data in static struct
static = data.trial.static;

% set up options for force plate data import for static calibration
forcePlateOptions = dataImport.forcePlate.options;
forcePlateOptions.trialName = staticOptions.trialName; % import same static trial as for marker import
forcePlateOptions.renameTrials = {staticOptions.trialName,'static'}; % rename static

% import force plate data for static calibration
fprintf('-importing force plate data: %s',staticOptions.trialName)
tic
data = dataImport.forcePlate.importer(forcePlateOptions);
fprintf(' (import time: %f s)\n',toc)

% store force plate data in static struct
static.forcePlate = data.trial.static.forcePlate;
model.calibrationData.trials.static = static;

% static calibration
% assigns marker positions in reference configuration, body weight and body mass
fprintf('-static calibration\n')
model = staticCalibration(model,static,staticOptions);

% plan next is to perform a functional calibration (starCalibration) to
% determine hip, knee, ankle joint centers and knee flexion axis (pointing
% right)
% so construct isb coordinate system
csOptions.side = 'right';
csOptions.hipJointCenterRegressor = 'hara';
model = isbLowerBodyCoordinateSystem(model,csOptions); % isb frame + some anthropometry

%% functional (star) calibration

% set up options for marker import for star calibration
sf = markerOptions.resample{1};
markerOptions.trialName = starOptions.trialName;
markerOptions.renameTrials = {starOptions.trialName,'star'};
if isfield(starOptions.indices,'right_hip')
    markerOptions.newStartTime = {(starOptions.indices.right_hip(1))/sf}; % no need to read data before hip calibration indices
end
if isfield(starOptions.indices,'right_ankle')
    markerOptions.newEndTime = {(starOptions.indices.right_ankle(end))/sf}; % no need to read data after ankle calibration indices
end

% since changed start/end time, adjust calibration indices
if all(isfield(starOptions.indices,{'right_hip','right_ankle','right_knee'}))
    starOptions.indices.right_ankle = starOptions.indices.right_ankle - starOptions.indices.right_hip(1) + 1;
    starOptions.indices.right_knee = starOptions.indices.right_knee - starOptions.indices.right_hip(1) + 1;
    starOptions.indices.right_hip = starOptions.indices.right_hip - starOptions.indices.right_hip(1) + 1;
end

% import marker data for star calibration trial
fprintf('-importing %s.trc\n',starOptions.trialName)
tic
data = dataImport.marker.importer(markerOptions);
fprintf('-import time: %f s\n',toc)
star = data.trial.star;
model.calibrationData.trials.star = star;

% solve unconstrained inverse kinematics
fprintf('-star trial unconstrained inverse kinematics\n')
tic
star = uncInverseKinematics(model,star,starOptions);
fprintf('-unconstrained inverse kinematics processing time: %f s\n',toc)

% star calibration
fprintf('-star calibration\n')
tic
model = starCalibration(model,star,starOptions);
fprintf('-star calibration processing time: %f s\n',toc)

% now re configure isb coordinate system now that functional joint centers
% specified and get other coordinate systems
model = isbLowerBodyCoordinateSystem(model,csOptions);
model = principalCoordinateSystem(model,csOptions); % principal inertia frame, some other inertial/anthropometric params
model = mechanicalCoordinateSystem(model,csOptions); % consistent with RLB1 mechanical constraints, this needed to get ankle joint in/eversion axis
model = anatomicalCoordinateSystem(model,csOptions); % compatible with horsman et al. 2007 mtu origins/insertions

% transform diagonal inertia matrix in principal frame to other frames
model = transformInertiaMatrix(model,'isb');
model = transformInertiaMatrix(model,'mechanical');
model = transformInertiaMatrix(model,'anatomical');

%% characterize mechanical joints

side = starOptions.side;

% hip joint axes: flexion, adduction, internalRotation must all be
% specified as per the RLB1 model
model.joint.([side '_hip']).flexion.axis = model.segment.pelvis.mechanical.basis(3).vector;
model.joint.([side '_hip']).adduction.axis = model.segment.pelvis.mechanical.basis(1).vector;
model.joint.([side '_hip']).internalRotation.axis = model.segment.pelvis.mechanical.basis(2).vector;

% knee joint axes: only the flexion axis need be specified as per the RLB1
% model. was already done in star calibration

% ankle joint axes: flexion axis is same as knee flexion axis (shank z
% pointing right) in static pose and adduction axis is the first basis in
% the mechanical coordinate system (see mechanicalCoordinateSystem for
% details)
model.joint.([side '_ankle']).flexion.axis = model.joint.([side '_knee']).flexion.axis;
model.joint.([side '_ankle']).adduction.axis = model.segment.([side '_foot']).mechanical.basis(1).vector;

% knee joint angle
model.joint.([side '_knee']).flexion.angle = 0;

% ankle joint angles
qf = model.segment.([side '_foot']).mechanical.orientation; % has AP axis as 2nd rotation axis (talocrural), not long axis of foot
qf2 = model.segment.([side '_foot']).isb.orientation;
qs = model.segment.([side '_shank']).mechanical.orientation;
qa = qprod(qconj(qs),qf);
qa2 = qprod(qconj(qs),qf2);
model.joint.([side '_ankle']).flexion.angle = asind(2 * qa(1,:) .* qa(2,:) + 2 * qa(3,:) .* qa(4,:)) - asind(2 * qa2(1,:) .* qa2(2,:) + 2 * qa2(3,:) .* qa2(4,:));
model.joint.([side '_ankle']).adduction.angle = asind(2 * qa(2,:) .* qa(3,:) + 2 * qa(1,:) .* qa(4,:));

% report
fprintf('-Ankle dorsiflexion angle in static calibration (offset): %4.2f degrees\n',model.joint.([side '_ankle']).flexion.angle);
fprintf('-Ankle inversion angle in static calibration: %4.2f degrees\n',model.joint.([side '_ankle']).adduction.angle);

% get joint coordinate system for all frames
model = jointCoordinateSystem(model,{'isb','principal','mechanical','anatomical'});

% get local joint positions
model = getLocalJointPositions(model,'isb');
model = getLocalJointPositions(model,'principal');
model = getLocalJointPositions(model,'mechanical');
model = getLocalJointPositions(model,'anatomical');

%% muscles

% initialize muscle model: is a project specific function
fprintf('-initializing/scaling muscle model\n')
model = initializeMuscleModel(model); % adjust initializeMuscleModel to customize
 
%% calibrate sensors

% calibrate emg
% emg must come before calibrateIMU
fprintf('-calibrating emg\n')
[model,session] = emgCalibration.calibrator(model,session,emgCalibration.options); 

% calibrate imu
fprintf('-calibrating imu\n')
[model,session] = imuCalibration.calibrator(model,session,imuCalibration.options);

% sensor to segment calibration
% computes quaternions that take sensor to thigh/shank mechanical frames
% and location of knee joint relative to thigh/shank imus in mechanical
% frame
% is a project specific function
model = sensor2segment(model,session);

%% plot model

options.muscles = model.muscleNames;
options.showFibers = false;
options.markers = model.markerNames;
options.joints = model.jointNames;
options.segments = model.segmentNames;
plotBody(model,model,1,options);

beep

%% save

ok = questdlg('Save (will overwrite any existing)?','Save','Yes','No','Yes');
if ~isempty(ok)
    if ok(1) == 'Y'
        trial = session.trial;
        session = rmfield(session,'trial');
        clearvars -except model session trial
        session.musculoskeletal_geometry_calibration_date = datetime;
        save(fullfile(session.subject.resultsDirectory,session.subject.resultsName))
    end
end

beep
