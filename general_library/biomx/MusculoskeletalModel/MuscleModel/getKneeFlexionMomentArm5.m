function body = getKneeFlexionMomentArm5(model,body,side,options)

% input nms model and body structs, body struct should have thigh,
% shank,foot orientation for mechanical coordinate system and knee
% flexion angle

% exact same as getKneeFlexionMomentArm3 except approximates partial using 5
% point central difference instead of 3 point

% side is 'right' or 'left'

% eventually should generalize moment arm computation for each mtu, should
% be a single generic function

% returns body.muscle.(muscleName).momentArm.right_knee.flexion in meters
% (or left_knee)

% options is an input to getGlobalMuscleGeometry (see function for details)

%% getKneeFlexionMomentArm5

% default options is empty
if nargin == 3
    options = struct();
end

% unpack
muscle = body.muscle;
msc = fieldnames(muscle);
qt = body.segment.([side '_thigh']).mechanical.orientation;
angle = body.joint.([side '_knee']).flexion.angle;
n = length(angle);
zero = zeros(1,n);
        
% perturbation: decrease/increase knee angle by 0.1 degree
dangle = 0.1;
angle1 = angle - 2*dangle;
angle2 = angle - dangle;
angle3 = angle + dangle;
angle4 = angle + 2*dangle;
dangle = dangle * pi / 180; % angle change in radians

% filter?
if isfield(options,'lowPassCutoff') && isfield(options,'samplingFrequency')
    angle1 = bwfilt(angle1,options.lowPassCutoff,options.samplingFrequency,'low',4);
    angle2 = bwfilt(angle2,options.lowPassCutoff,options.samplingFrequency,'low',4);
    angle3 = bwfilt(angle3,options.lowPassCutoff,options.samplingFrequency,'low',4);
    angle4 = bwfilt(angle4,options.lowPassCutoff,options.samplingFrequency,'low',4);
end

% get perturbed shank orientation
qk1 = [zero; zero; sind(angle1/2); cosd(angle1/2)];
qs1 = qprod(qt,qconj(qk1));
qk2 = [zero; zero; sind(angle2/2); cosd(angle2/2)];
qs2 = qprod(qt,qconj(qk2));
qk3 = [zero; zero; sind(angle3/2); cosd(angle3/2)];
qs3 = qprod(qt,qconj(qk3));
qk4 = [zero; zero; sind(angle4/2); cosd(angle4/2)];
qs4 = qprod(qt,qconj(qk4));

% get perturbed body
body1 = body;
body2 = body;
body3 = body;
body4 = body;
body1.segment.([side '_shank']).mechanical.orientation = qs1;
body2.segment.([side '_shank']).mechanical.orientation = qs2;
body3.segment.([side '_shank']).mechanical.orientation = qs3;
body4.segment.([side '_shank']).mechanical.orientation = qs4;

% shank mechanical position is knee jc, no need to change, but do need to update foot position
knee2ankle = model.joint.([side '_ankle']).positionRelative2ParentJoint.mechanical;
body1.segment.([side '_foot']).mechanical.position = body1.segment.([side '_shank']).mechanical.position + qrot(qs1,knee2ankle);
body2.segment.([side '_foot']).mechanical.position = body2.segment.([side '_shank']).mechanical.position + qrot(qs2,knee2ankle);
body3.segment.([side '_foot']).mechanical.position = body3.segment.([side '_shank']).mechanical.position + qrot(qs3,knee2ankle);
body4.segment.([side '_foot']).mechanical.position = body4.segment.([side '_shank']).mechanical.position + qrot(qs4,knee2ankle);

% also need to update foot orientation!!!
qs = body.segment.([side '_shank']).mechanical.orientation;
qf = body.segment.([side '_foot']).mechanical.orientation;
qa = qprod(qconj(qf),qs);
qf1 = qprod(qs1,qconj(qa));
qf2 = qprod(qs2,qconj(qa));
qf3 = qprod(qs3,qconj(qa));
qf4 = qprod(qs4,qconj(qa));
body1.segment.([side '_foot']).mechanical.orientation = qf1;
body2.segment.([side '_foot']).mechanical.orientation = qf2;
body3.segment.([side '_foot']).mechanical.orientation = qf3;
body4.segment.([side '_foot']).mechanical.orientation = qf4;

% anatomical system
body1 = coordinateTransformation(model,body1,'mechanical','anatomical');
body2 = coordinateTransformation(model,body2,'mechanical','anatomical');
body3 = coordinateTransformation(model,body3,'mechanical','anatomical');
body4 = coordinateTransformation(model,body4,'mechanical','anatomical');

% patella
body1 = patellaModel(model,body1,side);
body2 = patellaModel(model,body2,side);
body3 = patellaModel(model,body3,side);
body4 = patellaModel(model,body4,side);

% get perturbed muscle geometry
body1 = getGlobalMuscleGeometry(model,'anatomical',body1,options);
body2 = getGlobalMuscleGeometry(model,'anatomical',body2,options);
body3 = getGlobalMuscleGeometry(model,'anatomical',body3,options);
body4 = getGlobalMuscleGeometry(model,'anatomical',body4,options);

% for each muscle
for m = 1:length(msc)
    
    % if spans knee
    if any(strcmp(model.muscle.(msc{m}).joints,[side '_knee'])) && isfield(model.muscle.(msc{m}),'mtu')
        
        % get mtu length and perturbed lengths
        mtuLength1 = body1.muscle.(msc{m}).mtu.length;
        mtuLength2 = body2.muscle.(msc{m}).mtu.length;
        mtuLength3 = body3.muscle.(msc{m}).mtu.length;
        mtuLength4 = body4.muscle.(msc{m}).mtu.length;

        % 5 point finite difference approx
        muscle.(msc{m}).momentArm.([side '_knee']).flexion = -(8*mtuLength3 - 8*mtuLength2 - mtuLength4 + mtuLength1) / 12 / dangle; % same as -dmtulength/dangle

    else
        
        % zero moment arm
        muscle.(msc{m}).momentArm.([side '_knee']).flexion = zeros(1,n);
        
    end
    
end

% save
body.muscle = muscle;

end