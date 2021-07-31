function trial = cartesian2GeneralizedTorques(model,trial,options)

% currently works with RLB1 model

% INPUTS
% model - nms model struct
% trial - nms trial struct
% options - options struct
%   (1) options.coordinateSystem: cs in which to expresse kinetic variables
%   (2) options.side: 'right' or 'left'
%   (3) options.analysisName: name given to inv kin analysis

% updates torques for ankle flexion/adduction, knee flexion, and
% hip flexion/adduction/internalRotation (e.g. trial.joint.hip.flexion.torque)

% the coordinateSystem option should correspond to the frame in which the
% inverse dynamics have been computed for each segment (ie distal/proximal
% reaction forces/joint torques), e.g.
% segment.foot.(cs).proximalReactionForce

% algorithm:
%   (1) express proximal joint torque in world frame for each segment
%   (2) get the rotation axis in the world frame
%   (3) project joint torque onto rotation axis

cs = options.coordinateSystem;
side = options.side;
anl = options.analysisName;

% unpack
foot = trial.(anl).body.segment.([side '_foot']);
mfoot = model.segment.([side '_foot']);
shank = trial.(anl).body.segment.([side '_shank']);
mshank = model.segment.([side '_shank']);
thigh = trial.(anl).body.segment.([side '_thigh']);
mthigh = model.segment.([side '_thigh']);
pelvis = trial.(anl).body.segment.pelvis;
mpelvis = model.segment.pelvis;
ankle = trial.(anl).body.joint.([side '_ankle']);
mankle = model.joint.([side '_ankle']);
knee = trial.(anl).body.joint.([side '_knee']);
mknee = model.joint.([side '_knee']);
hip = trial.(anl).body.joint.([side '_hip']);
mhip = model.joint.([side '_hip']);

%% ankle joint torques

% foot proximal joint torque is ankle joint torque, get in world frame
ankle_torque_world = qrot(foot.(cs).orientation,foot.(cs).proximalJointTorque);

% ankle flexion axis is fixed in the shank frame, get in world frame
ankle_flexion_axis_shank = qrot(mshank.(cs).orientation,mankle.flexion.axis,'inverse'); % ankle flexion axis in shank (cs) frame is constant
ankle_flexion_axis_world = qrot(shank.(cs).orientation,ankle_flexion_axis_shank); % now rotate from shank (cs) frame to world frame

% ankle adduction axis is fixed in the foot frame, get in world frame
ankle_adduction_axis_foot = qrot(mfoot.(cs).orientation,mankle.adduction.axis,'inverse'); % ankle adduction axis in foot (cs) frame is constant since only 2 dof
ankle_adduction_axis_world = qrot(foot.(cs).orientation,ankle_adduction_axis_foot); % now rotate from foot (cs) frame to world frame

% scalars for proper signage
flexion_scalar = mankle.torqueTransform{strcmp(mankle.rotationName,'flexion')};
adduction_scalar = mankle.torqueTransform{strcmp(mankle.rotationName,'adduction')};

% project torque onto flexion/adduction axes
ankle.flexion.torque = flexion_scalar * dot(ankle_flexion_axis_world,ankle_torque_world);
ankle.adduction.torque = adduction_scalar * dot(ankle_adduction_axis_world,ankle_torque_world);

%% knee joint torque

% shank proximal joint torque is knee joint torque, get in world frame
knee_torque_world = qrot(shank.(cs).orientation,shank.(cs).proximalJointTorque);

% get the flexion axis in the world frame
knee_flexion_axis_thigh = qrot(mthigh.(cs).orientation,mknee.flexion.axis,'inverse'); % knee flexion axis in thigh (cs) frame is constant
knee_flexion_axis_world = qrot(thigh.(cs).orientation,knee_flexion_axis_thigh); % now rotate from thigh (cs) frame to world frame

% scalars for proper signage
flexion_scalar = mknee.torqueTransform{strcmp(mknee.rotationName,'flexion')};

% project torque onto flexion axis
knee.flexion.torque = flexion_scalar * dot(knee_flexion_axis_world,knee_torque_world);

%% hip joint torque

% thigh proximal joint torque is hip joint torque, get in world frame
hip_torque_world = qrot(thigh.(cs).orientation,thigh.(cs).proximalJointTorque);

% hip flexion axis is fixed in pelvis frame, get in world frame
hip_flexion_axis_pelvis = qrot(mpelvis.(cs).orientation,mhip.flexion.axis,'inverse'); % hip flexion axis in pelvis (cs) frame is constant
hip_flexion_axis_world = qrot(pelvis.(cs).orientation,hip_flexion_axis_pelvis); % now rotate from pelvis (cs) frame to world frame

% hip adduction axis instantaneously corresponds with the rotation of the
% hip adduction axis in the pelvis frame from the reference configuration
% taken through the first rotational dof (in this case hip flexion)
hip_adduction_axis_pelvis = qrot(mpelvis.(cs).orientation,mhip.adduction.axis,'inverse');
hip_adduction_axis_world = qrot(pelvis.(cs).orientation,hip_adduction_axis_pelvis);
q = normalize([hip_flexion_axis_world .* sind(hip.flexion.angle/2); cosd(hip.flexion.angle/2)],1,'norm');
hip_adduction_axis_world = qrot(q,hip_adduction_axis_world);

% hip internal rotation axis is fixed in thigh frame, get in world frame
hip_internalRotation_axis_thigh = qrot(mthigh.(cs).orientation,mhip.internalRotation.axis,'inverse'); % hip internalRotation axis in thigh (cs) frame is constant (since corresponds with last euler rotation)
hip_internalRotation_axis_world = qrot(thigh.(cs).orientation,hip_internalRotation_axis_thigh); % now rotate from thigh (cs) frame to world frame

% scalars for proper signage
flexion_scalar = mhip.torqueTransform{strcmp(mhip.rotationName,'flexion')};
adduction_scalar = mhip.torqueTransform{strcmp(mhip.rotationName,'adduction')};
internalRotation_scalar = mhip.torqueTransform{strcmp(mhip.rotationName,'internalRotation')};

% project torque onto flexion axis
hip.flexion.torque = flexion_scalar * dot(hip_flexion_axis_world,hip_torque_world);
hip.adduction.torque = adduction_scalar * dot(hip_adduction_axis_world,hip_torque_world);
hip.internalRotation.torque = internalRotation_scalar * dot(hip_internalRotation_axis_world,hip_torque_world);

%% save

trial.(anl).body.joint.([side '_ankle']) = ankle;
trial.(anl).body.joint.([side '_knee']) = knee;
trial.(anl).body.joint.([side '_hip']) = hip;

end