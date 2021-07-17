function model = jointCoordinateSystem(model,cs)

% all joints must have an axis specified for each rotation name specified
% in the rigid body model (e.g. hip.flexion.axis) where this axis is unit
% length and expressed with respect to the global frame in the static
% calibbration

% for each joint, three fields are updated in model
%   (1) joint.(jointName).orientation = 4x1 quaternion such that v_world = q * v_jcs * q_conj
%   (2) joint.(jointName).parent.(cs).orientation = 4x1 quaternion such that v_parent_cs = q * v_jcs * q_conj
%   (3) joint.(jointName).child.(cs).orientation = 4x1 quaternion such that v_child_cs = q * v_jcs * q_conj

% note that this can be done for multiple coordinate systems by inputting
% cs as a cell array (e.g. cs = {'isb','principal'})

%% jointCoordinateSystem

if ~iscell(cs); cs = {cs}; end

% for each joint
joints = model.jointNames;
n = model.nJoints;
for j = 1:n
    
    % init dcm (columns contain bases of jcs)
    dcm = zeros(3);
    
    % for each rotation
    for r = 1:model.joint.(joints{j}).rotationDOF
        
        % get axis
        dcm(:,r) = model.joint.(joints{j}).(model.joint.(joints{j}).rotationName{r}).axis;
        
    end
    
    % orthogonalize if necessary
    v = [1 0 0]';
    for c = r+1:3
        if c == 3; dcm(:,c) = normc(cross(dcm(:,1),dcm(:,2)));
        else
            if abs(dot(v,dcm(:,1))) >= 0.90; v = [0 1 0]'; end
            dcm(:,2) = normc(cross(dcm(:,1),v));
        end
    end
    
    % orientation
    qjcs = convdcm(dcm,'q');
    model.joint.(joints{j}).orientation = qjcs;
    
    % for each input coordinate system
    for k = 1:length(cs)
    
        % get quaternions mapping child/parent to world (e.g. v_world = qparent * v_parent * qparent_conj
        qparent = model.segment.(model.joint.(joints{j}).parent.segment).(cs{k}).orientation;
        qchild = model.segment.(model.joint.(joints{j}).child.segment).(cs{k}).orientation;

        % get quaternion q s.t. v_parent = q * v_jcs * q_conj
        model.joint.(joints{j}).parent.(cs{k}).orientation = qprod(qconj(qparent),qjcs); % qA_conj * qe in notes (qci, i = A or B depending on perspective)

        % get quaternion q s.t. v_child = q * v_jcs * q_conj
        model.joint.(joints{j}).child.(cs{k}).orientation = qprod(qconj(qchild),qjcs); % qB_conj * qe in notes (qci)
        
    end
    
end

end