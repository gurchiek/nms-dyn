function body = patellaModel(model,body,side)

% creates a patella segment for the nms body struct based on knee flexion
% angle (see patellarLigamentAngle())

% modifies following nms body fields
% (1) patellar ligament origin/insertion (global)
% (2) patella anatomical position/orientation/basis vectors

% patellar ligament insertion in anatomical system (shank frame), constant
pli = model.ligament.([side '_patellar']).local.anatomical.insertion.position;

% express relative to global frame
pli = qrot(body.segment.([side '_shank']).anatomical.orientation,pli) + body.segment.([side '_shank']).anatomical.position;
body.ligament.([side '_patellar']).insertion.position = pli;
body.ligament.([side '_patellar']).insertion.segment = 'shank';

% patellar ligament length
pll = model.ligament.([side '_patellar']).length;

% get angle of patellar ligament relative to shank long axis
alpha = patellarLigamentAngle(body.joint.([side '_knee']).flexion.angle); % angle in degrees

% now locate patellar origin as origin of patellar ligament
yshank = qrot(body.segment.([side '_shank']).anatomical.orientation,[0 1 0]');
zshank = qrot(body.segment.([side '_shank']).anatomical.orientation,[0 0 1]');
v = pll * yshank;
q = [repmat(sind(alpha/2),[3 1]) .* -zshank; cosd(alpha/2)];
v = qrot(q,v);
body.segment.([side '_patella']).anatomical.position = pli + v;
body.ligament.([side '_patellar']).origin.position = body.segment.([side '_patella']).anatomical.position; % this adjusts horsman 07 original data by only 1.17 cm
body.ligament.([side '_patellar']).origin.segment = 'patella';

% use shank ML as patella ML
body.segment.([side '_patella']).anatomical.basis(3).vector = zshank;

% based on van Eijden 1985 data, patellar long axis is almost constant 20
% degrees relative to patellar ligament (fig 4)
q = [sind(20/2) * zshank; repmat(cosd(20/2),[1 size(zshank,2)])];
body.segment.([side '_patella']).anatomical.basis(2).vector = normc(qrot(q,v));

% orthogonalize for AP
body.segment.([side '_patella']).anatomical.basis(1).vector = normc(cross(body.segment.([side '_patella']).anatomical.basis(2).vector,body.segment.([side '_patella']).anatomical.basis(3).vector));

% orientation
body.segment.([side '_patella']).anatomical.orientation = convdcm(permute(cat(3,body.segment.([side '_patella']).anatomical.basis(1).vector, body.segment.([side '_patella']).anatomical.basis(2).vector, body.segment.([side '_patella']).anatomical.basis(3).vector),[1 3 2]),'q');

end