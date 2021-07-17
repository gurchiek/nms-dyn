function model = scaleTwenteMuscleGeometry2(model,options)

% same as scaleTwenteMuscleGeometry except VI, VL, VM, and RF local
% insertions are moved posteriorly 1 cm to better align moment arm data
% with literature. Further, SM and ST insertion and tibia VPs are moved
% down 3 cm as this was found to ensure the SM/ST moment arm-knee angle
% relationships match literature data (e.g. peaking around 40 cm, see
% Arnold et al. 2010; moment arms between 1 and 9 cm, see Herzog and Read
% 1993)

% currently works only for right leg

% local geometry all expressed relative to anatomicalCoordinateSystem
% because this can be informed using horsman 07 data

% twente reference (Horsman et al. 2007)
if nargin == 1; options = struct(); end
ref = horsman07(options);

% move insertion of knee extensors back 1 cm locally
msc = {'right_vastusLateralis','right_vastusMedialis','right_vastusIntermedius','right_rectusFemoris'};
for m = 1:4
    ref.muscle.(msc{m}).local.anatomical.insertion.position(1) = ref.muscle.(msc{m}).local.anatomical.insertion.position(1) - 0.01;
    for e = 1:length(ref.muscle.(msc{m}).local.anatomical.element)
        ref.muscle.(msc{m}).local.anatomical.element(e).insertion.position(1) = ref.muscle.(msc{m}).local.anatomical.element(e).insertion.position(1) - 0.01;
    end
end

% move tibia insertion and VPs of medial hamstrings down 3 cm
msc = {'right_semimembranosus','right_semitendinosus'};
for m = 1:2
    ref.muscle.(msc{m}).local.anatomical.insertion.position(2) = ref.muscle.(msc{m}).local.anatomical.insertion.position(2) - 0.03;
    for e = 1:length(ref.muscle.(msc{m}).local.anatomical.element)
        ref.muscle.(msc{m}).local.anatomical.element(e).insertion.position(2) = ref.muscle.(msc{m}).local.anatomical.element(e).insertion.position(2) - 0.03;
    end
    nvp = ref.muscle.(msc{m}).nViaPoints;
    if nvp > 0
        for vp = 1:nvp
            ref.muscle.(msc{m}).local.anatomical.viaPoint(vp).position(2) = ref.muscle.(msc{m}).local.anatomical.viaPoint(vp).position(2) - 0.03;
        end
    end
end

% initialize with twente reference
model.muscle = ref.muscle;
model.bodyContour = ref.bodyContour;
model.ligament = ref.ligament;

% scale factors for adjusting origin/insertion
% pelvis based on rasis to lasis length, thigh/shank based on segment
% lengths, foot bbased on distance mid metarsal1/5 to ankle jc
scaleFactor.pelvis = vecnorm(mean([model.marker.right_asis.position, model.marker.left_asis.position],2) - model.joint.right_hip.position) / ...
                     vecnorm(mean([ref.marker.right_asis.position, ref.marker.left_asis.position],2) - ref.joint.right_hip.position);
scaleFactor.right_thigh = model.segment.right_thigh.length / ref.segment.right_thigh.length;
scaleFactor.right_patella = 1;
scaleFactor.right_shank = model.segment.right_shank.length / ref.segment.right_shank.length;
scaleFactor.right_foot = vecnorm(mean([model.marker.right_metatarsal1.position, model.marker.right_metatarsal5.position],2) - model.joint.right_ankle.position) / ...
                   vecnorm(mean([ref.marker.right_metatarsal1.position, ref.marker.right_metatarsal5.position],2) - ref.joint.right_ankle.position);

% only scale thigh/shank/foot longitudinally, scale all pelvis dimensions
scaleMatrix.pelvis = scaleFactor.pelvis * eye(3);
scaleMatrix.right_thigh = diag([1 scaleFactor.right_thigh 1]);
scaleMatrix.right_patella = eye(3);
scaleMatrix.right_shank = diag([1 scaleFactor.right_shank 1]);
scaleMatrix.right_foot = diag([1 scaleFactor.right_foot 1]);

% scale patellar ligament
model.ligament.right_patellar.length = model.ligament.right_patellar.length * scaleFactor.right_shank;
model.ligament.right_patellar.local.anatomical.insertion.position = model.ligament.right_patellar.local.anatomical.insertion.position * scaleFactor.right_shank;

% twente coord system for reference
model = anatomicalCoordinateSystem(model,struct('side','right'));
model = patellaModel(model,model,'right');

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
    model.muscle.(msc{m}).origin.position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.origin.position); % global
    
    % average insertion 
    seg = ref.muscle.(msc{m}).local.anatomical.insertion.segment;
    refInsertion = ref.muscle.(msc{m}).local.anatomical.insertion.position;
    
    % scale and get global
    p = model.segment.(seg).anatomical.position;
    q = model.segment.(seg).anatomical.orientation;
    model.muscle.(msc{m}).local.anatomical.insertion.position = scaleMatrix.(seg) * refInsertion;
    model.muscle.(msc{m}).insertion.position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.insertion.position); % global
    
    % now scale each element
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
            model.muscle.(msc{m}).viaPoint(k).position = p + qrot(q,model.muscle.(msc{m}).local.anatomical.viaPoint(k).position); % global

        end
    end
    
end

% local/global femoral condyle
pref = ref.segment.(ref.bodyContour.right_femoralCondyle.segment).anatomical.position;
qref = ref.segment.(ref.bodyContour.right_femoralCondyle.segment).anatomical.orientation;
pmdl = model.segment.(ref.bodyContour.right_femoralCondyle.segment).anatomical.position;
qmdl = model.segment.(ref.bodyContour.right_femoralCondyle.segment).anatomical.orientation;
model.bodyContour.right_femoralCondyle.local.anatomical.axis = qrot(qref,ref.bodyContour.right_femoralCondyle.axis,'inverse'); % condylar axis in segment frame
model.bodyContour.right_femoralCondyle.local.anatomical.position = qrot(qref,scaleMatrix.(ref.bodyContour.right_femoralCondyle.segment) * (ref.bodyContour.right_femoralCondyle.position - pref),'inverse'); % points from segment (thigh) to condyle position lcoally
model.bodyContour.right_femoralCondyle.axis = qrot(qmdl,model.bodyContour.right_femoralCondyle.local.anatomical.axis); % global condylar axis
model.bodyContour.right_femoralCondyle.position = pmdl + qrot(qmdl,model.bodyContour.right_femoralCondyle.local.anatomical.position); % global condylar position

% get mtu length
for m = 1:ref.nMuscles; model = getLengthMTU(model,msc{m},model); end

% get knee/ankle flexion moment arm
model = getKneeFlexionMomentArm5(model,model,'right');
model = getAnkleFlexionMomentArm5(model,model,'right');

% uncomment to keep opt fib len and ten slack len ratio same
% % scale optimal fiber length using ratio lmtu_model / lmtu_reference
% % length in static pose
% % for each muscle
% for m = 1:ref.nMuscles
%     ratio = model.muscle.(msc{m}).mtu.length / ref.muscle.(msc{m}).mtu.length;
%     model.muscle.(msc{m}).optimalFiberLength = ratio * model.muscle.(msc{m}).optimalFiberLength;
%     model.muscle.(msc{m}).tendonSlackLength = model.muscle.(msc{m}).mtu.length - model.muscle.(msc{m}).optimalFiberLength * cos(model.muscle.(msc{m}).phi0);
% end

end