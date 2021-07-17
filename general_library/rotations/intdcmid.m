function [ dc ] = intdcmid( dc0, w, t, b2w, inbody, forward)
%Reed Gurchiek, 2020
%   intdcmid time integrates dc to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (dc0). intdcmid uses the midpoint approximation (see
%   McGinnis and Perkins 2012) and the form dcdot = A * dc
%
%--------------------------INPUTS------------------------------------------
%
%   dc0:
%       9x1, initial orientation (direction cosines), dc(1:3) corresponds to column 1
%       of the corresponding dcm, dc(4:6) corresponds to column 2 of the
%       corresponding dcm, and dc(7:9) corresponds to column 3 of the
%       corresponding dcm
%
%   w:
%       gyroscope measured body angular rate IN RADIANS PER SECOND. should
%       be a 3xn array where n is the number of samples
%
%   t:
%       time IN SECONDS.  should be a 1D vector of length n.
%
%   b2w:
%       boolean.  Does dc2dcm(dc) rotate body frame referenced vectors to world
%       frame? if yes then b2w = 1. If not, b2w = 0 (i.e.
%       world to body). e.g. if b2w = 1 => v_world = dc2dcm(dc) * v_body
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
%   dc:
%       9xn time integrated direction cosines array
%
%--------------------------------------------------------------------------
%% intdcmid

% initialize
n = size(w,2);
dc = zeros(9,n);
dc(:,1) = dc0;
I9 = eye(9);

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% get state matrices
A = dcstatemat(w,b2w,inbody);

% for each sample
dt = diff(t);
for k = 1:n-1
    
    % step
    dc(:,k+1) = (I9 - dt(k)/2 * A(:,:,k+1)) \ (I9 + dt(k)/2 * A(:,:,k)) * dc(:,k);
    
    % orthogonalize
    dc(:,k+1) = dcm2dc(orthogonalize(dc2dcm(dc(:,k+1))));
    
end

% flip back?
if ~forward
    dc = flip(q,2);
end

end