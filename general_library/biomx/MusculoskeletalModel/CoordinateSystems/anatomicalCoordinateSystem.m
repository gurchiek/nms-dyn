function model = anatomicalCoordinateSystem(model,options)

% builds coordinate system with long axes as defined in deleva. ML axes for
% thigh and shank defined by knee joint axis. pelvis frame defined as in
% isb standards. Long axis of foot (x) connects heel to mid metatarsal,
% vertical (y) defines plane containing heel and 1st/5th metatarsal, z
% orthogonalizes (see ren 08). built in way that horsman 2007 bony
% landmarks can be used

side = options.side;
sideFlag = 1;
if strcmp(side,'left'); sideFlag = -1; end

% anatomical points
midmeta = mean([model.marker.([side '_metatarsal1']).position,model.marker.([side '_metatarsal5']).position],2);
midmal = mean([model.marker.([side '_medial_malleolus']).position,model.marker.([side '_lateral_malleolus']).position],2);
midcon = mean([model.marker.([side '_medial_tibial_condyle']).position,model.marker.([side '_lateral_tibial_condyle']).position],2);
midepi = mean([model.marker.([side '_med_femoral_epicondyle']).position,model.marker.([side '_lat_femoral_epicondyle']).position],2);
midpsis = mean([model.marker.right_psis.position,model.marker.left_psis.position],2);

% foot
model.segment.([side '_foot']).anatomical.position = model.joint.([side '_ankle']).position;
model.segment.([side '_foot']).anatomical.basis(1).vector = normc(midmeta - model.marker.([side '_heel']).position);
model.segment.([side '_foot']).anatomical.basis(2).vector = sideFlag * normc(cross(model.marker.([side '_metatarsal5']).position - model.marker.([side '_heel']).position, model.segment.([side '_foot']).anatomical.basis(1).vector));
model.segment.([side '_foot']).anatomical.basis(3).vector = normc(cross(model.segment.([side '_foot']).anatomical.basis(1).vector,model.segment.([side '_foot']).anatomical.basis(2).vector));
model.segment.([side '_foot']).anatomical.orientation = convdcm([model.segment.([side '_foot']).anatomical.basis(1).vector, model.segment.([side '_foot']).anatomical.basis(2).vector, model.segment.([side '_foot']).anatomical.basis(3).vector],'q');

% position is ankle jc projected onto foot sagittal plane
model.segment.([side '_foot']).anatomical.position = qrot(model.segment.([side '_foot']).anatomical.orientation,model.joint.([side '_ankle']).position - model.marker.([side '_heel']).position,'inverse');
model.segment.([side '_foot']).anatomical.position(3) = 0;
model.segment.([side '_foot']).anatomical.position = model.marker.([side '_heel']).position + qrot(model.segment.([side '_foot']).anatomical.orientation,model.segment.([side '_foot']).anatomical.position);

% shank
model.segment.([side '_shank']).anatomical.position = midmal;
model.segment.([side '_shank']).anatomical.basis(2).vector = normc(midcon - midmal);
model.segment.([side '_shank']).anatomical.basis(1).vector = normc(cross(model.segment.([side '_shank']).anatomical.basis(2).vector,model.joint.([side '_knee']).flexion.axis));
model.segment.([side '_shank']).anatomical.basis(3).vector = normc(cross(model.segment.([side '_shank']).anatomical.basis(1).vector,model.segment.([side '_shank']).anatomical.basis(2).vector));
model.segment.([side '_shank']).anatomical.orientation = convdcm([model.segment.([side '_shank']).anatomical.basis(1).vector, model.segment.([side '_shank']).anatomical.basis(2).vector, model.segment.([side '_shank']).anatomical.basis(3).vector],'q');

% thigh
model.segment.([side '_thigh']).anatomical.position = midepi;

% mid epicondyle to hip jc
y = model.joint.([side '_hip']).position - midepi;

% project onto shank sagittal plane
y = y - model.segment.([side '_shank']).anatomical.basis(3).vector * (model.segment.([side '_shank']).anatomical.basis(3).vector' * y);

% orthogonalize
model.segment.([side '_thigh']).anatomical.basis(2).vector = normc(y);
model.segment.([side '_thigh']).anatomical.basis(1).vector = normc(cross(y,model.segment.([side '_shank']).anatomical.basis(3).vector));
model.segment.([side '_thigh']).anatomical.basis(3).vector = normc(cross(model.segment.([side '_thigh']).anatomical.basis(1).vector,model.segment.([side '_thigh']).anatomical.basis(2).vector));
model.segment.([side '_thigh']).anatomical.orientation = convdcm([model.segment.([side '_thigh']).anatomical.basis(1).vector, model.segment.([side '_thigh']).anatomical.basis(2).vector, model.segment.([side '_thigh']).anatomical.basis(3).vector],'q');

% thigh
model.segment.pelvis.anatomical.position = model.joint.([side '_hip']).position;
model.segment.pelvis.anatomical.basis(3).vector = normc(model.marker.right_asis.position - model.marker.left_asis.position);
model.segment.pelvis.anatomical.basis(2).vector = normc(cross(midpsis - model.marker.left_asis.position,model.segment.pelvis.anatomical.basis(3).vector));
model.segment.pelvis.anatomical.basis(1).vector = normc(cross(model.segment.pelvis.anatomical.basis(2).vector,model.segment.pelvis.anatomical.basis(3).vector));
model.segment.pelvis.anatomical.orientation = convdcm([model.segment.pelvis.anatomical.basis(1).vector, model.segment.pelvis.anatomical.basis(2).vector, model.segment.pelvis.anatomical.basis(3).vector],'q');

%% get local marker positions and generalized coordinates

model = getLocalMarkerPositions(model,'anatomical');
model.generalizedCoordinates.anatomical.position = modelStruct2GeneralizedCoordinates(model,model,'anatomical');

end