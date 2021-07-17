function [ e ] = inteulerrect( e0, seq, w, t, b2w, inbody, midpoint, forward)
%Reed Gurchiek, 2020
%   inteulerrect time integrates the euler angles e0 to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (e0). inteulerrect performs the following:
%
%   (1) map angular rate to euler angle derivative
%   (2) take an integration step: e_next = e_now + delta_t * e_dot
%
%--------------------------INPUTS------------------------------------------
%
%   e0:
%       3x1, initial euler angle vector from which integration begins.
%       Angles must be in radians
%
%   w:
%       gyroscope measured body angular rate IN RADIANS PER SECOND. should
%       be a 3xn array where n is the number of samples
%
%   t:
%       time IN SECONDS.  should be a 1D vector of length n.
%
%   b2w:
%       boolean.  Does e rotate body frame referenced vectors to world
%       frame? if yes then b2w = 1. If not, b2w = 0 (i.e.
%       world to body).
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
%   e:
%       3xn time integrated euler angle array
%
%--------------------------------------------------------------------------
%% inteulerrect

% initialize
n = size(w,2);
e = zeros(3,n);
e(:,1) = e0;

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
    edot = eulerjac(e(:,k),seq,b2w,inbody,1) * w(:,k);
    
    % integration step
    e(:,k+1) = e(:,k) + dt(k) * edot;
    
end

% flip back?
if ~forward
    e = flip(e,2);
end

end