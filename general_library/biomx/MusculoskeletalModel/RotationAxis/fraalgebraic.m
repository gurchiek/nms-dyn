function [a1,c1,smin,Ainv,b,v] = fraalgebraic(r1,p1,p2,m2)
%   
%   functional rotation axis estimator: Gamage and Lasenby 2002
%
%   estimates rotation axis for joint characterized by two bodies (body 1,
%   body 2) where body 1 has associated orientations (r1) throughtout a
%   calibration trial as well as origin locations p1,p2 in the global frame
%   and marker positions in the global frame on body 2 (m2)
%
%   method uses fact that all points in body 2 should be a constant radial
%   distance from joint axis and a particular point on the axis. This
%   approach minimizes this cost minimizing error in squared radial
%   distance, can be formulated as linear system, has closed form solution,
%   is biased, bias compensation version is frabcalgebraic
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       in the world frame
%
%   p2:
%       3xn array of column vectors specifying a point in body 2 expressed
%       in the world frame. the joint center argument (c1 in body 1) is the
%       point on the joint axis (a1 in body 1) such that:
%           (p2_frame1 - c1) is orthogonal to a1
%
%   m2:
%       3x3xn array of column vectors of marker positions. Each page is for
%       a different marker. Marker positions should be for markers placed
%       on rigid body 2 but expressed in the world frame
%
%---------------------------------OUTPUTS----------------------------------
%
%   a1:
%       3x1 unit vector specifying the joint axis in frame 1
%
%   c1:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1
%
%   smin:
%       the least singular value of the design matrix, provides some
%       insight into what extent the joint actually acts as a hinge; the 
%       closer smin is to 0, the more the joint acts as a hinge; larger 
%       smin values may suggest the joint is better represented 
%       spheroidally
%
%   Ainv:
%       3x3 inverse of design matrix, needed for bias compensation
%       algorithm in frabcalgebraic
%
%   b:
%       3x1 output vector of linear system, b is biased, output here so
%       that bias can be compensated for as in frabcalgebraic
%
%   v:
%       1xm cell array where m is number of markers and each element is a
%       3xN_m array of marker positions (m2) expressed in frame 1, ie
%                           v = r1' * (m2 - p1)
%       the number of observations N_m may not be exactly n as any NaN
%       column vectors (where markers may have been occluded during
%       capture) have been removed
%
%--------------------------------------------------------------------------
%% fraalgebraic

% set up linear system (Ax = b)
nmkr = size(m2,3); % num markers
b = [0 0 0]';
A = zeros(3);
v = cell(1,nmkr);
for m = 1:nmkr

    % get marker m in frame 2 relative to frame 1
    v{m} = dcmrot(r1,m2(:,:,m) - p1,'inverse');

    % remove NaNs
    v{m}(:,any(isnan(v{m}))) = [];

    % vectors to update design matrix
    n = size(v{m},2);
    vbar = mean(v{m},2);
    v2 = dot(v{m},v{m});
    v2bar = mean(v2);
    v3bar = 1/n * v{m} * v2';

    % increment sums
    b = b + v3bar - vbar * v2bar;
    A = A + 1/n * (v{m} * v{m}') - (vbar * vbar');

end
A = 2*A;

% SVD
[U,S] = svd(A);

% get minimum singular value
spec = diag(S);
[smin,imin] = min(spec);

% joint axis is evec associated with smallest singular value, approximates
% null space of A
a1 = U(:,imin); a1 = a1/vecnorm(a1);

% get peudo inverse and solve system
U(:,imin) = [];
spec(imin) = [];
Ainv = U * diag(1./spec) * U';
c1 = Ainv * b;

% get p2 in frame 1
p2 = dcmrot(r1,p2 - p1,'inverse');

% get point on both joint axis and radius of p2 in frame 1
p2bar = mean(p2,2);
c1 = c1 + a1' * (p2bar - c1) * a1;

end