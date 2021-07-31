function body = getAnkleFlexionMomentArm5(model,body,side,options)

% input nms model and body structs, body struct should have thigh, shank,
% and foot orientation for mechanical coordinate system

% exact same as getAnkleFlexionMomentArm3 except approximates partial using 5
% point central difference instead of 3 point

% side is 'right' or 'left'

% eventually should generalize moment arm computation for each mtu, should
% be a single generic function

% returns body.muscle.(muscleName).momentArm.right_ankle.flexion in meters
% (or left_ankle)

% options is an input to getGlobalMuscleGeometry (see function for details)

%% getAnkleFlexionMomentArm5

% default options is empty
if nargin == 3
    options = struct();
end

% unpack
muscle = body.muscle;
msc = fieldnames(muscle);
qs = body.segment.([side '_shank']).mechanical.orientation;
qf = body.segment.([side '_foot']).mechanical.orientation;
n = size(qs,2);
zero = zeros(1,n);

% ankle angles
qa = normalize(qprod(qconj(qs),qf),1,'norm');
angle = asind(2 * qa(1,:) .* qa(2,:) + 2 * qa(3,:) .* qa(4,:));
adductionAngle = asind(2 * qa(2,:) .* qa(3,:) + 2 * qa(1,:) .* qa(4,:));
qx = [sind(adductionAngle/2); zero; zero; cosd(adductionAngle/2)];
        
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

% get perturbed foot orientation
qa1 = qprod([zero; zero; sind(angle1/2); cosd(angle1/2)],qx);
qf1 = qprod(qs,qa1);
qa2 = qprod([zero; zero; sind(angle2/2); cosd(angle2/2)],qx);
qf2 = qprod(qs,qa2);
qa3 = qprod([zero; zero; sind(angle3/2); cosd(angle3/2)],qx);
qf3 = qprod(qs,qa3);
qa4 = qprod([zero; zero; sind(angle4/2); cosd(angle4/2)],qx);
qf4 = qprod(qs,qa4);

% get perturbed body
body1 = body;
body2 = body;
body3 = body;
body4 = body;
body1.segment.([side '_foot']).mechanical.orientation = qf1;
body2.segment.([side '_foot']).mechanical.orientation = qf2;
body3.segment.([side '_foot']).mechanical.orientation = qf3;
body4.segment.([side '_foot']).mechanical.orientation = qf4;

% foot position is ankle jc, unaffected by changing foot orientation, no
% need to change

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
    
    % if spans ankle
    if any(strcmp(model.muscle.(msc{m}).joints,[side '_ankle'])) && isfield(model.muscle.(msc{m}),'mtu')
        
        % get mtu length and perturbed lengths
        mtuLength1 = body1.muscle.(msc{m}).mtu.length;
        mtuLength2 = body2.muscle.(msc{m}).mtu.length;
        mtuLength3 = body3.muscle.(msc{m}).mtu.length;
        mtuLength4 = body4.muscle.(msc{m}).mtu.length;

        % 5 point finite difference approx
        muscle.(msc{m}).momentArm.([side '_ankle']).flexion = -(8*mtuLength3 - 8*mtuLength2 - mtuLength4 + mtuLength1) / 12 / dangle; % same as -dmtulength/dangle

    else
        
        % zero moment arm
        muscle.(msc{m}).momentArm.([side '_ankle']).flexion = zeros(1,n);
        
    end
    
end

% save
body.muscle = muscle;

end