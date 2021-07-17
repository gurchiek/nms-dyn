function [ dcm ] = intdcmmid( dcm0, w, t, b2w, inbody, forward)
%Reed Gurchiek, 2020
%   intdcmmid time integrates the direction cosine matrix dcm0 to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (dcm0). intdcmmid uses mid point approximation (See
%   McGinnis and Perkins 2012)
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
%--------------------------------------------------------------------------
%% intdcmmid

% initialize
n = size(w,2);
dcm = zeros(3,3,n);
dcm(:,:,1) = dcm0;
I3 = eye(3);

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% for each sample
dt = diff(t); 

% if v_w = R * v_b and w in body
if b2w && inbody
    
    for k = 1:n-1
        m1 = I3 + dt(k)/2 * skew(w(:,k));
        m2 = I3 - dt(k)/2 * skew(w(:,k+1));
        dcm(:,:,k+1) = dcm(:,:,k) * m1 / m2;
        
        % orthogonalize
        dcm(:,:,k+1) = orthogonalize(dcm(:,:,k+1));
    end
    
% if v_w = R * v_b and w in world    
elseif b2w && ~inbody
    
    for k = 1:n-1
        m1 = I3 + dt(k)/2 * skew(w(:,k));
        m2 = I3 - dt(k)/2 * skew(w(:,k+1));
        dcm(:,:,k+1) = m2 \ m1 * dcm(:,:,k);
        
        % orthogonalize
        dcm(:,:,k+1) = orthogonalize(dcm(:,:,k+1));
    end
    
% if v_b = R * v_w and w in body    
elseif ~b2w && inbody
    
    for k = 1:n-1
        m1 = I3 - dt(k)/2 * skew(w(:,k));
        m2 = I3 + dt(k)/2 * skew(w(:,k+1));
        dcm(:,:,k+1) = m2 \ m1 * dcm(:,:,k);
        
        % orthogonalize
        dcm(:,:,k+1) = orthogonalize(dcm(:,:,k+1));
    end
    
% if v_b = R * v_w and w in world    
elseif ~b2w && ~inbody
    
    for k = 1:n-1
        m1 = I3 - dt(k)/2 * skew(w(:,k));
        m2 = I3 + dt(k)/2 * skew(w(:,k+1));
        dcm(:,:,k+1) = dcm(:,:,k) * m1 / m2;
        
        % orthogonalize
        dcm(:,:,k+1) = orthogonalize(dcm(:,:,k+1));
    end
    
end

% flip back?
if ~forward
    dcm = flip(dcm,3);
end

end