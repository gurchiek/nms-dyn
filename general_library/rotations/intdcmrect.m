function [ dcm, dc ] = intdcmrect( dcm0, w, t, b2w, inbody, midpoint, forward)
%Reed Gurchiek, 2020
%   intdcmrect time integrates the direction cosine matrix dcm0 to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (dcm0). infdcm performs the following:
%
%   (1) convert dcm to vector of direction cosines
%   (2) map angular rate to direction cosine derivatives
%   (3) take an integration step: dc_next = dc_now + delta_t * dc_dot
%   (4) convert back to dcm (dc and dcm are output)
%
%--------------------------INPUTS------------------------------------------
%
%   dcm0:
%       3x3, initial direction cosine matrix from which integration begins
%
%   w:
%       gyroscope measured body angular rate IN RADIANS PER SECOND. should
%       be a 3xn array where n is the number of samples
%
%   t:
%       time IN SECONDS.  should be a 1D vector of length n.
%
%   b2w:
%       boolean.  Does dcm rotate body frame referenced vectors to world
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
%   dcm:
%       3x3xn time integrated dcm array
%
%   dc:
%       9xn time integrated direction cosines array
%
%--------------------------------------------------------------------------
%% intdcmrect

% initialize
n = size(w,2);
dc = zeros(9,n);
dc(:,1) = dcm2dc(dcm0);

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
    dcdot = dcjac(dc(:,k),b2w,inbody,1) * w(:,k);
    
    % integration step
    dc(:,k+1) = dc(:,k) + dt(k) * dcdot;
    
    % orthogonalize
    dc(:,k+1) = dcm2dc(orthogonalize(dc2dcm(dc(:,k+1))));
    
end

% flip back?
if ~forward
    dc = flip(dc,2);
end

% to dcm
dcm = dc2dcm(dc);

end