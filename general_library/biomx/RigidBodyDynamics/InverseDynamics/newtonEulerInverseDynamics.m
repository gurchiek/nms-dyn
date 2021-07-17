function trial = newtonEulerInverseDynamics(model,trial,options)

% currently works only for half lower body working from the foot to the
% pelvis

% principal frame kinematics must be specified (origin of principal frame
% is segment center of mass)

% currently assumes forcePlateTime and markerTime are equivalent and thus
% nForcePlateSamples = nMarkerFrames

% INPUTS
% model - nms model struct
% trial - nms trial struct
% options - options struct
%   (1) options.coordinateSystem: cs in which to expresse kinetic variables
%   (2) options.side: 'right' or 'left'
%   (3) options.analysisName: name given to inv kin analysis
%   (4) options.gravAccel = gravitational acceleration

% computes dynamics of each segment expressed in cartesian coordinates
% updates following for each segment
%   (1) segment.(segmentName).(cs).distalReactionForce = intersegmental
%           force acting on segment at distal contact point expressed in 
%           the segment's (cs) frame. The distal force is the GRF if foot
%           segment
%   (2) segment.(segmentName).(cs).proximalReactionForce = intersegmental
%           force acting on segment at proximal contact point expressed in 
%           the segment's (cs) frame. 
%   (3) segment.(segmentName).(cs).distalJointTorque = joint torque acting
%           on the segment at the distal joint expressed in the segment's
%           (cs) frame. The distal joint torque is the force plate free
%           moment if foot segment
%   (4) segment.(segmentName).(cs).proximalJointTorque = joint torque acting
%           on the segment at the proximal joint expressed in the segment's
%           (cs) frame.

% algorithm:
%   (1) express GRF in foot frame = distal reaction force
%   (2) express gravitational force acting on foot in foot frame
%   (3) solve for foot proximal reaction force (intersegmental) expressed in foot frame = (foot mass) * (foot com acceleration in foot frame) - (gravitational force from 2) - (distal reaction force from 1)
%   (4) express distal joint torque (force plate free moment) in foot frame
%   (5) get vector pointing from foot com to center of pressure (rd) in foot frame
%   (6) get vector pointing from foot com to ankle joint center (rp) in foot frame
%   (7) solve for foot proximal joint torqe expressed in foot frame: (footMOI in foot frame) * (foot ang accel in foot frame) + (foot ang vel in foot frame) x (foot MOI in foot frame) * ( foot ang vel in foot frame) - (distal joint torque from 4) - (rd from 5) x (distal reaction force from 1) - (rp from 6) x (proximal reaction force from 3)
%   (8) express foot proximal reaction force in shank frame
%   (9) negate 8 = distal reaction force
%   (10) express foot proximal joint torque in shank frame
%   (11) negate 10 = distal joint torque
%   (12) repeat for shank as did for foot
%   (13) repeat for thigh as did for shank

%% newtonEulerInverseDynamics

cs = options.coordinateSystem;
side = options.side;
anl = options.analysisName;
gravAccel = options.gravitationalAcceleration;

% unpack
nframes = trial.nMarkerFrames;
foot = trial.(anl).body.segment.([side '_foot']);
mfoot = model.segment.([side '_foot']);
shank = trial.(anl).body.segment.([side '_shank']);
mshank = model.segment.([side '_shank']);
thigh = trial.(anl).body.segment.([side '_thigh']);
mthigh = model.segment.([side '_thigh']);
mankle = model.joint.([side '_ankle']);
mknee = model.joint.([side '_knee']);
mhip = model.joint.([side '_hip']);

% initialize kinetic variables
vars = {'proximalReactionForce','distalReactionForce','proximalJointTorque','distalJointTorque'};
for k = 1:length(vars)
    foot.(cs).(vars{k}) = zeros(3,nframes);
    shank.(cs).(vars{k}) = zeros(3,nframes);
    thigh.(cs).(vars{k}) = zeros(3,nframes);
end

% world frame gravity vector
gravity_world = gravAccel * [0 -1 0]';

%% foot
    
% foot distal reaction (grf) and gravity
foot.(cs).distalReactionForce = qrot(foot.(cs).orientation,trial.forcePlate(1).force,'inverse');
gravity_body = qrot(foot.(cs).orientation,mfoot.mass * gravity_world,'inverse');

% solve for proximal reaction
foot.(cs).proximalReactionForce = mfoot.mass * qrot(foot.(cs).orientation,foot.principal.acceleration,'inverse') - gravity_body - foot.(cs).distalReactionForce;

% distal torque on foot in foot frame from ground (free moment)
foot.(cs).distalJointTorque = qrot(foot.(cs).orientation,trial.forcePlate(1).torque,'inverse');

% get vectors from segment com to distal/proximal reaction forces (rd/rp)
rd = qrot(foot.(cs).orientation,trial.forcePlate(1).cop - foot.principal.position,'inverse'); % grf application is center of pressure
rp = repmat(qrot(mfoot.(cs).orientation,mankle.position - mfoot.principal.position,'inverse'),[1 nframes]);

% solve for proximal joint torque (ankle)
foot.(cs).proximalJointTorque = mfoot.(cs).inertiaTensor * foot.(cs).angularAcceleration + cross(foot.(cs).angularVelocity,mfoot.(cs).inertiaTensor * foot.(cs).angularVelocity) + ...
                                        -foot.(cs).distalJointTorque + ...
                                        -cross(rd,foot.(cs).distalReactionForce) + ...
                                        -cross(rp,foot.(cs).proximalReactionForce);
                                    
%% shank

% shank distal reaction (negative of foot proximal reaction) and gravity
shank.(cs).distalReactionForce = -qrot(qprod(qconj(shank.(cs).orientation),foot.(cs).orientation),foot.(cs).proximalReactionForce);
gravity_body = qrot(shank.(cs).orientation,mshank.mass * gravity_world,'inverse');

% solve for proximal reaction
shank.(cs).proximalReactionForce = mshank.mass * qrot(shank.(cs).orientation,shank.principal.acceleration,'inverse') - gravity_body - shank.(cs).distalReactionForce;

% shank distal joint torque is negative of foot proximal joint torque
shank.(cs).distalJointTorque = -qrot(qprod(qconj(shank.(cs).orientation),foot.(cs).orientation),foot.(cs).proximalJointTorque);

% get vectors from segment com to distal/proximal reaction forces (rd/rp)
rd = repmat(qrot(mshank.(cs).orientation,mankle.position - mshank.principal.position,'inverse'),[1 nframes]);
rp = repmat(qrot(mshank.(cs).orientation,mknee.position - mshank.principal.position,'inverse'),[1 nframes]);

% solve for proximal joint torque (shank)
shank.(cs).proximalJointTorque = mshank.(cs).inertiaTensor * shank.(cs).angularAcceleration + cross(shank.(cs).angularVelocity,mshank.(cs).inertiaTensor * shank.(cs).angularVelocity) + ...
                                        -shank.(cs).distalJointTorque + ...
                                        -cross(rd,shank.(cs).distalReactionForce) + ...
                                        -cross(rp,shank.(cs).proximalReactionForce);

%% thigh

% thigh distal reaction (negative of shank proximal) and gravity
thigh.(cs).distalReactionForce = -qrot(qprod(qconj(thigh.(cs).orientation),shank.(cs).orientation),shank.(cs).proximalReactionForce);
gravity_body = qrot(thigh.(cs).orientation,mthigh.mass * gravity_world,'inverse');

% solve for proximal reaction
thigh.(cs).proximalReactionForce = mthigh.mass * qrot(thigh.(cs).orientation,thigh.principal.acceleration,'inverse') - gravity_body - thigh.(cs).distalReactionForce;

% thigh distal joint torque is negative of shank proximal
thigh.(cs).distalJointTorque = -qrot(qprod(qconj(thigh.(cs).orientation),shank.(cs).orientation),shank.(cs).proximalJointTorque);

% get vectors from segment com to distal/proximal reaction forces (rd/rp)
rd = repmat(qrot(mthigh.(cs).orientation,mknee.position - mthigh.principal.position,'inverse'),[1 nframes]);
rp = repmat(qrot(mthigh.(cs).orientation,mhip.position - mthigh.principal.position,'inverse'),[1 nframes]);

% solve for proximal joint torque (hip)
thigh.(cs).proximalJointTorque = mthigh.(cs).inertiaTensor * thigh.(cs).angularAcceleration + cross(thigh.(cs).angularVelocity,mthigh.(cs).inertiaTensor * thigh.(cs).angularVelocity) + ...
                                        -thigh.(cs).distalJointTorque + ...
                                        -cross(rd,thigh.(cs).distalReactionForce) + ...
                                        -cross(rp,thigh.(cs).proximalReactionForce);


%% save

trial.(anl).body.segment.([side '_foot']) = foot;
trial.(anl).body.segment.([side '_shank']) = shank;
trial.(anl).body.segment.([side '_thigh']) = thigh;


end