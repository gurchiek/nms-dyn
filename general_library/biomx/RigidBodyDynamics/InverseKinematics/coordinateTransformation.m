function body = coordinateTransformation(model,body,cs1,cs2)

% gets orientation and position of coordinate system cs2 given orientation
% and position of coordinate system cs1. Does so for each segment.
% Configuration of both cs1 and cs2 for each segment must be specified in
% reference configuration (model).

% if cs1 velocity/acceleration/angularVelocity/angularAcceleration are
% specified then these also are transformed

% angularVelocity/angularAcceleration are expressed in the body frame

% for each segment
seg = model.segmentNames;
for s = 1:length(seg)
    
    % get model frame 1 and frame 2
    ref1 = model.segment.(seg{s}).(cs1);
    ref2 = model.segment.(seg{s}).(cs2);
    
    % get body frame 1
    b1 = body.segment.(seg{s}).(cs1);
    
    % get constant quaternion st v1 = q * v2 * q_conj
    q = qprod(qconj(ref1.orientation),ref2.orientation);
    
    % get constant vector pointing from f1 origin to f2 origin in ref1
    p = qrot(ref1.orientation,ref2.position - ref1.position,'inverse');
    
    % get body frame 2
    body.segment.(seg{s}).(cs2).orientation = qprod(b1.orientation,q);
    body.segment.(seg{s}).(cs2).position = b1.position + qrot(b1.orientation,p);
    
    % transform angular velocity?
    if isfield(b1,'angularVelocity')
        body.segment.(seg{s}).(cs2).angularVelocity = qrot(q,b1.angularVelocity,'inverse');
    end
    
    % transform angular acceleration?
    if isfield(b1,'angularAcceleration')
        body.segment.(seg{s}).(cs2).angularAcceleration = qrot(q,b1.angularAcceleration,'inverse');
    end
    
    % transform velocity?
    if isfield(b1,'angularVelocity') && isfield(b1,'velocity')
        pmult = repmat(p,[1 size(b1.angularVelocity,2)]);
        body.segment.(seg{s}).(cs2).velocity = b1.velocity + qrot(b1.orientation,cross(b1.angularVelocity,pmult));
    end
    
    % transform acceleration?
    if isfield(b1,'angularVelocity') && isfield(b1,'acceleration') && isfield(b1,'angularAcceleration')
        body.segment.(seg{s}).(cs2).acceleration = b1.acceleration + qrot(b1.orientation,cross(b1.angularAcceleration,pmult)) + qrot(b1.orientation,cross(b1.angularVelocity,cross(b1.angularVelocity,pmult)));
    end
    
end

end