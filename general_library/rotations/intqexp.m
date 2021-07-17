function [ q, expq, expA ] = intqexp( q0, w, t, b2w, inbody, midpoint, forward)
%Reed Gurchiek, 2020
%   intqexp time integrates the quaternion q0 to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (q0). intqexp performs the following:
%
%   (1) get A s.t. qdot_k = A * q_k
%   (2) solve: q_k+1 = exp(A*dt) * q_k
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
%% intqexp

% initialize
n = size(w,2);
q = zeros(4,n);
expA = zeros(4,4,n-1);
expq = zeros(4,n-1);
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

% time steps
dt = diff(t);

% order for matrix multiplication
if b2w && inbody
    order = 2;
elseif b2w && ~inbody
    order = 1;
elseif ~b2w && inbody
    order = 1;
elseif ~b2w && ~inbody
    order = 2;
end

% negate if world to body
if ~b2w; w = -w; end

% for each sample
for k = 1:n-1
    
    % get quaternion exponential that solves state equation (assuming
    % constant angular rate) and convert to matrix
    halfangle = vecnorm(w(:,k)) * dt(k) / 2;
    expq(:,k) = [normc(w(:,k)) * sin(halfangle); cos(halfangle)];
    expA(:,:,k) = qprodmat(expq(:,k),order);
    
    % step
    q(:,k+1) = expA(:,:,k) * q(:,k);
    
    % normalize
    q(:,k+1) = normc(q(:,k+1));
    
end

% flip back?
if ~forward
    q = flip(q,2);
end

end