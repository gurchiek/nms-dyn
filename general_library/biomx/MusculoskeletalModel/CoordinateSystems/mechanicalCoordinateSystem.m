function model = mechanicalCoordinateSystem(model,options)

% uses 3x1 marker positions to construct segment frames for pelvis and
% right/left thigh, shank, and foot that are consistent with the RLB1
% mechanical constraints

% pelvis origin is hip joint center
% all other segment origins are parent joint center (hip for thigh, knee
% for shank, ankle for foot)

% pelvis frame same as isb
% shank z (right) is knee joint flexion axis
% shank x (forward) is orthogonal to z shank long (mid condyle to mid malleoli)
% thigh x,y,z is same as shank
% foot z is shank z
% foot x is in/eversion axis as per fig 4 in delp et al. 1990

% does one side at a time

% required markers:
%   right_asis
%   left_asis
%   right_psis
%   left_psis
%   right_lateral_malleolus (or left_)
%   right_medial_malleolus (or left_)
%   right_medial_tibial_condyle (or left_)
%   right_lateral_tibial_condyle (or left_)
%   right_heel (or left_)

% requires hip, knee, ankle joint positions
% requires knee flexion axis (pointing right)

% INPUTS
% model - nms model struct,
% options - struct, options.side = 'right' or 'left' (default = 'right')

side = options.side;

% pelvis
model.segment.pelvis.mechanical.position = model.joint.([side '_hip']).position;
model.segment.pelvis.mechanical.basis(3).vector = normc(model.marker.right_asis.position - model.marker.left_asis.position);
model.segment.pelvis.mechanical.basis(2).vector = normc(cross(mean([model.marker.right_psis.position, model.marker.left_psis.position],2) - model.marker.left_asis.position,model.segment.pelvis.mechanical.basis(3).vector));
model.segment.pelvis.mechanical.basis(1).vector = normc(cross(model.segment.pelvis.mechanical.basis(2).vector,model.segment.pelvis.mechanical.basis(3).vector));
model.segment.pelvis.mechanical.orientation = convdcm([model.segment.pelvis.mechanical.basis(1).vector, model.segment.pelvis.mechanical.basis(2).vector, model.segment.pelvis.mechanical.basis(3).vector],'q');

% shank
% trust knee axis as shank z (points right) and orthogonalize with tibia long axis
model.segment.([side '_shank']).mechanical.position = model.joint.([side '_knee']).position;
model.segment.([side '_shank']).mechanical.basis(3).vector = model.joint.([side '_knee']).flexion.axis;
model.segment.([side '_shank']).mechanical.basis(1).vector = ...
    normc(cross(mean([model.marker.([side '_medial_tibial_condyle']).position,model.marker.([side '_lateral_tibial_condyle']).position],2) - mean([model.marker.([side '_lateral_malleolus']).position,model.marker.([side '_medial_malleolus']).position],2),model.joint.([side '_knee']).flexion.axis));
model.segment.([side '_shank']).mechanical.basis(2).vector = normc(cross(model.segment.([side '_shank']).mechanical.basis(3).vector,model.segment.([side '_shank']).mechanical.basis(1).vector));
model.segment.([side '_shank']).mechanical.orientation = convdcm([model.segment.([side '_shank']).mechanical.basis(1).vector, model.segment.([side '_shank']).mechanical.basis(2).vector, model.segment.([side '_shank']).mechanical.basis(3).vector],'q');

% thigh
% assumes knees locked out => thigh cs = shank cs (single DOF)
model.segment.([side '_thigh']).mechanical.position = model.joint.([side '_hip']).position;
model.segment.([side '_thigh']).mechanical.basis = model.segment.([side '_shank']).mechanical.basis;
model.segment.([side '_thigh']).mechanical.orientation = model.segment.([side '_shank']).mechanical.orientation;

% foot
% see fig 4 in delp 90, foot roll (in/eversion) axis points from heel
% through point on line defined by ankle jc and PF axis and orthogonal to
% PF axis, compute using gram-schmidt
model.segment.([side '_foot']).mechanical.position = model.joint.([side '_ankle']).position;
model.segment.([side '_foot']).mechanical.basis(3).vector = model.joint.([side '_knee']).flexion.axis;
hj = model.joint.([side '_ankle']).position - model.marker.([side '_heel']).position;
model.segment.([side '_foot']).mechanical.basis(1).vector = normc( hj - (model.joint.([side '_knee']).flexion.axis' * hj) * model.joint.([side '_knee']).flexion.axis );
model.segment.([side '_foot']).mechanical.basis(2).vector = normc(cross(model.segment.([side '_foot']).mechanical.basis(3).vector,model.segment.([side '_foot']).mechanical.basis(1).vector));
model.segment.([side '_foot']).mechanical.orientation = convdcm([model.segment.([side '_foot']).mechanical.basis(1).vector, model.segment.([side '_foot']).mechanical.basis(2).vector, model.segment.([side '_foot']).mechanical.basis(3).vector],'q');

%% get local marker positions and generalized coordinates

model = getLocalMarkerPositions(model,'mechanical');
model.generalizedCoordinates.mechanical.position = modelStruct2GeneralizedCoordinates(model,model,'mechanical');

end