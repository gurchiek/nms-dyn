function [c,ceq,c_deriv,ceq_deriv,ceq_deriv2] = multibodySystemConstraints(x,model,trial,frame,cs)

% constraint function for use in fmincon
% x - generalized coordinates
% model - nms model struct
% cs - coordinate system name

% initialize equality constraints and gradient
ceq = zeros(model.nConstraints,1);
ceq_deriv = zeros(model.nConstraints,length(x));

% initialize second derivative
ceq_deriv2(length(x),length(x)) = struct();
for i = 1:length(x)
    for j = i:length(x)
        ceq_deriv2(i,j).vec = zeros(model.nConstraints,1); % ceq_deriv2(i,j).vec(k) = d/dxi * [dceq(k))/dx(j)]
    end
end

% get segment positions, orientations, gen coord indices, quaternion jacobians
for s = 1:model.nSegments
    seg = modelIndex2Segment(model,model.segmentIndices(s));
    ip.(seg) = segmentIndex2GeneralizedCoordinateIndices(model.segmentIndices(s),'translation'); % segment position indices
    iq.(seg) = segmentIndex2GeneralizedCoordinateIndices(model.segmentIndices(s),'rotation'); % segment orientation indices
    p.(seg) = x(ip.(seg)); % segment position
    q.(seg) = x(iq.(seg)); % segment orientation
    qr_deriv.(seg) = qrotjac(q.(seg)); % qr_deriv(:,:,i) = dR/dqi
end

% some constant matrices needed for computing first/second derivatives
qr_deriv2 = qrotjac2; % qr_deriv2(i).jac(:,:,j) = d/dqj * dR/dqi
dQBL = qprodmatjac(1); % dQBL(:,:,i) = dQ/dqi where Q * v is equivalent to qprod(q,v), Q is 4x4 matrix
dQ_AR = qprodmatjac(2);
for k = 1:4; dQ_AR(:,:,k) = dQ_AR(:,:,k) * diag([-1 -1 -1 1]); end

% for each joint
for j = 1:model.nJoints
    
    % get position of joint relative to parent/child in parent/child: see getLocalJointPositions()
    jp.(model.jointNames{j}).parent = model.joint.(model.jointNames{j}).parent.position.(cs);
    jp.(model.jointNames{j}).child = model.joint.(model.jointNames{j}).child.position.(cs);
    
    % if joint has constraints
    if model.joint.(model.jointNames{j}).rotationDOF < 3
        
        % get parent/child orientations
        qparent = q.(model.joint.(model.jointNames{j}).parent.segment);
        iqp = iq.(model.joint.(model.jointNames{j}).parent.segment);
        qchild = q.(model.joint.(model.jointNames{j}).child.segment);
        iqc = iq.(model.joint.(model.jointNames{j}).child.segment);
        
        % if perspective is parent2child => B = parent, A = child in notes
        if strcmpi(model.joint.(model.jointNames{j}).rotationPerspective,'parent2child')
            
            % then qj maps v_parent = qj * v_child * qj_conj
            % => qB = qparent and qA = qchild in notes
            qA.(model.jointNames{j}) = qchild;
            iqA.(model.jointNames{j}) = iqc;
            qB.(model.jointNames{j}) = qparent;
            iqB.(model.jointNames{j}) = iqp;
            
            % get quaternion that takes jcs to segment A/B in ref config: see jointCoordinateSystem()
            qcA = model.joint.(model.jointNames{j}).child.(cs).orientation;
            qcB = model.joint.(model.jointNames{j}).parent.(cs).orientation;
        
        % if perspective is child2parent => B = child, A = parent
        elseif strcmpi(model.joint.(model.jointNames{j}).rotationPerspective,'child2parent')
            
            % then qj maps v_child = qj * v_parent * qj_conj
            % => qB = qchild and qA = qparent in notes
            qA.(model.jointNames{j}) = qparent;
            iqA.(model.jointNames{j}) = iqp;
            qB.(model.jointNames{j}) = qchild;
            iqB.(model.jointNames{j}) = iqc;
            
            % get quaternion that takes jcs to segment A/B in ref config: see jointCoordinateSystem()
            qcA = model.joint.(model.jointNames{j}).parent.(cs).orientation;
            qcB = model.joint.(model.jointNames{j}).child.(cs).orientation;
            
        end
    
        % get constant matrix that takes quasi-joint: qj' = qB'_conj * qA' to actual joint quaternion qj = Pc * qj'
        Pc.(model.jointNames{j}) = qprodmat(qcB,1)' * qprodmat(qcA,2);
        
        % get QBL that takes qA to quasi-joint as per qj' = QBL' * qA
        QBL.(model.jointNames{j}) = qprodmat(qB.(model.jointNames{j}),1);
        
        % get Q_AR that takes qB to quasi-joint as per qj' = Q_AR * qB
        Q_AR.(model.jointNames{j}) = qprodmat(qA.(model.jointNames{j}),2) * diag([-1 -1 -1 1]);
        
        % compute product Pc * Q_AR and Pc * QBL'
        PcQ_AR.(model.jointNames{j}) = Pc.(model.jointNames{j}) * Q_AR.(model.jointNames{j});
        PcQBLt.(model.jointNames{j}) = Pc.(model.jointNames{j}) * QBL.(model.jointNames{j})';
        
        % get joint quaternion
        qj.(model.jointNames{j}) = 0.5 * (PcQBLt.(model.jointNames{j}) * qA.(model.jointNames{j}) + PcQ_AR.(model.jointNames{j}) * qB.(model.jointNames{j}));
        
        % get some matrices needed for hessian
        for k = 1:4
            PcdQ_AR.(model.jointNames{j})(:,:,k) = Pc.(model.jointNames{j}) * dQ_AR(:,:,k); % PcdQ_AR(:,:,k) = Pc * (dQ_AR/dqA_k)
            PcdQBLt.(model.jointNames{j})(:,:,k) = Pc.(model.jointNames{j}) * dQBL(:,:,k)';
        end
        
    
    end
    
end

% non dislocating joints
ic = 0;
for j = 1:model.nJoints
    
    % update constraint indices
    ic = ic(end)+1:ic(end)+3;
    
    % joint center in world from relative joint center in parent/child should agree
    jnt = model.jointNames{j};
    pseg = model.joint.(jnt).parent.segment;
    cseg = model.joint.(jnt).child.segment;
    ceq(ic) = p.(pseg) + qrot(q.(pseg),jp.(jnt).parent) - p.(cseg) - qrot(q.(cseg),jp.(jnt).child);
    
    % dceq(ic)/dx
    ceq_deriv(ic,ip.(pseg)) =  eye(3);
    ceq_deriv(ic,ip.(cseg)) = -eye(3);
    ceq_deriv(ic,iq.(pseg)) =  [qr_deriv.(pseg)(:,:,1) * jp.(jnt).parent, qr_deriv.(pseg)(:,:,2) * jp.(jnt).parent, qr_deriv.(pseg)(:,:,3) * jp.(jnt).parent, qr_deriv.(pseg)(:,:,4) * jp.(jnt).parent];
    ceq_deriv(ic,iq.(cseg)) = -[qr_deriv.(cseg)(:,:,1) * jp.(jnt).child,  qr_deriv.(cseg)(:,:,2) * jp.(jnt).child,  qr_deriv.(cseg)(:,:,3) * jp.(jnt).child,  qr_deriv.(cseg)(:,:,4) * jp.(jnt).child];
    
    % d/dxi * dceq(ic)/dxj
    for i = 1:4; for k = 1:4; ceq_deriv2(iq.(pseg)(i),iq.(pseg)(k)).vec(ic) =  qr_deriv2(k).jac(:,:,i) * jp.(jnt).parent; end; end
    for i = 1:4; for k = 1:4; ceq_deriv2(iq.(cseg)(i),iq.(cseg)(k)).vec(ic) = -qr_deriv2(k).jac(:,:,i) * jp.(jnt).child;  end; end
    
end
   
% unit quaternions
for s = 1:model.nSegments
    
    % update constraint indices
    ic = ic(end)+1;
    
    % quaternion should have unit norm
    seg = model.segmentNames{s};
    ceq(ic) = ( q.(seg)' * q.(seg) ) - 1;
    
    % dceq(ic)/dq
    ceq_deriv(ic,iq.(seg)) = 2 * q.(seg)';
    
    % d/dqi * dceq(ic)/dqj = 0
    % d/dqi * dceq(ic)/dqi
    for i = 1:4; ceq_deriv2(iq.(seg)(i),iq.(seg)(i)).vec(ic) = 2; end
    
end

% hinge joints
for j = 1:model.nJoints
    
    jnt = model.jointNames{j};
    if strcmpi(model.joint.(jnt).type,'hinge') || strcmpi(model.joint.(jnt).type,'revolute') || strcmpi(model.joint.(jnt).type,'pin')
        
        % for y and z components
        for k = 2:3
        
            % update constraint indices
            ic = ic(end) + 1;
            
            % component k (2 or 3) should be zero
            ceq(ic) = qj.(jnt)(k);

            % dceq(ic)/dqA: row k of Pc * QBL'
            ceq_deriv(ic,iqA.(jnt)) = PcQBLt.(jnt)(k,:);
            
            % dceq(ic)/dqB: row k of Pc * Q_AR
            ceq_deriv(ic,iqB.(jnt)) = PcQ_AR.(jnt)(k,:);
            
            % d/dqA * (dceq(ic)/dqA) = d/dqB * (dceq(ic)/dqB) = 0
            
            % d/dqB * (dceq(ic)/dqA)
            for r = 1:4
                for c = 1:4
                    ceq_deriv2(iqB.(jnt)(r),iqA.(jnt)(c)).vec(ic) = PcdQBLt.(jnt)(k,c,r); % d/dqB(r) * dceq(ic)/dqA(c)
                    ceq_deriv2(iqA.(jnt)(r),iqB.(jnt)(c)).vec(ic) = PcdQ_AR.(jnt)(k,c,r); % d/dqA_r * (dc/dqB_c)
                end
            end
            
        end
        
    end
    
end

% universal joints
for j = 1:model.nJoints
    
    jnt = model.jointNames{j};
    if strcmpi(model.joint.(jnt).type,'universal')
        
        % update constraint indices
        ic = ic(end) + 1;
        
        % qj(1) = sx*cy, qj(2) = cx*sy, qj(3) = -sx*sy, qj(4) = cx*cy
        % => qj(1)*qj(2) + qj(3)*qj(4) = 0
%         ceq(ic) = qj.(jnt)(1) * qj.(jnt)(2) + qj.(jnt)(3) * qj.(jnt)(4);
        ceq(ic) = qj.(jnt)(1) * qj.(jnt)(2) - qj.(jnt)(3) * qj.(jnt)(4);
        
        % dceq(ic)/dqA
%         ceq_deriv(ic,iqA.(jnt)) = PcQBLt.(jnt)(1,:) * qj.(jnt)(2) + PcQBLt.(jnt)(2,:) * qj.(jnt)(1) + PcQBLt.(jnt)(3,:) * qj.(jnt)(4) + PcQBLt.(jnt)(4,:) * qj.(jnt)(3);
        ceq_deriv(ic,iqA.(jnt)) = PcQBLt.(jnt)(1,:) * qj.(jnt)(2) + PcQBLt.(jnt)(2,:) * qj.(jnt)(1) - PcQBLt.(jnt)(3,:) * qj.(jnt)(4) - PcQBLt.(jnt)(4,:) * qj.(jnt)(3);
        
        % dceq(ic)/dqB
%         ceq_deriv(ic,iqB.(jnt)) = PcQ_AR.(jnt)(1,:) * qj.(jnt)(2) + PcQ_AR.(jnt)(2,:) * qj.(jnt)(1) + PcQ_AR.(jnt)(3,:) * qj.(jnt)(4) + PcQ_AR.(jnt)(4,:) * qj.(jnt)(3);
        ceq_deriv(ic,iqB.(jnt)) = PcQ_AR.(jnt)(1,:) * qj.(jnt)(2) + PcQ_AR.(jnt)(2,:) * qj.(jnt)(1) - PcQ_AR.(jnt)(3,:) * qj.(jnt)(4) - PcQ_AR.(jnt)(4,:) * qj.(jnt)(3);

        % d/dqi * dceq(ic)/dqj
        for r = 1:4
            for c = 1:4
                
                % d/dqA * dceq(ic)/dqA
%                 ceq_deriv2(iqA.(jnt)(r),iqA.(jnt)(c)).vec(ic) = PcQBLt.(jnt)(1,c) * PcQBLt.(jnt)(2,r) + PcQBLt.(jnt)(2,c) * PcQBLt.(jnt)(1,r) + PcQBLt.(jnt)(3,c) * PcQBLt.(jnt)(4,r) + PcQBLt.(jnt)(4,c) * PcQBLt.(jnt)(3,r);
                ceq_deriv2(iqA.(jnt)(r),iqA.(jnt)(c)).vec(ic) = PcQBLt.(jnt)(1,c) * PcQBLt.(jnt)(2,r) + PcQBLt.(jnt)(2,c) * PcQBLt.(jnt)(1,r) - PcQBLt.(jnt)(3,c) * PcQBLt.(jnt)(4,r) - PcQBLt.(jnt)(4,c) * PcQBLt.(jnt)(3,r);
                
                % d/dqB * dceq(ic)/dqB
%                 ceq_deriv2(iqB.(jnt)(r),iqB.(jnt)(c)).vec(ic) = PcQ_AR.(jnt)(1,c) * PcQ_AR.(jnt)(2,r) + PcQ_AR.(jnt)(2,c) * PcQ_AR.(jnt)(1,r) + PcQ_AR.(jnt)(3,c) * PcQ_AR.(jnt)(4,r) + PcQ_AR.(jnt)(4,c) * PcQ_AR.(jnt)(3,r);
                ceq_deriv2(iqB.(jnt)(r),iqB.(jnt)(c)).vec(ic) = PcQ_AR.(jnt)(1,c) * PcQ_AR.(jnt)(2,r) + PcQ_AR.(jnt)(2,c) * PcQ_AR.(jnt)(1,r) - PcQ_AR.(jnt)(3,c) * PcQ_AR.(jnt)(4,r) - PcQ_AR.(jnt)(4,c) * PcQ_AR.(jnt)(3,r);
                
                % d/dqB * dceq(ic)/dqA
%                 ceq_deriv2(iqB.(jnt)(r),iqA.(jnt)(c)).vec(ic) = PcdQBLt.(jnt)(1,c,r) * qj.(jnt)(2) + PcQBLt.(jnt)(1,c) * PcQ_AR.(jnt)(2,r) + ...
%                                                                 PcdQBLt.(jnt)(2,c,r) * qj.(jnt)(1) + PcQBLt.(jnt)(2,c) * PcQ_AR.(jnt)(1,r) + ...
%                                                                 PcdQBLt.(jnt)(3,c,r) * qj.(jnt)(4) + PcQBLt.(jnt)(3,c) * PcQ_AR.(jnt)(4,r) + ...
%                                                                 PcdQBLt.(jnt)(4,c,r) * qj.(jnt)(3) + PcQBLt.(jnt)(4,c) * PcQ_AR.(jnt)(3,r);
                ceq_deriv2(iqB.(jnt)(r),iqA.(jnt)(c)).vec(ic) =  PcdQBLt.(jnt)(1,c,r) * qj.(jnt)(2) + PcQBLt.(jnt)(1,c) * PcQ_AR.(jnt)(2,r) + ...
                                                                 PcdQBLt.(jnt)(2,c,r) * qj.(jnt)(1) + PcQBLt.(jnt)(2,c) * PcQ_AR.(jnt)(1,r) + ...
                                                                -PcdQBLt.(jnt)(3,c,r) * qj.(jnt)(4) - PcQBLt.(jnt)(3,c) * PcQ_AR.(jnt)(4,r) + ...
                                                                -PcdQBLt.(jnt)(4,c,r) * qj.(jnt)(3) - PcQBLt.(jnt)(4,c) * PcQ_AR.(jnt)(3,r);
                
                % d/dqA * dceq(ic)/dqB
%                 ceq_deriv2(iqA.(jnt)(r),iqB.(jnt)(c)).vec(ic) = PcdQ_AR.(jnt)(1,c,r) * qj.(jnt)(2) + PcQ_AR.(jnt)(1,c) * PcQBLt.(jnt)(2,r) + ...
%                                                                 PcdQ_AR.(jnt)(2,c,r) * qj.(jnt)(1) + PcQ_AR.(jnt)(2,c) * PcQBLt.(jnt)(1,r) + ...
%                                                                 PcdQ_AR.(jnt)(3,c,r) * qj.(jnt)(4) + PcQ_AR.(jnt)(3,c) * PcQBLt.(jnt)(4,r) + ...
%                                                                 PcdQ_AR.(jnt)(4,c,r) * qj.(jnt)(3) + PcQ_AR.(jnt)(4,c) * PcQBLt.(jnt)(3,r);
                ceq_deriv2(iqA.(jnt)(r),iqB.(jnt)(c)).vec(ic) =  PcdQ_AR.(jnt)(1,c,r) * qj.(jnt)(2) + PcQ_AR.(jnt)(1,c) * PcQBLt.(jnt)(2,r) + ...
                                                                 PcdQ_AR.(jnt)(2,c,r) * qj.(jnt)(1) + PcQ_AR.(jnt)(2,c) * PcQBLt.(jnt)(1,r) + ...
                                                                -PcdQ_AR.(jnt)(3,c,r) * qj.(jnt)(4) - PcQ_AR.(jnt)(3,c) * PcQBLt.(jnt)(4,r) + ...
                                                                -PcdQ_AR.(jnt)(4,c,r) * qj.(jnt)(3) - PcQ_AR.(jnt)(4,c) * PcQBLt.(jnt)(3,r);
            end
        end
        
    end
    
end

% transpose for matlab
ceq_deriv = ceq_deriv';

% no inequality constraints
c = [];
c_deriv = [];

end