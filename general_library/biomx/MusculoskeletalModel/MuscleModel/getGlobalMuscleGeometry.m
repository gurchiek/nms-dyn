function body = getGlobalMuscleGeometry(model,cs,body,options)

% input is nms model and body structs and cs char indicating coordinate
% system for which body segment orientations are specified. Local mtu
% geometry must also be specified for this coordinate system in the nms
% model struct

% options is optional, is used in getLengthMTU to allow low pass filtering
% MTU lengths (see getLengthMTU for details)

% for each muscle this updates (all 3xn global positions):
%   body.muscle.(muscleName).element.(k).origin.position
%   body.muscle.(muscleName).origin.position
%   body.muscle.(muscleName).element.(k).insertion.position
%   body.muscle.(muscleName).insertion.position
%   body.muscle.(muscleName).viaPoint(k).position

% also computes mtu length for each muscle: getLengthMTU()
% getLengthMTU() requires global body contour geometry in nms body struct
% so this must already be specified for each body contour used (e.g. run
% getGlobalBodyContourGeometry() before this function)

% default options
if nargin == 3
    options = struct();
end

% for each muscle
muscle = model.muscle;
msc = fieldnames(muscle);
for m = 1:length(msc)
    
    % origin segment
    oseg = muscle.(msc{m}).element(1).origin.segment;
    p = body.segment.(oseg).(cs).position;
    q = body.segment.(oseg).(cs).orientation;
    
    % for each element
    n = muscle.(msc{m}).nElements;
    for k = 1:n
        
        % get global
        body.muscle.(msc{m}).element(k).origin.position = p + qrot(q,muscle.(msc{m}).local.(cs).element(k).origin.position);
        body.muscle.(msc{m}).element(k).origin.segment = oseg;
        
    end
    
    % average origin in global
    body.muscle.(msc{m}).origin.position = p + qrot(q,muscle.(msc{m}).local.(cs).origin.position);
    body.muscle.(msc{m}).origin.segment = oseg;
    
    % insertion segment
    iseg = muscle.(msc{m}).element(1).insertion.segment;
    p = body.segment.(iseg).(cs).position;
    q = body.segment.(iseg).(cs).orientation;
    
    % for each element
    for k = 1:n
        
        % get global
        body.muscle.(msc{m}).element(k).insertion.position = p + qrot(q,muscle.(msc{m}).local.(cs).element(k).insertion.position);
        body.muscle.(msc{m}).element(k).insertion.segment = iseg;
        
    end
    
    % average insertion in global
    body.muscle.(msc{m}).insertion.position = p + qrot(q,muscle.(msc{m}).local.(cs).insertion.position);
    body.muscle.(msc{m}).insertion.segment = iseg;
    
    % for each via point
    n = muscle.(msc{m}).nViaPoints;
    if n > 0
        for k = 1:n

            % get global
            seg = muscle.(msc{m}).viaPoint(k).segment;
            p = body.segment.(seg).(cs).position;
            q = body.segment.(seg).(cs).orientation;
            body.muscle.(msc{m}).viaPoint(k).position = p + qrot(q,muscle.(msc{m}).local.(cs).viaPoint(k).position);
            body.muscle.(msc{m}).viaPoint(k).segment = iseg;

        end
    end
    
    % get length
    body = getLengthMTU(model,msc{m},body,options);
    
end

end