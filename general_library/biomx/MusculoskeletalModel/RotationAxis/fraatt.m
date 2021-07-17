function [a1,a2,c1,c2,smin] = fraatt(r1,r2,p1,p2,tol)
%   
%   functional rotation axis estimator: ATT method, Ehrig et al. 2007,
%   basically same as SARA up to a coordinate transform
%
%   estimates rotation axis for joint characterized by two bodies (body 1,
%   body 2) with associated orientations (r1, r2) and origins (p1, p2)
%   where joint is approximately planar (hinge joint).
%
%   the output argument smin provides some insight into what extent
%   the joint actually acts as a hinge; the closer smin is to 0, the
%   more the joint acts as a hinge; larger smin values may suggest
%   the joint is better represented spheroidally
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   r2:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r2(:,:,i) * v_frame2(:,i)
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       in the world frame
%
%   p2:
%       3xn array of column vectors specifying a point in body 2 expressed
%       in the world frame; this can be the origin of body 2, but it does
%       not have to be; the joint center argument (c1 in body 1 or c2 in
%       body 2) is the point on the joint axis (a1 in body 1 or a2 in body
%       2) such that (p2 - c2) is orthogonal to a2
%
%   tol (optional: default = 1e-4):
%       same argument in matlab's pinv, singular values below this number
%       are ignored in computing the pseudo inverse
%
%---------------------------------OUTPUTS----------------------------------
%
%   a1,a2:
%       3x1 unit vector specifying the direction of the joint axis in frame
%       1 and frame 2 respectively
%
%   c1,c2:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1 and frame 2 respectively
%
%   smin:
%       the least singular value of the design matrix, provides some
%       insight into what extent the joint actually acts as a hinge; the 
%       closer smin is to 0, the more the joint acts as a hinge; larger 
%       smin values may suggest the joint is better represented 
%       spheroidally
%
%--------------------------------------------------------------------------
%% fraatt

% tol
if nargin == 4; tol = 1e-4; end

% get location of frame 2 relative to frame 1
v = p2 - p1;

% initialize dcm taking frame 2 to frame 1
r21 = r2;

% for each observation
for k = 1:size(v,2)

    % get r21 s.t. v_frame1 = r21 * v_frame2
    r21(:,:,k) = r1(:,:,k)' * r2(:,:,k);

    % get v in frame 1
    v(:,k) = r1(:,:,k)' * v(:,k);

end

% setup linear system
b = tower(v);
A = [tower(repmat(eye(3),[1 1 size(v,2)])) -tower(r21)];

% SVD
[U,S,V] = svd(A);

% remove evecs associated with 0 singular values (prepping for pseudoinv)
U(:,7:end) = [];

% get minimum singular value
spec = diag(S(1:6,1:6));
[smin,imin] = min(spec);

% rotation axis is that which approximates the null space of the design
% matrix A, ie for noiseless measurements we would have A * [a1 a2]' = 0 if
% the joint were truly a hinge (in this case smin would be exactly 0)
a1 = V(1:3,imin)/vecnorm(V(1:3,imin));
a2 = V(4:6,imin)/vecnorm(V(4:6,imin));

% neglect smin component if below user-specified tolerance
if smin <= tol
    V(:,imin) = [];
    spec(imin) = [];
    U(:,imin) = [];
end

% solve
x = V * diag(1./spec) * U' * b;
c1 = x(1:3);
c2 = x(4:6);

end