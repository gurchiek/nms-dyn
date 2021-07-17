function model = isbLowerBodyCoordinateSystem(model,options)

% uses 3x1 marker positions to construct segment frames for pelvis and
% right/left thigh, shank, and foot according to isb standards. Assumes a
% flat foot

% pelvis origin is hip joint center. If the model hip joint center is
% already specified (e.g. via functional methods) then this is used,
% otherwise it is regressed. Users can select which regressor to use: see
% hipjcregressor()

% does one side at a time

% required markers:
%   right_asis
%   left_asis
%   right_psis
%   left_psis
%   right_lat_femoral_epicondyle (or left_)
%   right_med_femoral_epicondyle (or left_)
%   right_lateral_malleolus (or left_)
%   right_medial_malleolus (or left_)
%   right_medial_tibial_condyle (or left_)
%   right_lateral_tibial_condyle (or left_)
%   right_metatarsal1 (or left_)
%   right_metatarsal5 (or left_)

% INPUTS
% model - nms model struct, after staticCalibration
% options - struct
%           options.side = 'right' or 'left' (default = 'right')
%           options.hipJointCenterRegressor = 'hara' (default)


%% isb coordinate system

% coordinate system name (fieldname)
cs = 'isb';

% default
if nargin == 1; options = struct('hipJointCenterRegressor','hara','side','right'); end
if ~isfield(options,'hipJointCenterRegressor'); options.hipJointCenterRegressor = 'hara'; end
if ~isfield(options,'side'); options.side = 'right'; end % right side

% unpack
marker = model.marker;
side = options.side;
sideFlag = 1;
if strcmpi(side,'left'); sideFlag = -1; end

% anthropometry
if ~isfield(model,[side 'LegLength']); model.([side 'LegLength']) = vecnorm(marker.([side '_asis']).position - marker.([side '_medial_malleolus']).position); end
if ~isfield(model.segment.pelvis,'width'); model.segment.pelvis.width = vecnorm(marker.right_asis.position - marker.left_asis.position); end
if ~isfield(model.segment.pelvis,'depth'); model.segment.pelvis.depth = vecnorm(mean([marker.right_asis.position, marker.left_asis.position],2) - mean([marker.right_psis.position, marker.left_psis.position],2)); end
if ~isfield(model.segment.([side '_foot']),'width'); model.segment.([side '_foot']).width = vecnorm(marker.([side '_metatarsal1']).position - marker.([side '_metatarsal5']).position); end
if ~isfield(model.joint.([side '_knee']),'width'); model.joint.([side '_knee']).width = vecnorm(marker.([side '_lat_femoral_epicondyle']).position - marker.([side '_med_femoral_epicondyle']).position); end
if ~isfield(model.joint.([side '_ankle']),'width'); model.joint.([side '_ankle']).width = vecnorm(marker.([side '_lateral_malleolus']).position - marker.([side '_medial_malleolus']).position); end

% pelvis frame
model.segment.pelvis.(cs).basis(3).vector = normc(marker.right_asis.position - marker.left_asis.position);
model.segment.pelvis.(cs).basis(2).vector = normc(cross(mean([marker.right_psis.position, marker.left_psis.position],2) - marker.left_asis.position,model.segment.pelvis.(cs).basis(3).vector));
model.segment.pelvis.(cs).basis(1).vector = normc(cross(model.segment.pelvis.(cs).basis(2).vector,model.segment.pelvis.(cs).basis(3).vector));
model.segment.pelvis.(cs).orientation = convdcm([model.segment.pelvis.(cs).basis(1).vector, model.segment.pelvis.(cs).basis(2).vector, model.segment.pelvis.(cs).basis(3).vector],'q');

% hip joint center is pelvis origin
if ~isfield(model.joint.([side '_hip']),'position')
    hipjc = hipjcregressor(options.hipJointCenterRegressor,model.segment.pelvis.depth,model.segment.pelvis.width,model.([side 'LegLength']),sideFlag);
    model.segment.pelvis.(cs).position = mean([marker.right_asis.position,marker.left_asis.position],2) + qrot(model.segment.pelvis.(cs).orientation,hipjc);
    model.joint.([side '_hip']).position = model.segment.pelvis.(cs).position;
else
    model.segment.pelvis.(cs).position = model.joint.([side '_hip']).position;
end

% thigh: z right, x forward, y up
model.segment.([side '_thigh']).(cs).position = model.joint.([side '_hip']).position;
model.segment.([side '_thigh']).(cs).basis(2).vector = normc(model.joint.([side '_hip']).position - mean([marker.([side '_med_femoral_epicondyle']).position, marker.([side '_lat_femoral_epicondyle']).position],2));
model.segment.([side '_thigh']).(cs).basis(1).vector = sideFlag * normc(cross(model.segment.([side '_thigh']).(cs).basis(2).vector,marker.([side '_lat_femoral_epicondyle']).position - marker.([side '_med_femoral_epicondyle']).position));
model.segment.([side '_thigh']).(cs).basis(3).vector = normc(cross(model.segment.([side '_thigh']).(cs).basis(1).vector,model.segment.([side '_thigh']).(cs).basis(2).vector));
model.segment.([side '_thigh']).(cs).orientation = convdcm([model.segment.([side '_thigh']).(cs).basis(1).vector, model.segment.([side '_thigh']).(cs).basis(2).vector, model.segment.([side '_thigh']).(cs).basis(3).vector],'q');

% shank: z right, x forward, y up
model.segment.([side '_shank']).(cs).position = mean([marker.([side '_lateral_malleolus']).position,marker.([side '_medial_malleolus']).position],2);
model.segment.([side '_shank']).(cs).basis(3).vector = sideFlag * normc(marker.([side '_lateral_malleolus']).position - marker.([side '_medial_malleolus']).position);
model.segment.([side '_shank']).(cs).basis(1).vector = normc(cross(mean([marker.([side '_medial_tibial_condyle']).position, marker.([side '_lateral_tibial_condyle']).position],2) - marker.([side '_medial_malleolus']).position,model.segment.([side '_shank']).(cs).basis(3).vector));
model.segment.([side '_shank']).(cs).basis(2).vector = normc(cross(model.segment.([side '_shank']).(cs).basis(3).vector,model.segment.([side '_shank']).(cs).basis(1).vector));
model.segment.([side '_shank']).(cs).orientation = convdcm([model.segment.([side '_shank']).(cs).basis(1).vector, model.segment.([side '_shank']).(cs).basis(2).vector, model.segment.([side '_shank']).(cs).basis(3).vector],'q');

% foot: z right, x forward, y up
model.segment.([side '_foot']).(cs).position = model.segment.([side '_shank']).(cs).position;
model.segment.([side '_foot']).(cs).basis(2).vector = [0 1 0]'; % assumes flat foot
xhat = sideFlag * normc(cross(marker.([side '_medial_tibial_condyle']).position - model.segment.([side '_foot']).(cs).position, marker.([side '_lateral_tibial_condyle']).position - model.segment.([side '_foot']).(cs).position));
z = normc(cross(xhat,[0 1 0]'));
model.segment.([side '_foot']).(cs).basis(3).vector = sign(z' * model.segment.([side '_shank']).(cs).basis(3).vector) * z;
model.segment.([side '_foot']).(cs).basis(1).vector = normc(cross(model.segment.([side '_shank']).(cs).basis(2).vector, model.segment.([side '_shank']).(cs).basis(3).vector));
model.segment.([side '_foot']).(cs).orientation = convdcm([model.segment.([side '_foot']).(cs).basis(1).vector, model.segment.([side '_foot']).(cs).basis(2).vector, model.segment.([side '_foot']).(cs).basis(3).vector],'q');

%% get local marker positions and generalized coordinates

model = getLocalMarkerPositions(model,'isb');
model.generalizedCoordinates.isb.position = modelStruct2GeneralizedCoordinates(model,model,'isb');

end