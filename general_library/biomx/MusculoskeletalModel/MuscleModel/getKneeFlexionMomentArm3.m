function body = getKneeFlexionMomentArm(model,body,side)

% input nms model and body structs, body struct should have thigh,
% shank,foot orientation for mechanical coordinate system and knee
% flexion angle

% side is 'right' or 'left'

% eventually should generalize moment arm computation for each mtu, should
% be a single generic function

% returns body.muscle.(muscleName).momentArm.right_knee.flexion in meters
% (or left_knee)

%% getKneeFlexionMomentArm

% unpack
muscle = body.muscle;
msc = fieldnames(muscle);
qt = body.segment.([side '_thigh']).mechanical.orientation;
angle = body.joint.([side '_knee']).flexion.angle;
n = length(angle);
zero = zeros(1,n);
        
% perturbation: decrease/increase knee angle by 1 degree
dangle = 1.0;
angle1 = angle - dangle;
angle2 = angle + dangle;
dangle = dangle * pi / 180; % angle change in radians

% get perturbed shank orientation
qk1 = [zero; zero; sind(angle1/2); cosd(angle1/2)];
qs1 = qprod(qt,qconj(qk1));
qk2 = [zero; zero; sind(angle2/2); cosd(angle2/2)];
qs2 = qprod(qt,qconj(qk2));

% get perturbed body
body1 = body;
body2 = body;
body1.segment.([side '_shank']).mechanical.orientation = qs1;
body2.segment.([side '_shank']).mechanical.orientation = qs2;

% shank mechanical position is knee jc, no need to change, but do need to update foot position
knee2ankle = model.joint.([side '_ankle']).positionRelative2ParentJoint.mechanical;
body1.segment.([side '_foot']).mechanical.position = body1.segment.([side '_shank']).mechanical.position + qrot(qs1,knee2ankle);
body2.segment.([side '_foot']).mechanical.position = body2.segment.([side '_shank']).mechanical.position + qrot(qs2,knee2ankle);

% also need to update foot orientation!!!
qs = body.segment.([side '_shank']).mechanical.orientation;
qf = body.segment.([side '_foot']).mechanical.orientation;
qa = qprod(qconj(qf),qs);
qf1 = qprod(qs1,qconj(qa));
qf2 = qprod(qs2,qconj(qa));
body1.segment.([side '_foot']).mechanical.orientation = qf1;
body2.segment.([side '_foot']).mechanical.orientation = qf2;

% anatomical system
body1 = coordinateTransformation(model,body1,'mechanical','anatomical');
body2 = coordinateTransformation(model,body2,'mechanical','anatomical');

% patella
body1 = patellaModel(model,body1,side);
body2 = patellaModel(model,body2,side);

% get perturbed muscle geometry
body1 = getGlobalMuscleGeometry(model,'anatomical',body1);
body2 = getGlobalMuscleGeometry(model,'anatomical',body2);

% for each muscle
for m = 1:length(msc)
    
    % if spans knee
    if any(strcmp(model.muscle.(msc{m}).joints,[side '_knee'])) && isfield(model.muscle.(msc{m}),'mtu')
        
        % get mtu length and perturbed lengths
        mtuLength1 = body1.muscle.(msc{m}).mtu.length;
        mtuLength2 = body2.muscle.(msc{m}).mtu.length;

        % 3 point finite difference approx
        muscle.(msc{m}).momentArm.([side '_knee']).flexion = (mtuLength1 - mtuLength2) / 2 / dangle; % same as -dmtulength/dangle since dmtulength = mtulength2 - mtulength1

    else
        
        % zero moment arm
        muscle.(msc{m}).momentArm.([side '_knee']).flexion = zeros(1,n);
        
    end
    
end

% save
body.muscle = muscle;

end