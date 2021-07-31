function body = getAnkleFlexionMomentArm(model,body,side)

% input nms model and body structs, body struct should have thigh, shank,
% and foot orientation for mechanical coordinate system

% side is 'right' or 'left'

% eventually should generalize moment arm computation for each mtu, should
% be a single generic function

% returns body.muscle.(muscleName).momentArm.right_ankle.flexion in meters
% (or left_ankle)

%% getAnkleFlexionMomentArm

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
        
% perturbation: decrease/increase knee angle by 1 degree
angle1 = angle - 1;
angle2 = angle + 1;
dangle = 1 * pi / 180; % angle change in radians

% get perturbed foot orientation
qa1 = qprod([zero; zero; sind(angle1/2); cosd(angle1/2)],qx);
qf1 = qprod(qs,qa1);
qa2 = qprod([zero; zero; sind(angle2/2); cosd(angle2/2)],qx);
qf2 = qprod(qs,qa2);

% get perturbed body
body1 = body;
body2 = body;
body1.segment.([side '_foot']).mechanical.orientation = qf1;
body2.segment.([side '_foot']).mechanical.orientation = qf2;

% foot position is ankle jc, unaffected by changing foot orientation, no
% need to change

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
    
    % if spans ankle
    if any(strcmp(model.muscle.(msc{m}).joints,[side '_ankle'])) && isfield(model.muscle.(msc{m}),'mtu')
        
        % get mtu length and perturbed lengths
        mtuLength1 = body1.muscle.(msc{m}).mtu.length;
        mtuLength2 = body2.muscle.(msc{m}).mtu.length;

        % 3 point finite difference approx
        muscle.(msc{m}).momentArm.([side '_ankle']).flexion = (mtuLength1 - mtuLength2) / 2 / dangle;  % same as -dmtulength/dangle since dmtulength = mtulength2 - mtulength1

    else
        
        % zero moment arm
        muscle.(msc{m}).momentArm.([side '_ankle']).flexion = zeros(1,n);
        
    end
    
end

% save
body.muscle = muscle;

end