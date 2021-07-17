function a1 = frapcawrel(r1,r2,w1,w2,a0)
%   
%   functional rotation axis estimator: PCA method, Lebleu et al. 2020
%
%   estimates rotation axis for joint characterized by two bodies (body 1,
%   body 2) with associated orientations (r1, r2) and rates (w1, w2)
%   where joint is approximately planar (hinge joint).
%
%   assuming a hinge joint, the body 2 angular rate relative to body 1 in
%   the body 1 frame should be only about a single axis (the hinge axis),
%   this is approximated as the first principal component of the relative
%   angular velocity data
%
%   this method does not return a joint center estimate.
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   r2:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r2(:,:,i) * v_frame2(:,i)
%   w1:
%       3xn array of angular velocity vector of frame 1 measured in frame 1
%   w2:
%       3xn array of angular velocity vector of frame 2 measured in frame 2
%
%   a0:
%       3x1 vector, first estimate of joint axis in frame 1, only needs to
%       point in correct half of joint plane
%
%---------------------------------OUTPUTS----------------------------------
%
%   a1:
%       3x1 unit vector specifying the joint axis in frame 1
%
%--------------------------------------------------------------------------
%% frapcawrel

% get angular velocity of frame 2 relative to frame 1 in frame 1
wrel = qrot(qprod(qconj(convdcm(r1,'q')),convdcm(r2,'q')),w2) - w1;

% correct side
wrel = wrel .* repmat(sign(a0' * wrel),[3 1]);

% get principal components, joint axis estimate is first pc
a1 = pca(wrel');
a1 = a1(:,1);

end