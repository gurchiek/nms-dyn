function trial = analyzeMovement(model,trial,session,con,unc)

% function used in inverse_dynamics_marker

% unpack
dataImport = session.dataImport;

% marker/forcePlate import options
mkrOptions = dataImport.marker.options;
fpOptions = dataImport.forcePlate.options;

% import trc
fprintf('-importing marker data: %s\n',trial.trialName)
mkrOptions.markerNames = model.markerNames;
mkrOptions.trialName = trial.trialName;
mkrOptions.renameTrials = {trial.trialName,'trial'};
data = dataImport.marker.importer(mkrOptions);

% combined fields
trial = inherit(data.trial.trial,trial,{'samplingFrequency','nMarkers','markerNames','marker','deletedMarkers','missingData'});

% add fields where name being changed
trial.markerTime = data.trial.trial.time;
trial.nMarkerFrames = data.trial.trial.nFrames;

% import forcePlate
fprintf('-importing force plate data: %s\n',trial.trialName)
fpOptions.trialName = mkrOptions.trialName;
fpOptions.renameTrials = mkrOptions.renameTrials;
data = dataImport.forcePlate.importer(fpOptions);
trial.nForcePlates = data.trial.trial.nForcePlates;
trial.forcePlate = data.trial.trial.forcePlate(trial.useForcePlates);
trial.forcePlateTime = data.trial.trial.time;
trial.nForcePlateSamples = data.trial.trial.nSamples;

% constrained inverse kinematics
fprintf('-constrained inverse kinematics')
tic
trial = conInverseKinematics(model,trial,struct('coordinateSystem','mechanical','constrainedAnalysisName',con,'unconstrainedAnalysisName',unc,'lowPassCutoff',session.kinematicLowPassCutoff));
trial.(con).body.optimizationTime = toc;
fprintf(' (optimization time: %f seconds)\n',trial.(con).body.optimizationTime);

% convert generalized coords/velocities/accelerations to joint angles,
% segment positions/orientations and translational/rotational
% velocities/accelerations for the mechanical frame
trial.(con).body = generalizedCoordinates2MultibodySystem(model,trial.(con).body,struct('coordinateSystem','mechanical','lowPassCutoff',session.kinematicLowPassCutoff,'samplingFrequency',trial.samplingFrequency));

% transform mechanical frame kinematics to principal frame for inverse
% dynamics and anatomical frame for mtu kinematics
trial.(con).body = coordinateTransformation(model,trial.(con).body,'mechanical','principal');
trial.(con).body = coordinateTransformation(model,trial.(con).body,'mechanical','anatomical');

% patellar kinematics are completely dependent on all other segments
% update patella/patellar ligament kinematics here
trial.(con).body = patellaModel(model,trial.(con).body,'right');

% global body contour geometry
% updates global condylar axis and position
trial.(con).body = getGlobalBodyContourGeometry(model,trial.(con).body,'right_femoralCondyle','anatomical');

% global muscle geometry
% updates global mtu origin/insertions (average and element wise), mtu via
% points, and mtu lengths
trial.(con).body = getGlobalMuscleGeometry(model,'anatomical',trial.(con).body);

% get knee/ankle flexion moment arm
trial.(con).body = getKneeFlexionMomentArm5(model,trial.(con).body,'right');
trial.(con).body = getAnkleFlexionMomentArm5(model,trial.(con).body,'right');

% get mtu velocity
trial.(con).body = getVelocityMTU(trial.(con).body,struct('samplingFrequency',trial.samplingFrequency,'lowPassCutoff',session.kinematicLowPassCutoff));

% gait events
if strcmp(trial.task,'gait')
    fprintf('-gait events\n')
    trial = getMocapGaitEvents(trial,struct('grfThreshold',20,'analysisName',con,'side','right'));
end

% inverse dynamics
fprintf('-inverse dynamics\n')
trial = newtonEulerInverseDynamics(model,trial,struct('coordinateSystem','principal','side','right','analysisName',con,'gravitationalAcceleration',session.gravitationalAcceleration));

% newtonEulerInverseDynamics computes segment dynamics (reaction forces and
% joint torques) in cartesian coordinates expressed in each segment's frame
% now convert to torque associated with specific joint dofs
trial = cartesian2GeneralizedTorques(model,trial,struct('coordinateSystem','principal','side','right','analysisName',con));

% low pass filter knee joint moment at same cutoff used for kinematics
% filtering (per Edwards et al., 2011, On the filtering of intersegmental
% loads during running)
trial.(con).body.joint.right_knee.flexion.torque = bwfilt(trial.(con).body.joint.right_knee.flexion.torque,session.kinematicLowPassCutoff,trial.samplingFrequency,'low',4);

end