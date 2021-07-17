function a1 = frameanwrel(r1,r2,w1,w2,a0,weight)
%   
%   functional rotation axis estimator: mean instantaneous helical axis, 
%   Stokdijk et al. 1999, Besier et al. 2003
%
%   estimates rotation axis for joint characterized by two bodies (body 1,
%   body 2) with associated orientations (r1, r2) and rates (w1, w2)
%   where joint is approximately planar (hinge joint).
%
%   assuming a hinge joint, the body 2 angular rate relative to body 1 in
%   the body 1 frame should be only about a single axis (the hinge axis),
%   this is approximated as the weighed average of the direction of all
%   angular velocities input.
%
%   this also called mean helical axis approach. Rigid body displacement
%   can be parametrized as a screw/wrench/helical displacement. The
%   rotation displacement can be characterized in many ways (dcm,
%   quaternion, euler angles, etc.) including axis/angle of rotation. The
%   helical axis is the axis of rotation. Instantaneous axis is relative 
%   angular rate
%
%   this method does not return a joint center estimate.
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%
%   r2:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r2(:,:,i) * v_frame2(:,i)
%
%   w1:
%       3xn array of angular velocity vector of frame 1 measured in frame 1
%
%   w2:
%       3xn array of angular velocity vector of frame 2 measured in frame 2
%
%   a0:
%       3x1 vector, first estimate of joint axis in frame 1, only needs to
%       point in correct half of joint plane
%
%   weight:
%       weight for weighted average
%           -weight = 0, all weighted equally
%           -weight = 1, weight is angular velocity magnitude
%           -weight = 2, weight is angular velocity magnitude squared
%
%---------------------------------OUTPUTS----------------------------------
%
%   a1:
%       3x1 unit vector specifying the joint axis in frame 1
%
%--------------------------------------------------------------------------
%% frameanwrel

% for each frame
n = size(w1,2);
a1 = [0 0 0]';
for i = 1:n
    
    % get body 2 rate relative to body 1
    wrel = r1(:,:,i)' * r2(:,:,i) * w2(:,i) - w1(:,i);
    wmag = vecnorm(wrel);
    
    % get instantaneous helical axis
    axis = wrel / wmag;
    
    % correct side
    axis = sign(axis'*a0) * axis;
    
    % get weight
    if weight == 1; w = wmag;
    elseif weight == 2; w = wmag^2;
    else; w = 1;
    end
    
    % increment weighted sum
    a1 = a1 + w * axis;
    
end

% normalize
a1 = a1 / vecnorm(a1);
            
end