function [cost, grad, hessian, errvec, errjac, errjac2, W, inan, errvec_dot, grad_dot] = modelObjectiveFunction(x,model,trial,frame,cs)

% objective function for constrained inverse kinematics and use in fmincon
% see andersen et al. 09

% names of measured markers
mkr = fieldnames(trial.marker);
nmkr = length(mkr);

% weight matrix
W = zeros(3*nmkr);

%
jac2 = qrotjac2;

% error jacobian matrix: d(err)/dx
errjac = zeros(3*nmkr,7 * model.nSegments);

% partials of errjac: d(errjac)/dx
errjac2(length(x),length(x)) = struct();
for i = 1:length(x)
    for j = i:length(x)
        errjac2(i,j).vec = zeros(3*nmkr,1); % d/dxi * d(err)/dxj
    end
end

% error vector
errvec = zeros(3*nmkr,1);
errvec_dot = errvec;

% for each marker
inan = false(3*nmkr,1);
vnan = inan;
for m = 1:nmkr
    
    ind = 3*m-2:3*m;
    
    % get measured marker position
    m_meas = trial.marker.(mkr{m}).position(:,frame);
    errvec_dot(ind) = trial.marker.(mkr{m}).velocity(:,frame);
    
    % isnan?
    inan(ind) = isnan(m_meas);
    vnan(ind) = isnan(errvec_dot(ind));
    
    % continue if not
    if ~any(inan(ind))
        
        % get marker segment and segment index
        seg = modelMarker2Segment(model,mkr{m});
        iseg = modelSegment2Index(model,seg);

        % get marker position in (cs) frame
        v = model.segment.(seg).marker.(mkr{m}).position.(cs);

        % get seg origin position and orientation
        ip = segmentIndex2GeneralizedCoordinateIndices(iseg,'translation'); %7*iseg - 6 : 7*iseg - 4;
        iq = segmentIndex2GeneralizedCoordinateIndices(iseg,'rotation'); %7*iseg - 3 : 7*iseg;
        p = x(ip);
        q = x(iq);

        % transform
        m_est = p + qrot(q,v);
        
        % error
        errvec(ind) = m_est - m_meas;
        
        % jacobian: d(err)/d(pos)
        errjac(ind,ip) = eye(3);
        
        % jacobian: d(err)/d(q)
        qrjac = qrotjac(q);
        errjac(ind,iq) = [ qrjac(:,:,1) * v,  qrjac(:,:,2) * v,  qrjac(:,:,3) * v,  qrjac(:,:,4) * v ];
        
        % partial of d(err)/d(q) wrt d(q)
        % note: jac2(i).jac(:,:,j) = d/dqj * dR/dqi
        errjac2(iq(1),iq(1)).vec(ind) = jac2(1).jac(:,:,1) * v;
        errjac2(iq(1),iq(2)).vec(ind) = jac2(2).jac(:,:,1) * v;
        errjac2(iq(1),iq(3)).vec(ind) = jac2(3).jac(:,:,1) * v;
        errjac2(iq(1),iq(4)).vec(ind) = jac2(4).jac(:,:,1) * v;
        
        errjac2(iq(2),iq(1)).vec(ind) = jac2(1).jac(:,:,2) * v;
        errjac2(iq(2),iq(2)).vec(ind) = jac2(2).jac(:,:,2) * v;
        errjac2(iq(2),iq(3)).vec(ind) = jac2(3).jac(:,:,2) * v;
        errjac2(iq(2),iq(4)).vec(ind) = jac2(4).jac(:,:,2) * v;
        
        errjac2(iq(3),iq(1)).vec(ind) = jac2(1).jac(:,:,3) * v;
        errjac2(iq(3),iq(2)).vec(ind) = jac2(2).jac(:,:,3) * v;
        errjac2(iq(3),iq(3)).vec(ind) = jac2(3).jac(:,:,3) * v;
        errjac2(iq(3),iq(4)).vec(ind) = jac2(4).jac(:,:,3) * v;
        
        errjac2(iq(4),iq(1)).vec(ind) = jac2(1).jac(:,:,4) * v;
        errjac2(iq(4),iq(2)).vec(ind) = jac2(2).jac(:,:,4) * v;
        errjac2(iq(4),iq(3)).vec(ind) = jac2(3).jac(:,:,4) * v;
        errjac2(iq(4),iq(4)).vec(ind) = jac2(4).jac(:,:,4) * v;
        
        % weight
        W(ind,ind) = model.markerTrustValue(strcmp(mkr{m},model.markerNames)) * eye(3);
        
    end
    
end

% remove entries with nan
errvec(inan) = 0;
errjac(inan,:) = 0;
W(inan,:) = 0;
W(:,inan) = 0;

% cost
cost = 1/2 * errvec' * W * errvec;

% gradient
grad = errvec' * W * errjac;

% hessian
hess1 = errjac' * W * errjac;
hess2 = zeros(size(hess1));
for i = 1:length(x)
    for j = i:length(x)
        hess2(i,j) = errvec' * W * errjac2(i,j).vec;
        if j ~= i; hess2(j,i) = hess2(i,j); end
    end
end
hessian = hess1 + hess2;
hessian = (hessian + hessian')/2;

% time derive of obj gradient (assuming constant gen coord)
errvec_dot(vnan) = 0;
grad_dot = errvec_dot' * W * errjac;

end