function model = RLB1()

% RLB1: right lower body model 1, generic segment joint model

% model structure: model.segment.(segmentName), model.joint.(jointName)

% required segment specs: index (int), parent.segment (char), parent.joint (char),
% child(k).segment (char), child(k).joint (char), markerNames (cell of
% chars), markerTrustValue (double array), accelerometerNames (cell of
% chars), gyroscopeNames (cell of chars), magnetometerNames (cell of
% chars), barometerNames (cell of chars)

% required joint specs: index (int), parent.joint (char), parent.segment
% (char), child.segment (char), child(k).joint (char), rotationDOF (1,2, or
% 3), type (char), rotationName (cell of chars, one for each rotationDOF),
% rotationTransform (cell)

% the global parent segment should be index 1. The parent joint for all
% joints connected to the parent segment is empty []. Parents are proximal
% and children are distal. The parent segment will have empty
% parent.segment and parent.joint. All most distal joints will have empty
% child joints. All most distal segments will have empty child.segment and
% child.joint

% all models must end with completeSegmentJointModel(model)

%% RLB1

fprintf('-initializing model\n')
model.name = 'RLB1';

%% segments/joints/markers

% pelvis
model.segment.pelvis.index = 1; % global parent segment
model.segment.pelvis.parent = struct('segment',[],'joint',[]); % all empty since has no parent (pelvis is global parent)
model.segment.pelvis.child(1) = struct('segment','right_thigh','joint','right_hip'); % generally can have multiple (e.g. if right and left thigh then both would be children)
model.segment.pelvis.markerNames = {'right_asis','left_asis','right_psis','left_psis'};
model.segment.pelvis.markerTrustValue = [1 1 1 1];
model.segment.pelvis.accelerometerNames = cell(0);
model.segment.pelvis.gyroscopeNames = cell(0);
model.segment.pelvis.magnetometerNames = cell(0);
model.segment.pelvis.barometerNames = cell(0);

% right hip
model.joint.right_hip.index = 1;
model.joint.right_hip.parent.joint = []; % all joints have a single parent joint that trace back to the global parent segment
model.joint.right_hip.parent.segment = 'pelvis'; % each joint has only one parent segment (proximal segment)
model.joint.right_hip.child.segment = 'right_thigh'; % each joint has only one child segment (distal segment)
model.joint.right_hip.child(1).joint = 'right_knee'; % could have multiple (all child joints for this joint's child segment)
model.joint.right_hip.rotationDOF = 3; % num rotational degrees of freedom 3, 2, or 1
model.joint.right_hip.type = 'ball'; % 'ball' if 3 dof, 'universal' if 2 dof, 'hinge' or 'revolute' if 1 dof
model.joint.right_hip.rotationSequence = 'zxy'; % this one does not lead to singularity in large flexions during squatting task and in line with ISB rec whereas 'yzx' is similar to how some describe shoulder rotations but will lead to discontinuity for large flexion angles like during squat
model.joint.right_hip.rotationPerspective = 'parent2child'; % e.g. imagine aligning joint by rotating the parent onto the child
model.joint.right_hip.rotationName = {'flexion','adduction','internalRotation'};
model.joint.right_hip.rotationTransform = {1,1,1}; % scalar applied to euler angle in order to indicate the desired direction (+/-) and to corresponds with the associated rotationName
model.joint.right_hip.torqueTransform = {1,1,1}; % if use axes and names as listed above then transform to correspond with same name when projecting torque onto these axes
model.joint.right_hip.rotationLowerBound = {-pi/2,-pi/2,-pi}; % rotationLowerBound and rotationUpperBound are currently not enforced
model.joint.right_hip.rotationUpperBound = {pi/2,pi/2,pi};

% right thigh
model.segment.right_thigh.index = 2;
model.segment.right_thigh.parent = struct('segment','pelvis','joint','right_hip');
model.segment.right_thigh.child(1) = struct('segment','right_shank','joint','right_knee');
model.segment.right_thigh.markerNames = {'right_lat_femoral_epicondyle','right_med_femoral_epicondyle','right_anterior_thigh15','right_anterior_thigh25','right_anterior_thigh50',...
                                    'right_lateral_thigh25','right_lateral_thigh50','right_trochanter','right_thigh_cluster1','right_thigh_cluster2','right_thigh_cluster3'};
model.segment.right_thigh.markerTrustValue = [1 1 1 1 1 1 1 1 1 1 1];
model.segment.right_thigh.accelerometerNames = {'anterior_thigh_right'};
model.segment.right_thigh.gyroscopeNames = {'anterior_thigh_right'};
model.segment.right_thigh.magnetometerNames = cell(0);
model.segment.right_thigh.barometerNames = cell(0);

% right knee
model.joint.right_knee.index = 2;
model.joint.right_knee.parent.joint = 'right_hip';
model.joint.right_knee.parent.segment = 'right_thigh';
model.joint.right_knee.child.segment = 'right_shank';
model.joint.right_knee.child(1).joint = 'right_ankle';
model.joint.right_knee.rotationDOF = 1;
model.joint.right_knee.type = 'hinge';
model.joint.right_knee.rotationSequence = 'z';
model.joint.right_knee.rotationPerspective = 'child2parent';
model.joint.right_knee.rotationName = {'flexion'};
model.joint.right_knee.rotationTransform = {1};
model.joint.right_knee.torqueTransform = {-1}; % using this formulation, the flexion axis is the z axis of the child (shank) so that the euler angle decomposition yields the flexion angle, but this is actually the extension torque axis (so negate here)
model.joint.right_knee.rotationLowerBound = {-15*pi/180};
model.joint.right_knee.rotationUpperBound = {3*pi/4};
                           
% right shank
model.segment.right_shank.index = 3;
model.segment.right_shank.parent = struct('segment','right_thigh','joint','right_knee');
model.segment.right_shank.child(1) = struct('segment','right_foot','joint','right_ankle');
model.segment.right_shank.markerNames = {'right_fibular_head','right_tibial_tuberosity','right_lateral_distal_shank','right_anterior_shank30','right_lateral_malleolus','right_medial_malleolus',...
                                    'right_medial_tibial_condyle','right_lateral_tibial_condyle','right_shank_cluster1','right_shank_cluster2','right_shank_cluster3'};
model.segment.right_shank.markerTrustValue = [1 1 1 1 1 1 1 1 1 1 1];
model.segment.right_shank.accelerometerNames = {'distal_lateral_shank_right'};
model.segment.right_shank.gyroscopeNames = {'distal_lateral_shank_right'};
model.segment.right_shank.magnetometerNames = cell(0);
model.segment.right_shank.barometerNames = cell(0);

% right ankle
model.joint.right_ankle.index = 3;
model.joint.right_ankle.parent.joint = 'right_knee';
model.joint.right_ankle.parent.segment = 'right_shank';
model.joint.right_ankle.child.segment = 'right_foot';
model.joint.right_ankle.child(1).joint = [];
model.joint.right_ankle.rotationDOF = 2;
model.joint.right_ankle.type = 'universal';
model.joint.right_ankle.rotationSequence = 'zx';
model.joint.right_ankle.rotationPerspective = 'parent2child';
model.joint.right_ankle.rotationName = {'flexion','adduction'};
model.joint.right_ankle.rotationTransform = {1,1};
model.joint.right_ankle.torqueTransform = {1,1};
model.joint.right_ankle.rotationLowerBound = {-pi/2,-pi/2};
model.joint.right_ankle.rotationUpperBound = {pi/2,pi/2};

% right foot
model.segment.right_foot.index = 4;
model.segment.right_foot.parent = struct('segment','right_shank','joint','right_ankle');
model.segment.right_foot.child = struct('segment',[],'joint',[]);
model.segment.right_foot.markerNames = {'right_heel','right_metatarsal2','right_metatarsal5','right_metatarsal1','right_foot_cluster1','right_foot_cluster2','right_foot_cluster3','right_toe_tip'};
model.segment.right_foot.markerTrustValue = [1 1 1 1 1 1 1 1];
model.segment.right_foot.accelerometerNames = cell(0);
model.segment.right_foot.gyroscopeNames = cell(0);
model.segment.right_foot.magnetometerNames = cell(0);
model.segment.right_foot.barometerNames = cell(0);

% complete
model = completeSegmentJointModel(model);

end