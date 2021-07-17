function model = getLocalJointPositions(model,cs)

% INPUTS
% model - nms model struct
% cs - coordinate system name (e.g. 'isb')

% updates following joint fields:
%
%   joint.(jointName).positionRelative2ParentJoint.(cs) = 3x1 vector 
%           pointing from the position of the parent joint (or position of 
%           parent segment if root segment) to jointName position in the 
%           parent segment frame specified by cs. Is a constant vector
%           under a rigid body assumption.
%
%   joint.(jointName).parent.position.(cs) = 3x1 vector pointing from
%           origin of parent segment to jointName position in the parent
%           segment frame specified by cs. Is a constant vector under a
%           rigid body assumption.
%
%   joint.(jointName).child.position.(cs) = 3x1 vector pointing from
%           origin of child segment to jointName position in the child
%           segment frame specified by cs. Is a constant vector under a
%           rigid body assumption.

% updates following to segment fields:
%
%   segment.(segmentName).parent.jointPosition.(cs) = 3x1 vector pointing 
%           from segment origin to parent joint center in segment frame
%
%   segment.(segmentName).child(j).jointPosition.(cs) = 3x1 vector pointing 
%           from segment origin to each child joint center in segment
%           frame (in this case child j)


%% update joint fields

% for each joint
jind = model.jointIndices;
cnx = model.jointConnections;
for i = 1:length(jind)
    
    % current joint name
    currjnt = modelIndex2Joint(model,i);
    
    % current global joint position
    jc2 = model.joint.(currjnt).position;
    
    % get parent segment index
    pind = cnx(i,1);
    
    % get parent segment
    pseg = modelIndex2Segment(model,pind);
    
    % get quaternion that rotates parent segment to world
    q = model.segment.(pseg).(cs).orientation;
    
    % if root segment
    if pind == 1
        
        % get global position of origin of parent segment
        jc1 = model.segment.(pseg).(cs).position;
        
    else
        
        % get global position of joint center of parent joint
        parentJoint = model.joint.(currjnt).parent.joint; % joint name
        jc1 = model.joint.(parentJoint).position;
        
    end
    
    % get vector pointing from the position of the parent joint (ie jc1 or position of parent segment if root segment) to joint i in the parent segment frame for joint i 
    model.joint.(currjnt).positionRelative2ParentJoint.(cs) = qrot(q,jc2 - jc1,'inverse');
    
    % get vector pointing from parent segment origin to joint center in parent frame
    model.joint.(currjnt).parent.position.(cs) = qrot(q,jc2 - model.segment.(pseg).(cs).position,'inverse');
    
    % get child segment
    cind = cnx(i,2);
    cseg = modelIndex2Segment(model,cind);
    
    % get vector pointing from child segment origin to joint center in child frame
    model.joint.(currjnt).child.position.(cs) = qrot(model.segment.(cseg).(cs).orientation,jc2 - model.segment.(cseg).(cs).position,'inverse');
    
end

%% update segment fields

% for each segment
sind = model.segmentIndices;
for i = 1:length(sind)
    
    % segment name
    seg = modelIndex2Segment(model,i);
    
    % segment orientation, rotates segment to world
    q = model.segment.(seg).(cs).orientation;
        
    % segment origin
    p1 = model.segment.(seg).(cs).position;
    
    % get vector pointing from segment origin to parent joint center in segment frame
    if ~isempty(model.segment.(seg).parent.joint)
        p2 = model.joint.(model.segment.(seg).parent.joint).position;
        model.segment.(seg).parent.jointPosition.(cs) = qrot(q,p2-p1,'inverse');
    end
    
    % get vector pointing from segment origin to each child joint center in segment frame
    if ~isempty(model.segment.(seg).child(1).joint)
        for j = 1:numel(model.segment.(seg).child)
            p2 = model.joint.(model.segment.(seg).child(j).joint).position;
            model.segment.(seg).child(j).jointPosition.(cs) = qrot(q,p2-p1,'inverse');
        end
    end
    
end

end