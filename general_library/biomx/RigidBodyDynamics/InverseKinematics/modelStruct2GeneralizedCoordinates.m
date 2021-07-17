function [q,qname] = modelStruct2GeneralizedCoordinates(model,body,cs)

% returns vector of generalized coordinates given input nms model struct,
% and nms body struct where each segment has 7 gen coords and the first 3
% correspond to 3 translational dof (global segment position) and the other
% 4 correspond to 4 rotation dog (segment quaternion orientation) such that
% v_world = quaternion * v_body * quaternion_conjugate. The first 7 gen
% coords correspond to segment index 1, the second 7 correspond to segment
% index 2, etc. cs specifies the coordinate system name as per
% body.segment.(segmentName).(cs).orientation and
% body.segment.(segmentName).(cs).position

% segment indices
segind = model.segmentIndices;

% num frames
nframes = size(body.segment.(modelIndex2Segment(model,1)).(cs).position,2);

% init
q = zeros(7*length(segind),nframes);
qname = cell(7*length(segind),1);

% for each segment
for s = 1:length(segind)
    
    % segment position
    q(7*s-6:7*s-4,:) = body.segment.(modelIndex2Segment(model,s)).(cs).position;
    for k = 1:3; qname{7*s-7+k} = [modelIndex2Segment(model,s) '_p' num2str(k)]; end
    
    % segment orientation
    % q is s.t. v_world = q * v_s * q_conj
    q(7*s-3:7*s,:) = body.segment.(modelIndex2Segment(model,s)).(cs).orientation;
    for k = 1:4; qname{7*s-4+k} = [modelIndex2Segment(model,s) '_q' num2str(k)]; end
    
end

end