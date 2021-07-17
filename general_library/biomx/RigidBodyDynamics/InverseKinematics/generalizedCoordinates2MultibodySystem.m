function body = generalizedCoordinates2MultibodySystem(model,body,options)

% nms body struct should have generalized coordinates, velocities,
% accelerations for input cs (e.g. body.generalizedCoordinates.(cs).position)

% must have already computed joint coordinate systems and local joint
% positions

% options:
%   (1) optioons.coordinateSystem = char
%   (2) options.lowPassCutoff = double, Hz
%   (3) options.samplingFrequency = double, Hz

% updates the following nms body fields:
%   (1) body.joint.(jointName).(rotationName).angle: degrees, one for each rotationName (each dof)
%   (2) body.segment.(segmentName).(cs).position: 3xn global frame
%   (2) body.segment.(segmentName).(cs).velocity: 3xn global frame
%   (2) body.segment.(segmentName).(cs).acceleration: 3xn global frame
%   (2) body.segment.(segmentName).(cs).orientation: 4xn st v_global = q * v_body * q_conj
%   (2) body.segment.(segmentName).(cs).angularVelocity: 3xn body frame
%   (2) body.segment.(segmentName).(cs).angularAcceleration: 3xn body frame

% unpack
cs = options.coordinateSystem;
lpc = options.lowPassCutoff;
sf = options.samplingFrequency;

% gen coord
x = body.generalizedCoordinates.(cs).position;
xd = body.generalizedCoordinates.(cs).velocity;
xdd = body.generalizedCoordinates.(cs).acceleration;
nFrames = size(x,2);

% for each joint
joints = model.jointNames;
for j = 1:model.nJoints
    
    % get parent/child orientation
    gc_ind = segmentIndex2GeneralizedCoordinateIndices(modelSegment2Index(model,model.joint.(joints{j}).parent.segment),'rotation');
    qparent = x(gc_ind,:);
    gc_ind = segmentIndex2GeneralizedCoordinateIndices(modelSegment2Index(model,model.joint.(joints{j}).child.segment),'rotation');
    qchild = x(gc_ind,:);
    
    % get joint jcs in parent and child
    Qp = qprodmat(model.joint.(joints{j}).parent.(cs).orientation,2);
    Qc = qprodmat(model.joint.(joints{j}).child.(cs).orientation,2);
    qjp = Qp * qparent;
    qjc = Qc * qchild;
    
    % get quaternion that maps segment 1 jcs to segment 2 jcs, order depends on perspective
    % if parent to child
    if strcmpi(model.joint.(joints{j}).rotationPerspective,'parent2child')
        
        % then qj maps v_parent = qj * v_child * qj_conj
        qj = qprod(qconj(qjp),qjc);
        
    elseif strcmpi(model.joint.(joints{j}).rotationPerspective,'child2parent')
        
        % then qj maps v_child = qj * v_parent * qj_conj
        qj = qprod(qconj(qjc),qjp);
        
    end
    
    % ball (3 dof)
    if model.joint.(joints{j}).rotationDOF == 3
        
        % invert rotator as per euler convention and convert
        angle = convq(qconj(qj),'xyz') * 180/pi;
       
    % universal (2 dof)
    elseif model.joint.(joints{j}).rotationDOF == 2
        
        % extract
          % this was based incorrectly on qj = q_dof2 * q_dof1
%         angle = [asind(2 * qj(1,:) .* qj(4,:) - 2 * qj(2,:) .* qj(3,:)); ...
%                  asind(2 * qj(2,:) .* qj(4,:) - 2 * qj(1,:) .* qj(3,:))];

        angle = [asind(2 * qj(1,:) .* qj(4,:) + 2 * qj(2,:) .* qj(3,:)); ...
                 asind(2 * qj(2,:) .* qj(4,:) + 2 * qj(1,:) .* qj(3,:))];
        
    % hinge (1 dof)
    elseif model.joint.(joints{j}).rotationDOF == 1
        
        % extract
        angle = 2 * asind(qj(1,:));
        
    end
    
    % assign angles
    for dof = 1:model.joint.(joints{j}).rotationDOF; body.joint.(joints{j}).(model.joint.(joints{j}).rotationName{dof}).angle = angle(dof,:); end
    
end

% for each segment
for k = 1:model.nSegments
    
    % get segment name
    seg = modelIndex2Segment(model,model.segmentIndices(k));
    
    % get cartesian kinematics
    body.segment.(seg).(cs).position = x(segmentIndex2GeneralizedCoordinateIndices(model.segmentIndices(k),'translation'),:);
    body.segment.(seg).(cs).velocity = bwfilt(xd(segmentIndex2GeneralizedCoordinateIndices(model.segmentIndices(k),'translation'),:),lpc,sf,'low',4);
    body.segment.(seg).(cs).acceleration = bwfilt(xdd(segmentIndex2GeneralizedCoordinateIndices(model.segmentIndices(k),'translation'),:),lpc,sf,'low',4);
    
    % unpack quaternion/quaternion derivative
    q = x(segmentIndex2GeneralizedCoordinateIndices(model.segmentIndices(k),'rotation'),:);
    qd = xd(segmentIndex2GeneralizedCoordinateIndices(model.segmentIndices(k),'rotation'),:);
%     qdd = xdd(segmentIndex2GeneralizedCoordinateIndices(k,'rotation'),:);

    % get jacobian that takes quaternion derivative to angular rate in body frame
    Jw = qjac(q,1,1,0);
%     Ja = qjac(qd,1,1,0);

    % store orientation and initialize angular vel/accel (in body frame)
    body.segment.(seg).(cs).orientation = q;
    body.segment.(seg).(cs).angularVelocity = zeros(3,nFrames); 
    body.segment.(seg).(cs).angularAcceleration = zeros(3,nFrames);
    w = zeros(3,nFrames);
%     a = w;

    % get angular rate in body frame
    for j = 1:nFrames
        w(:,j) = Jw(:,:,j) * qd(:,j);
%         a(:,j) = Ja(:,:,j) * qd(:,j) + Jw(:,:,j) * qdd(:,j);
    end
    
    % smooth, differentiate, smooth
    w = bwfilt(w,lpc,sf,'low',4);
    a = fdiff(w,1/sf,5);
    a = bwfilt(a,lpc,sf,'low',4);
    
    body.segment.(seg).(cs).angularVelocity = w;
    body.segment.(seg).(cs).angularAcceleration = a;
    
end

% % twente coordinate system
% body = coordinateTransformation(model,body,cs,'anatomical');
% body = patellaModel(model,body);
% 
% % 
% body = getGlobalBodyContourGeometry(model,body,'right_femoralCondyle','anatomical');
% 
% % global muscle geometry
% body = getGlobalMuscleGeometry(model,'anatomical',body);
% 
% % get knee/ankle flexion moment arm
% body = getKneeFlexionMomentArm5(model,body);
% body = getAnkleFlexionMomentArm5(model,body);

end