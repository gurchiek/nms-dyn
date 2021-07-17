function [ dc, expA ] = intdcexp( dc0, w, t, b2w, inbody, midpoint, forward)
%Reed Gurchiek, 2020
%   intdcexp time integrates the direction cosines vector dc to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (dc0). intdcexp performs the following:
%
%   (1) get A s.t. dcdot_k = A * dc_k
%   (2) solve: dc_k+1 = exp(A*dt) * dc_k
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
%   dc:
%       9xn time integrated direction cosines array
%
%--------------------------------------------------------------------------
%% intdcexp

% initialize
n = size(w,2);
dc = zeros(9,n);
expA = zeros(9,9,n-1);
dc(:,1) = dc0;

Z3 = zeros(3);
I3 = eye(3);
I9 = eye(9);

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% replace each w_k with midpoint?
if midpoint
    w = 1/2 * (w(:,1:n-1) + w(:,2:n));
end

% time steps
dt = diff(t);
w = w .* dt;

% angle, angle^2, sin(angle), cos(angle)
a = vecnorm(w);
a2 = dot(w,w);
s = sin(a);
c = cos(a);

% if v_world = R * v_body and omega expressed wrt body axes
if b2w && inbody
    
    % state matrix
    A = dcstatemat(w,b2w,inbody);
    
    for k = 1:n-1
        expA(:,:,k) = I9 + s(k)/a(k) * A(:,:,k) + (1-c(k))/a2(k) * A(:,:,k)*A(:,:,k);
    end
    
% if v_world = R * v_body and omega expressed wrt world axes    
elseif b2w && ~inbody
    
    % angular rate in skew symmetric form
    skw = skew(w);
    
    for k = 1:n-1
        R = I3 + s(k)/a(k) * skw(:,:,k) + (1-c(k))/a2(k) * skw(:,:,k)*skw(:,:,k);
        expA(:,:,k) = [R  Z3  Z3;...
                       Z3  R  Z3;...
                       Z3 Z3  R];
    end
    
% if v_body = R * v_world and omega expressed wrt body axes    
elseif ~b2w && inbody
    
    % angular rate in skew symmetric form
    skw = skew(w);
    
    for k = 1:n-1
        R = I3 - s(k)/a(k) * skw(:,:,k) + (1-c(k))/a2(k) * skw(:,:,k)*skw(:,:,k);
        expA(:,:,k) = [R  Z3  Z3;...
                       Z3  R  Z3;...
                       Z3 Z3  R];
    end
    
% if v_body = R * v_world and omega expressed wrt world axes     
elseif ~b2w && ~inbody
    
    % state matrix
    A = dcstatemat(w,b2w,inbody);
    
    for k = 1:n-1
        expA(:,:,k) = I9 + s(k)/a(k) * A(:,:,k) + (1-c(k))/a2(k) * A(:,:,k)*A(:,:,k);
    end
    
end

% integration steps
for k = 1:n-1
    
    % step
    dc(:,k+1) = expA(:,:,k) * dc(:,k);
    
    % orthogonalize
    dc(:,k+1) = dcm2dc(orthogonalize(dc2dcm(dc(:,k+1))));
    
end

% flip back?
if ~forward
    dc = flip(dc,2);
end

end