function model = principalCoordinateSystem(model,options)

% all coordinate system functions return the position of the segment frame
% (global 3x1), the orientation of the segment frame (quaternion 4x1 s.t.
% v_world = q * v_body * q_conj), 3 basis vecotrs (global 3x1), the vector
% of generalized coordinates, and local marker positions

% uses 3x1 marker positions to construct segment frames for pelvis and
% right/left thigh, shank, and foot compatible with the RLB1 generic rigid
% body model

% assumes flat foot

% all frame origins are the segment center of mass
% all frames correspond to the segment principal axes (s.t. inertia matrix
% is diagonal)

% also informs segment mass (segment.(segmentName).mass), segment length
% (segment.(segmentName).length), proximal and distal endpoints
% (e.g segment.(segmentName).principal.endpoint.proximal), gyrationRadii 
% (e.g. segment.(segmentName).principal.gyrationRadius.x, in meters), and
% inertia tensor (segment.(segmentName).principal.inertiaTensor = 3x3
% double)

% inertia properties determined using deleva() function: 'foot' for foot,
% 'shank2' for shank, 'thigh' for thigh, and 'LPT' for pelvis (see deleva()
% for details)

% does one side at a time as per option.side

% uses isb coord system for some axes so returns this coordinate system
% also

% required markers:
%   all isb required markers
%   right_heel (or left_)
%   right_metatarsal2 (or left_)

% requires hip, knee, ankle joint positions
% requires knee flexion axis (pointing right)

% INPUTS
% model - nms model struct, after staticCalibration
% options - struct
%           options.side = 'right' or 'left' (default = 'right')
%           options.hipJointCenterRegressor = 'hara' (default)

%% principal coordinate system

% default
if nargin == 1; options = struct('hipJointCenterRegressor','hara','side','right'); end
if ~isfield(options,'hipJointCenterRegressor'); options.hipJointCenterRegressor = 'hara'; end
if ~isfield(options,'side'); options.side = 'right'; end % right side

% right or left
side = options.side;

% uses some from isb coord sys, so load
model = isbLowerBodyCoordinateSystem(model,options);

%% foot

% mass
model.segment.([side '_foot']).mass = deleva('foot','mass',model.sex) * model.mass;

% length + com
long = model.marker.right_toe_tip.position - model.marker.right_heel.position;
x = normc(model.marker.right_metatarsal2.position - model.marker.right_heel.position);
long = dot(long,x) * x;
model.segment.([side '_foot']).length = vecnorm(long);
model.segment.([side '_foot']).principal.endpoint.proximal = model.marker.right_heel.position;
model.segment.([side '_foot']).principal.endpoint.distal = model.marker.right_heel.position + dot(x,model.marker.right_metatarsal2.position - model.marker.right_heel.position) * x;
model.segment.([side '_foot']).principal.position = model.segment.([side '_foot']).principal.endpoint.proximal + long * deleva('foot','com',model.sex);

% inertia tensor
model.segment.([side '_foot']).principal.gyrationRadius.x = model.segment.([side '_foot']).length * deleva('foot','x',model.sex);
model.segment.([side '_foot']).principal.gyrationRadius.y = model.segment.([side '_foot']).length * deleva('foot','y',model.sex);
model.segment.([side '_foot']).principal.gyrationRadius.z = model.segment.([side '_foot']).length * deleva('foot','z',model.sex);
model.segment.([side '_foot']).principal.inertiaTensor = model.segment.([side '_foot']).mass * diag([ model.segment.([side '_foot']).principal.gyrationRadius.x , model.segment.([side '_foot']).principal.gyrationRadius.y , model.segment.([side '_foot']).principal.gyrationRadius.z ].^2);

% frame composed of principal axes
model.segment.([side '_foot']).principal.basis(1).vector = x;
model.segment.([side '_foot']).principal.basis(3).vector = normc(cross(x,[0 1 0]'));
model.segment.([side '_foot']).principal.basis(2).vector = normc(cross(model.segment.([side '_foot']).principal.basis(3).vector,model.segment.([side '_foot']).principal.basis(1).vector));
model.segment.([side '_foot']).principal.orientation = convdcm([model.segment.([side '_foot']).principal.basis(1).vector, model.segment.([side '_foot']).principal.basis(2).vector, model.segment.([side '_foot']).principal.basis(3).vector],'q');

%% shank

% mass
model.segment.([side '_shank']).mass = deleva('shank2','mass',model.sex) * model.mass;

% length + com
long = model.segment.([side '_shank']).isb.position - mean([model.marker.right_medial_tibial_condyle.position,model.marker.right_lateral_tibial_condyle.position],2);
model.segment.([side '_shank']).length = vecnorm(long);
model.segment.([side '_shank']).principal.endpoint.proximal = model.segment.([side '_shank']).isb.position - long;
model.segment.([side '_shank']).principal.endpoint.distal = model.segment.([side '_shank']).isb.position;
model.segment.([side '_shank']).principal.position = model.segment.([side '_shank']).principal.endpoint.proximal + long * deleva('shank2','com',model.sex);

% inertia tensor
model.segment.([side '_shank']).principal.gyrationRadius.x = model.segment.([side '_shank']).length * deleva('shank2','x',model.sex);
model.segment.([side '_shank']).principal.gyrationRadius.y = model.segment.([side '_shank']).length * deleva('shank2','y',model.sex);
model.segment.([side '_shank']).principal.gyrationRadius.z = model.segment.([side '_shank']).length * deleva('shank2','z',model.sex);
model.segment.([side '_shank']).principal.inertiaTensor = model.segment.([side '_shank']).mass * diag([ model.segment.([side '_shank']).principal.gyrationRadius.x , model.segment.([side '_shank']).principal.gyrationRadius.y , model.segment.([side '_shank']).principal.gyrationRadius.z ].^2);

% frame composed of principal axes
model.segment.([side '_shank']).principal.basis(2).vector = -long/vecnorm(long);
model.segment.([side '_shank']).principal.basis(1).vector = normc(cross(model.segment.([side '_shank']).principal.basis(2).vector,model.joint.([side '_knee']).flexion.axis));
model.segment.([side '_shank']).principal.basis(3).vector = normc(cross(model.segment.([side '_shank']).principal.basis(1).vector,model.segment.([side '_shank']).principal.basis(2).vector));
model.segment.([side '_shank']).principal.orientation = convdcm([model.segment.([side '_shank']).principal.basis(1).vector, model.segment.([side '_shank']).principal.basis(2).vector, model.segment.([side '_shank']).principal.basis(3).vector],'q');

%% thigh

% mass
model.segment.([side '_thigh']).mass = deleva('thigh','mass',model.sex) * model.mass;

% distal endpoint is functional knee center projected onto long axis of shank
model.segment.([side '_thigh']).principal.endpoint.distal = model.segment.([side '_shank']).isb.position + model.segment.([side '_shank']).principal.basis(2).vector * (model.segment.([side '_shank']).principal.basis(2).vector' * (model.joint.([side '_knee']).position - model.segment.([side '_shank']).isb.position));

% proximal endpoint is hip jc
model.segment.([side '_thigh']).principal.endpoint.proximal = model.joint.([side '_hip']).position;

% long axis
long = model.segment.([side '_thigh']).principal.endpoint.distal - model.segment.([side '_thigh']).principal.endpoint.proximal;
model.segment.([side '_thigh']).length = vecnorm(long);
model.segment.([side '_thigh']).principal.position = model.segment.([side '_thigh']).principal.endpoint.proximal + long * deleva('thigh','com',model.sex);

% inertia tensor
model.segment.([side '_thigh']).principal.gyrationRadius.x = model.segment.([side '_thigh']).length * deleva('thigh','x',model.sex);
model.segment.([side '_thigh']).principal.gyrationRadius.y = model.segment.([side '_thigh']).length * deleva('thigh','y',model.sex);
model.segment.([side '_thigh']).principal.gyrationRadius.z = model.segment.([side '_thigh']).length * deleva('thigh','z',model.sex);
model.segment.([side '_thigh']).principal.inertiaTensor = model.segment.([side '_thigh']).mass * diag([ model.segment.([side '_thigh']).principal.gyrationRadius.x , model.segment.([side '_thigh']).principal.gyrationRadius.y , model.segment.([side '_thigh']).principal.gyrationRadius.z ].^2);

% frame composed of principal axes (knees locked => same as shank)
model.segment.([side '_thigh']).principal.basis = model.segment.([side '_shank']).principal.basis;
model.segment.([side '_thigh']).principal.orientation = model.segment.([side '_shank']).principal.orientation;

%% pelvis
    
% mass
model.segment.pelvis.mass = deleva('LPT','mass',model.sex) * model.mass;

% get length based off leg length
model.segment.pelvis.length = (model.segment.([side '_thigh']).length + model.segment.([side '_shank']).length) / (deleva('shank2','length',model.sex) + deleva('thigh','length',model.sex)) * deleva('LPT','length',model.sex);

% get com position
long = model.segment.pelvis.isb.basis(2).vector;

% mid hip
model.segment.pelvis.principal.endpoint.distal = model.joint.([side '_hip']).position;
model.segment.pelvis.principal.endpoint.proximal = model.joint.([side '_hip']).position + 2 * model.segment.pelvis.isb.basis(3).vector * (model.segment.pelvis.isb.basis(3).vector' * (mean([model.marker.right_asis.position,model.marker.left_asis.position],2) - model.joint.([side '_hip']).position));
midhip = mean([model.segment.pelvis.principal.endpoint.distal,model.segment.pelvis.principal.endpoint.proximal],2);
model.segment.pelvis.principal.position = midhip + long * model.segment.pelvis.length * (1 - deleva('LPT','com',model.sex));

% inertia tensor
model.segment.pelvis.principal.gyrationRadius.x = model.segment.pelvis.length * deleva('LPT','x',model.sex);
model.segment.pelvis.principal.gyrationRadius.y = model.segment.pelvis.length * deleva('LPT','y',model.sex);
model.segment.pelvis.principal.gyrationRadius.z = model.segment.pelvis.length * deleva('LPT','z',model.sex);
model.segment.pelvis.principal.inertiaTensor = model.segment.pelvis.mass * diag([ model.segment.pelvis.principal.gyrationRadius.x , model.segment.pelvis.principal.gyrationRadius.y , model.segment.pelvis.principal.gyrationRadius.z ].^2);

% frame composed of principal axes
model.segment.pelvis.principal.basis = model.segment.pelvis.isb.basis;
model.segment.pelvis.principal.orientation = model.segment.pelvis.isb.orientation;

%% get local marker positions and generalized coordinates

model = getLocalMarkerPositions(model,'principal');
model.generalizedCoordinates.principal.position = modelStruct2GeneralizedCoordinates(model,model,'principal');

end