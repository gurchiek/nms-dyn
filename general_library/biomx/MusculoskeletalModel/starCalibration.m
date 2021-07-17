function model = starCalibration(model,star,options)

% Star Calibration trial is a functional calibration trial specific to our
% lab wherein all dof of the hip are excited, the knee is brought through
% several flexions/extensions as is the foot as well as circular motions
% for the foot. The input star struct should contain inverse kinematics
% analysis data in star.(analysisName).body.segment.(segmentName).(coordinateSystem).

% updates nms model struct to include:
%   hip.position = 3x1 global hip joint center in reference configuration
%   ankle.position = 3x1 global ankle joint center in reference configuration
%   knee.position = 3x1 global knee joint center in reference configuration
%   knee.flexion.axis = 3x1 unit vector specifying knee joint axis in global frame in reference configuration, points right


% unpack
cs = options.coordinateSystem;
side = options.side;
anl = options.analysisName;

%% hip jc

% get indices of hip motion during star
getind = 1;
if isfield(options.indices,[side '_hip'])
    if ~isempty(options.indices.([side '_hip']))
        ind = options.indices.([side '_hip']);
        getind = 0;
    end
end
if getind
    relvel = star.(anl).body.segment.pelvis.(cs).angularVelocity - qrot(qconj(star.(anl).body.segment.pelvis.(cs).orientation),qrot(star.(anl).body.segment.([side '_thigh']).(cs).orientation,star.(anl).body.segment.([side '_thigh']).(cs).angularVelocity));
    if ~any(isnan(relvel)); relvel = bwfilt(vecnorm(relvel),3,star.samplingFrequency,'low',4); end
    ind = getIndex(relvel,2,{'Click at start of hip rotations','Click at end of hip rotations'});
    ind = ind(1):ind(2);
    fprintf('-Hip functional calibration indices: %d, %d\n',ind(1),ind(end))
end

% pivot
r1 = convq(star.(anl).body.segment.pelvis.(cs).orientation(:,ind),'dcm');
r2 = convq(star.(anl).body.segment.([side '_thigh']).(cs).orientation(:,ind),'dcm');
p1 = star.(anl).body.segment.pelvis.(cs).position(:,ind); % if cs is isb then this is first estimate of hip jc (e.g. hara regression eq)
p2 = modelStruct2GeneralizedCoordinates(model,star.(anl).body,cs);
p2 = generalizedCoordinates2MarkerPositions(model,p2,{[side '_lat_femoral_epicondyle']},cs);
p2 = p2.([side '_lat_femoral_epicondyle']).position(:,ind);
[c1,c2] = fjcpivot(r1,r2,p1,p2);
c1w = qrot(model.segment.pelvis.(cs).orientation,c1) + model.segment.pelvis.(cs).position;
c2w = qrot(model.segment.([side '_thigh']).(cs).orientation,c2) + model.marker.([side '_lat_femoral_epicondyle']).position;
cw = mean([c1w,c2w],2);

% get c, c1, c2 at each instant in calibration movement
c = qrot(model.segment.pelvis.(cs).orientation,cw - model.segment.pelvis.(cs).position,'inverse');
cinst = dcmrot(r1,c) + p1;
c1inst = dcmrot(r1,c1) + p1;
c2inst = dcmrot(r2,c2) + p2;

% distance between points should be constant, use one that has smallest
% largest variance
rc = max([range(vecnorm(cinst - p1)) range(vecnorm(cinst - p2))]);
rc1 = max([range(vecnorm(c1inst - p1)) range(vecnorm(c1inst - p2))]);
rc2 = max([range(vecnorm(c2inst - p1)) range(vecnorm(c2inst - p2))]);
[minrange,imin] = min([rc rc1 rc2]);
if imin == 1
    hipjc = cw;
    jcsegment = 'mean';
elseif imin == 2
    hipjc = c1w;
    jcsegment = 'parent';
elseif imin == 3
    hipjc = c2w;
    jcsegment = 'child';
end
fprintf('-Hip JC range (if perfect then this will be zero): %f cm, segment: %s\n',minrange * 100,jcsegment);

% report distance between hip jc and regression estimate (if available,
% will be isb pelvis position)
if isfield(model.segment.pelvis,'isb')
    fprintf('-Hip JC distance to regression-based JC: %f cm\n',vecnorm(hipjc-model.segment.pelvis.isb.position)*100)
end

% store
model.joint.([side '_hip']).position = hipjc;

%% ankle jc

getind = 1;
if isfield(options.indices,[side '_ankle'])
    if ~isempty(options.indices.([side '_ankle']))
        ind = options.indices.([side '_ankle']);
        getind = 0;
    end
end
if getind
    relvel = star.(anl).body.segment.([side '_shank']).(cs).angularVelocity - qrot(qconj(star.(anl).body.segment.([side '_shank']).(cs).orientation),qrot(star.(anl).body.segment.([side '_foot']).(cs).orientation,star.(anl).body.segment.([side '_foot']).(cs).angularVelocity));
    if ~any(isnan(relvel)); relvel = bwfilt(vecnorm(relvel),3,star.samplingFrequency,'low',4); end
    ind = getIndex(relvel,2,{'Click at start of ankle rotations','Click at end of ankle rotations'});
    ind = ind(1):ind(2);
    fprintf('-Ankle functional calibration indices: %d, %d\n',ind(1),ind(end))
end

% pivot
r1 = convq(star.(anl).body.segment.([side '_shank']).(cs).orientation(:,ind),'dcm');
r2 = convq(star.(anl).body.segment.([side '_foot']).(cs).orientation(:,ind),'dcm');
p1 = star.(anl).body.segment.([side '_shank']).(cs).position(:,ind);
p2 = star.(anl).body.segment.([side '_foot']).(cs).position(:,ind);
[c1,c2] = fjcpivot(r1,r2,p1,p2);
c1w = qrot(model.segment.([side '_shank']).(cs).orientation,c1) + model.segment.([side '_shank']).(cs).position;
c2w = qrot(model.segment.([side '_foot']).(cs).orientation,c2) + model.segment.([side '_foot']).(cs).position;
cw = mean([c1w,c2w],2);

% get c, c1, c2 at each instant in calibration movement
c = qrot(model.segment.([side '_shank']).(cs).orientation,cw - model.segment.([side '_shank']).(cs).position,'inverse');
cinst = dcmrot(r1,c) + p1;
c1inst = dcmrot(r1,c1) + p1;
c2inst = dcmrot(r2,c2) + p2;

% distance between points should be constant, use one with minimum variable
% distance
rc = max([range(vecnorm(cinst - p1)) range(vecnorm(cinst - p2))]);
rc1 = max([range(vecnorm(c1inst - p1)) range(vecnorm(c1inst - p2))]);
rc2 = max([range(vecnorm(c2inst - p1)) range(vecnorm(c2inst - p2))]);
[minrange,imin] = min([rc rc1 rc2]);
if imin == 1
    anklejc = cw;
    jcsegment = 'mean';
elseif imin == 2
    anklejc = c1w;
    jcsegment = 'parent';
elseif imin == 3
    anklejc = c2w;
    jcsegment = 'child';
end
fprintf('-Ankle JC range (if perfect then this will be zero): %f cm, segment: %s\n',minrange * 100,jcsegment);

% report distance to mid-malleolus as sanity check
midmall = mean([model.marker.([side '_medial_malleolus']).position, model.marker.([side '_lateral_malleolus']).position],2);
fprintf('-Ankle JC distance to mid-malleolus: %f cm\n',vecnorm(anklejc-midmall)*100)

% store
model.joint.([side '_ankle']).position = anklejc;

%% knee jc and hinge axis

getind = 1;
if isfield(options.indices,[side '_knee'])
    if ~isempty(options.indices.([side '_knee']))
        ind = options.indices.([side '_knee']);
        getind = 0;
    end
end
if getind
    relvel = star.(anl).body.segment.([side '_thigh']).(cs).angularVelocity - qrot(qconj(star.(anl).body.segment.([side '_thigh']).(cs).orientation),qrot(star.(anl).body.segment.([side '_shank']).(cs).orientation,star.(anl).body.segment.([side '_shank']).(cs).angularVelocity));
    if ~any(isnan(relvel)); relvel = bwfilt(vecnorm(relvel),3,star.samplingFrequency,'low',4); end
    ind = getIndex(relvel,2,{'Click at start of knee rotations','Click at end of knee rotations'});
    ind = ind(1):ind(2);
    fprintf('-Knee functional calibration indices: %d, %d\n',ind(1),ind(end))
end

% sara/att
r1 = convq(star.(anl).body.segment.([side '_thigh']).(cs).orientation(:,ind),'dcm');
r2 = convq(star.(anl).body.segment.([side '_shank']).(cs).orientation(:,ind),'dcm');
p1 = star.(anl).body.segment.([side '_thigh']).(cs).position(:,ind);
p2 = star.(anl).body.segment.([side '_shank']).(cs).position(:,ind);
[a1,a2,c1,c2] = frasara(r1,r2,p1,p2,[0 0 1]',1e-4);

% get in world frame
a1world = qrot(model.segment.([side '_thigh']).(cs).orientation,a1);
a2world = qrot(model.segment.([side '_shank']).(cs).orientation,a2);
c1world = qrot(model.segment.([side '_thigh']).(cs).orientation,c1) + model.segment.([side '_thigh']).(cs).position;
c2world = qrot(model.segment.([side '_shank']).(cs).orientation,c2) + model.segment.([side '_shank']).(cs).position;

% get average
cworld = mean([c1world,c2world],2);

% get c, c1, c2 at each instant in calibratio movement
c = qrot(model.segment.([side '_thigh']).(cs).orientation,cworld - model.segment.([side '_thigh']).(cs).position,'inverse');
cinst = dcmrot(r1,c) + p1;
c1inst = dcmrot(r1,c1) + p1;
c2inst = dcmrot(r2,c2) + p2;

% distance between points should be constant, use one with minimum range
rc = max([range(vecnorm(cinst - p1)) range(vecnorm(cinst - p2))]);
rc1 = max([range(vecnorm(c1inst - p1)) range(vecnorm(c1inst - p2))]);
rc2 = max([range(vecnorm(c2inst - p1)) range(vecnorm(c2inst - p2))]);
[minrange,imin] = min([rc rc1 rc2]);
if imin == 1
    kneeAxisPoint = cworld;
    jcsegment = 'mean';
elseif imin == 2
    kneeAxisPoint = c1world;
    jcsegment = 'parent';
elseif imin == 3
    kneeAxisPoint = c2world;
    jcsegment = 'child';
end
fprintf('-Knee JC range (if perfect then this will be zero): %f cm, segment: %s\n',minrange * 100, jcsegment);

% kneeAxisPoint defines point on axis in world
% get in thigh
kneeAxisPoint_thigh = qrot(model.segment.([side '_thigh']).(cs).orientation,kneeAxisPoint - model.segment.([side '_thigh']).(cs).position,'inverse');

% get in world during calibration movement
thigh_point = p1 + dcmrot(r1,kneeAxisPoint_thigh);

% get distance to shank position (should be constant)
distance = vecnorm(thigh_point - p2);

% report
fprintf('-Knee JC in thigh to mid-malleolus in shank during motion should be constant distance (if perfect hinge, femoral condyle well approximated by cylinder, no translational DOF). SD is %f cm and range is %f cm\n',std(distance)*100,range(distance)*100);

% average knee axis is final estimate
kneeAxis = normc(mean([a1world,a2world],2));

% knee center then defined as point on line that is closest to first guess
% first guess in this case will be mean lat/med fem epicondyle
kneeCenter0 = mean([model.marker.([side '_med_femoral_epicondyle']).position,model.marker.([side '_lat_femoral_epicondyle']).position],2);
kneeCenter = kneeAxisPoint + kneeAxis * (kneeCenter0 - kneeAxisPoint)' * kneeAxis;

% report distance to mid-epicondyle as sanity check
fprintf('-Knee JC distance to mid-epicondyle: %f cm\n',vecnorm(kneeCenter-kneeCenter0)*100)

% store
model.joint.([side '_knee']).position = kneeCenter;
model.joint.([side '_knee']).flexion.axis = kneeAxis;

end