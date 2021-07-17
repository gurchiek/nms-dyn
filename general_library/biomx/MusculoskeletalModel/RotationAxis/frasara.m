function [a1,a2,c1,c2,smin] = frasara(r1,r2,p1,p2,a1init,tol)
%   
%   functional rotation axis estimator: SARA method, Ehrig et al. 2007
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
%   a1init (optional: default = []):
%       3x1 estimate of rotation axis a1. Is not used as an initial 
%       estimate in some sort of iterative minimization, instead, a1init
%       only helps to return the correct sign of a1. The rotation axis that
%       solves the system of equations is described by a unit vector that 
%       can point in one or the other direction of the rotation axis, if 
%       a1init is given, then a1' * a1init >= 0; (only = 0 if a happens to 
%       be perpendicular to a0 in which case a0 would be a not so good 
%       initial guess...
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
%       3x1 position vector indicating the location of a point on the joint
%       axis line in frame 1 and frame 2 respectively. It is not
%       necessarily the joint center.
%
%   smin:
%       the least singular value of the design matrix, provides some
%       insight into what extent the joint actually acts as a hinge; the 
%       closer smin is to 0, the more the joint acts as a hinge; larger 
%       smin values may suggest the joint is better represented 
%       spheroidally
%
%--------------------------------------------------------------------------
%% frasara

% tolerance for pseudo inverse
if nargin == 4; a1init = []; tol = 1e-4; 
elseif nargin == 5; tol = 1e-4; end

% setup linear system, Ehrig 07 eq 2
b = tower(p2-p1);
A = [tower(r1) -tower(r2)];

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

% sign correction
if ~isempty(a1init)
    a1 = sign(a1init' * a1) * a1; 
    a2 = sign(a1init' * r1(:,:,1)' * r2(:,:,1) * a2) * a2;
end

end