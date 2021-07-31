function model = twenteTriadCoordinateSystem(model)

% builds orthogonal triad for pelvis, thigh, shank, foot, based on bony
% anatomy, joint positions, and joint axes from Horsman et al. 2007

% pelvis
model.segment.pelvis.twenteTriad.position = model.joint.hip.position;
model.segment.pelvis.twenteTriad.basis(3).vector = normalize(model.marker.right_asis.position - model.marker.left_asis.position,1,'norm');
yhat = normalize(cross(mean([model.marker.right_psis.position, model.marker.left_psis.position],2) - model.marker.right_asis.position,model.segment.pelvis.twenteTriad.basis(3).vector),1,'norm');
model.segment.pelvis.twenteTriad.basis(1).vector = normalize(cross(yhat,model.segment.pelvis.twenteTriad.basis(3).vector),1,'norm');
model.segment.pelvis.twenteTriad.basis(2).vector = normalize(cross(model.segment.pelvis.twenteTriad.basis(3).vector,model.segment.pelvis.twenteTriad.basis(1).vector),1,'norm');

% thigh
model.segment.thigh.twenteTriad.position = model.joint.knee.position; % model.joint.hip.position
model.segment.thigh.twenteTriad.basis(3).vector = model.joint.knee.flexion.axis;
model.segment.thigh.twenteTriad.basis(1).vector = normalize(cross(model.joint.hip.position - model.joint.knee.position,model.joint.knee.flexion.axis),1,'norm');
model.segment.thigh.twenteTriad.basis(2).vector = normalize(cross(model.segment.thigh.twenteTriad.basis(3).vector, model.segment.thigh.twenteTriad.basis(1).vector),1,'norm');

% shank
model.segment.shank.twenteTriad.position = model.joint.knee.position;
model.segment.shank.twenteTriad.basis(3).vector = model.joint.knee.flexion.axis;
model.segment.shank.twenteTriad.basis(1).vector = normalize(cross(model.joint.knee.position - model.joint.ankle.position,model.joint.knee.flexion.axis),1,'norm');
model.segment.shank.twenteTriad.basis(2).vector = normalize(cross(model.segment.shank.twenteTriad.basis(3).vector, model.segment.shank.twenteTriad.basis(1).vector),1,'norm');

% foot
model.segment.foot.twenteTriad.position = model.joint.ankle.position;
% model.segment.foot.twenteTriad.basis(1).vector = normalize(mean([model.marker.right_metatarsal5.position,model.marker.right_metatarsal1.position],2) - model.joint.ankle.position,1,'norm');
% yhat = normalize(cross(model.marker.right_metatarsal5.position - model.joint.ankle.position, model.marker.right_metatarsal1.position - model.joint.ankle.position));
% model.segment.foot.twenteTriad.basis(3).vector = normalize(cross(model.segment.foot.twenteTriad.basis(1).vector,yhat),1,'norm');
% model.segment.foot.twenteTriad.basis(2).vector = normalize(cross(model.segment.foot.twenteTriad.basis(3).vector,model.segment.foot.twenteTriad.basis(1).vector),1,'norm');
model.segment.foot.twenteTriad.basis(1).vector = normalize(mean([model.marker.right_metatarsal5.position,model.marker.right_metatarsal1.position],2) - model.marker.right_heel.position,1,'norm');
model.segment.foot.twenteTriad.basis(3).vector = normalize(cross(model.segment.foot.twenteTriad.basis(1).vector,model.joint.ankle.position - model.marker.right_heel.position),1,'norm');
model.segment.foot.twenteTriad.basis(2).vector = normalize(cross(model.segment.foot.twenteTriad.basis(3).vector,model.segment.foot.twenteTriad.basis(1).vector),1,'norm');

% orientation
seg = fieldnames(model.segment);
for k = 1:length(seg); model.segment.(seg{k}).twenteTriad.orientation = convdcm([model.segment.(seg{k}).twenteTriad.basis(1).vector, model.segment.(seg{k}).twenteTriad.basis(2).vector, model.segment.(seg{k}).twenteTriad.basis(3).vector],'q'); end

end