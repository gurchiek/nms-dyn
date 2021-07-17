function model = scaleTwenteMuscleGeometry(model,options)

% twente reference (Horsman et al. 2007)
if nargin == 1; options = struct(); end
ref = horsman07(options);

% initialize with twente reference
model.muscle = ref.muscle;
model.bodyContour = ref.bodyContour;
model.ligament = ref.ligament;

% scale factors
scaleFactor.pelvis = vecnorm(mean([model.marker.right_asis.position, model.marker.left_asis.position],2) - model.joint.hip.position) / ...
                     vecnorm(mean([ref.marker.right_asis.position, ref.marker.left_asis.position],2) - ref.joint.hip.position);
scaleFactor.thigh = model.segment.thigh.length / ref.segment.thigh.length;
scaleFactor.patella = 1;
scaleFactor.shank = model.segment.shank.length / ref.segment.shank.length;
scaleFactor.foot = vecnorm(mean([model.marker.right_metatarsal1.position, model.marker.right_metatarsal5.position],2) - model.joint.ankle.position) / ...
                   vecnorm(mean([ref.marker.right_metatarsal1.position, ref.marker.right_metatarsal5.position],2) - ref.joint.ankle.position);

scaleMatrix.pelvis = scaleFactor.pelvis * eye(3);
scaleMatrix.thigh = diag([1 scaleFactor.thigh 1]);
scaleMatrix.patella = eye(3);
scaleMatrix.shank = diag([1 scaleFactor.shank 1]);
scaleMatrix.foot = diag([1 scaleFactor.foot 1]);

% scale patellar ligament
model.ligament.patellar.length = model.ligament.patellar.length * scaleFactor.shank;
model.ligament.patellar.local.anatomical.insertion.position = model.ligament.patellar.local.anatomical.insertion.position * scaleFactor.shank;

% twente coord system for reference
model = anatomicalCoordinateSystem(model);
model = patellaModel(model,model);

% for each muscle
msc = ref.muscleNames;
for m = 1:ref.nMuscles
    
    % average origin 
    seg = ref.muscle.(msc{m}).local.anatomical.origin.segment;
    refOrigin = ref.muscle.(msc{m}).local.anatomical.origin.position;
    
    % scale and get global
    p = model.segment.(seg).anatomical.position;
    q = model.segment.(seg).anatomical.orientation;
    model.muscle.(msc{m}).local.anatomical.origin.position = scaleMatrix.(seg) * refOrigin;
    model.muscle.(msc{m}).origin.position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.origin.position);
    
    % average insertion 
    seg = ref.muscle.(msc{m}).local.anatomical.insertion.segment;
    refInsertion = ref.muscle.(msc{m}).local.anatomical.insertion.position;
    
    % scale and get global
    p = model.segment.(seg).anatomical.position;
    q = model.segment.(seg).anatomical.orientation;
    model.muscle.(msc{m}).local.anatomical.insertion.position = scaleMatrix.(seg) * refInsertion;
    model.muscle.(msc{m}).insertion.position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.insertion.position);
    
    % for each element
    for e = 1:ref.muscle.(msc{m}).nElements
    
        % origin 
        seg = ref.muscle.(msc{m}).local.anatomical.element(e).origin.segment;
        refOrigin = ref.muscle.(msc{m}).local.anatomical.element(e).origin.position;

        % scale and get global
        p = model.segment.(seg).anatomical.position;
        q = model.segment.(seg).anatomical.orientation;
        model.muscle.(msc{m}).local.anatomical.element(e).origin.position = scaleMatrix.(seg) * refOrigin;
        model.muscle.(msc{m}).element(e).origin.position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.element(e).origin.position);

        % insertion 
        seg = ref.muscle.(msc{m}).local.anatomical.element(e).insertion.segment;
        refInsertion = ref.muscle.(msc{m}).local.anatomical.element(e).insertion.position;

        % scale and get global
        p = model.segment.(seg).anatomical.position;
        q = model.segment.(seg).anatomical.orientation;
        model.muscle.(msc{m}).local.anatomical.element(e).insertion.position = scaleMatrix.(seg) * refInsertion;
        model.muscle.(msc{m}).element(e).insertion.position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.element(e).insertion.position);
        
    end
    
    % for each via point
    n = ref.muscle.(msc{m}).nViaPoints;
    if n > 0
        for k = 1:n

            % scale and get global
            seg = ref.muscle.(msc{m}).local.anatomical.viaPoint(k).segment;
            p = model.segment.(seg).anatomical.position;
            q = model.segment.(seg).anatomical.orientation;
            model.muscle.(msc{m}).local.anatomical.viaPoint(k).position = scaleMatrix.(seg) * ref.muscle.(msc{m}).local.anatomical.viaPoint(k).position;
            model.muscle.(msc{m}).viaPoint(k).position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.viaPoint(k).position);

        end
    end
    
end

% local/global femoral condyle
pref = ref.segment.(ref.bodyContour.femoralCondyle.segment).anatomical.position;
qref = ref.segment.(ref.bodyContour.femoralCondyle.segment).anatomical.orientation;
pmdl = model.segment.(ref.bodyContour.femoralCondyle.segment).anatomical.position;
qmdl = model.segment.(ref.bodyContour.femoralCondyle.segment).anatomical.orientation;
model.bodyContour.femoralCondyle.local.anatomical.axis = qrot(qref,ref.bodyContour.femoralCondyle.axis,'inverse');
model.bodyContour.femoralCondyle.local.anatomical.position = qrot(qref,scaleMatrix.(ref.bodyContour.femoralCondyle.segment) * (ref.bodyContour.femoralCondyle.position - pref),'inverse');
model.bodyContour.femoralCondyle.axis = qrot(qmdl,model.bodyContour.femoralCondyle.local.anatomical.axis);
model.bodyContour.femoralCondyle.position = pmdl + qrot(qmdl,model.bodyContour.femoralCondyle.local.anatomical.position);

% get mtu length
for m = 1:ref.nMuscles; model = getLengthMTU(model,msc{m},model); end

% get knee/ankle flexion moment arm
model = getKneeFlexionMomentArm5(model,model);
model = getAnkleFlexionMomentArm5(model,model);

% scale optimal fiber length using ratio lmtu_model / lmtu_reference
% length in static pose
% for each muscle
for m = 1:ref.nMuscles
    ratio = model.muscle.(msc{m}).mtu.length / ref.muscle.(msc{m}).mtu.length;
    model.muscle.(msc{m}).optimalFiberLength = ratio * model.muscle.(msc{m}).optimalFiberLength;
    model.muscle.(msc{m}).tendonSlackLength = model.muscle.(msc{m}).mtu.length - model.muscle.(msc{m}).optimalFiberLength * cos(model.muscle.(msc{m}).phi0);
end

end