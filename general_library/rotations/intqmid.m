function [ q ] = intqmid( q0, w, t, b2w, inbody, forward)
%Reed Gurchiek, 2020
%   intqmid time integrates the quaternion q0 to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (q0). intqmid uses the midpoint approximation (see
%   McGinnis and Perkins 2012) and the form qdot = A * q
%
%   q is s.t. its rotation operation is per: v2 = q * v1 * q_conj
%   q(4,:) is the scalar part, q(1:3,:) is the x, y, z vector part
%
%--------------------------INPUTS------------------------------------------
%
%   q0:
%       4x1, initial quaternion from which integration begins
%
%   w:
%       gyroscope measured body angular rate IN RADIANS PER SECOND. should
%       be a 3xn array where n is the number of samples
%
%   t:
%       time IN SECONDS.  should be a 1D vector of length n.
%
%   b2w:
%       boolean.  Does q rotate body frame referenced vectors to world
%       frame? if yes then b2w = 1. If not, b2w = 0 (i.e.
%       world to body). e.g. if b2w = 1 => v_world = q * v_body * q_conj
%
%   inbody:
%       boolean. Is w expressed in the body frame? If yes, then inbody = 1,
%       if not, then inbody = 0.
%
%   forward:
%       boolean. if integrate from beginning to end then forward = 1 and r0
%       corresponds to r at t = t(1). If integrate from end to beginning
%       then forward = 0 and r0 corresponds to r at t = t(end)
%
%-------------------------------OUTPUTS------------------------------------
%
%   q:
%       4xn time integrated quaternion array
%
%--------------------------------------------------------------------------
%% intqmid

% initialize
n = size(w,2);
q = zeros(4,n);
q(:,1) = normc(q0);
I4 = eye(4);

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% get state matrices
A = qstatemat(w,b2w,inbody);

% for each sample
dt = diff(t);
for k = 1:n-1
    
    % step
    q(:,k+1) = (I4 - dt(k)/2 * A(:,:,k+1)) \ (I4 + dt(k)/2 * A(:,:,k)) * q(:,k);
    
    % normalize
    q(:,k+1) = normc(q(:,k+1));
    
end

% flip back?
if ~forward
    q = flip(q,2);
end

end