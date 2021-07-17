function [ q ] = intqrect( q0, w, t, b2w, inbody, midpoint, forward)
%Reed Gurchiek, 2020
%   intqrect time integrates the quaternion q to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (q0). intqrect performs the following:
%
%   (1) map angular rate to quaternion derivative
%   (2) take an integration step: q_next = q_now + delta_t * q_dot
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
%       world to body). e.g. if b2w = 1 = v_world = q * v_body * q_conj
%
%   inbody:
%       boolean. Is w expressed in the body frame? If yes, then inbody = 1,
%       if not, then inbody = 0.
%
%   midpoint:
%       boolean. Use midpoint approximation? If no then  midpoint = 0 and
%           w = w_k within t_k < t < t_k+1 (zero order hold) 
%       otherwise if midpoint = 1 then the assumed constant angular rate
%       during the time interval is the average of w_k and w_k+1
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
%% intqtrap

% initialize
n = size(w,2);
q = zeros(4,n);
q(:,1) = normc(q0);

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% replace each w_k with midpoint?
if midpoint
    w = [1/2 * (w(:,1:n-1) + w(:,2:n)) w(:,end)];
end

% for each sample
dt = diff(t);
for k = 1:n-1
    
    % get derivative
    qdot = qjac(q(:,k),b2w,inbody,1) * w(:,k);
    
    % integration step
    q(:,k+1) = q(:,k) + dt(k) * qdot;
    
    % normalize
    q(:,k+1) = normc(q(:,k+1));
    
end

% flip back?
if ~forward
    q = flip(q,2);
end

end