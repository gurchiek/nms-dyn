function model = getLocalMuscleGeometry(model,cs)

% multiple attachment elements are averaged and expressed in segment frame
% using coordinate system cs

% for each muscle
muscle = model.muscle;
msc = fieldnames(muscle);
for m = 1:length(msc)
    
    % origin segment
    oseg = muscle.(msc{m}).element(1).origin.segment;
    p = model.segment.(oseg).(cs).position;
    q = model.segment.(oseg).(cs).orientation;
    
    % for each element
    n = muscle.(msc{m}).nElements;
    origin = zeros(3,1);
    for k = 1:n
        
        % update average
        origin = origin + 1/n * muscle.(msc{m}).element(k).origin.position; 
        
        % get local
        muscle.(msc{m}).local.(cs).element(k).origin.position = qrot(q,muscle.(msc{m}).element(k).origin.position - p,'inverse');
        muscle.(msc{m}).local.(cs).element(k).origin.segment = oseg;
        
    end
    
    % store average
    muscle.(msc{m}).origin.position = origin;
    muscle.(msc{m}).origin.segment = oseg;
    
    % get local
    muscle.(msc{m}).local.(cs).origin.position = qrot(q,origin - p,'inverse');
    muscle.(msc{m}).local.(cs).origin.segment = oseg;
    
    % insertion segment
    iseg = muscle.(msc{m}).element(1).insertion.segment;
    p = model.segment.(iseg).(cs).position;
    q = model.segment.(iseg).(cs).orientation;
    
    % for each element
    insertion = zeros(3,1);
    for k = 1:n
        
        % update average
        insertion = insertion + 1/n * muscle.(msc{m}).element(k).insertion.position; 
        
        % get local
        muscle.(msc{m}).local.(cs).element(k).insertion.position = qrot(q,muscle.(msc{m}).element(k).insertion.position - p,'inverse');
        muscle.(msc{m}).local.(cs).element(k).insertion.segment = iseg;
        
    end
    
    % store average
    muscle.(msc{m}).insertion.position = insertion;
    muscle.(msc{m}).insertion.segment = iseg;
    
    % get local
    muscle.(msc{m}).local.(cs).insertion.position = qrot(q,insertion - p,'inverse');
    muscle.(msc{m}).local.(cs).insertion.segment = iseg;
    
    % for each via point
    n = muscle.(msc{m}).nViaPoints;
    if n > 0
        for k = 1:n

            % get local
            seg = muscle.(msc{m}).viaPoint(k).segment;
            p = model.segment.(seg).(cs).position;
            q = model.segment.(seg).(cs).orientation;
            muscle.(msc{m}).local.(cs).viaPoint(k).position = qrot(q,muscle.(msc{m}).viaPoint(k).position - p,'inverse');
            muscle.(msc{m}).local.(cs).viaPoint(k).segment = seg;

        end
    end
    
end

% save
model.muscle = muscle;

end