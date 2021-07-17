function [ dcmdot, w, J, dcdot ] = diffdcm(dcm,b2w,t,npoint)
%Reed Gurchiek, 2020
%   numerically differentiates direction cosine matrix
%
%----------------------------------INPUTS----------------------------------
%
%   dcm:
%       3 x 3 x n array of direction cosine matrices
%
%   b2w:
%       if 1 then v_world = dcm * v_body
%       if 0 then v_body = dcm * v_world
%
%   t, npoint:
%       see input to fdiff
%
%---------------------------------OUTPUTS----------------------------------
%
%   dcmdot:
%       dcm time-derivative
%
%   w:
%       anguluar rate of body frame expressed in body frame
%
%   J:
%       3 x 9 x n jacobian s.t. w_body = J * [xdot; ydot; zdot] where 
%       x,y,z are the first, second, and third columns of dcm respectively
%
%   dcdot:
%       time derivative of vector of direction cosines [xdot; ydot; zdot]
%
%--------------------------------------------------------------------------
%% diffdcm

% get vector of direction cosines
n = size(dcm,3);
dc = zeros(9,n); 
for k = 1:n; dc(:,k) = [dcm(:,1,k); dcm(:,2,k); dcm(:,3,k)]; end

% dcdot
dcdot = fdiff(dc,t,npoint);

% jacobian
J = dcjac(dc,b2w,1,0);

% angular rate
w = zeros(3,n);
for k = 1:n
    w(:,k) = J(:,:,k) * dcdot(:,k);
end

% back to dcm
dcmdot = zeros(3,3,n);
for k = 1:n; dcmdot(:,:,k) = [dcdot(1:3,k) dcdot(4:6,k) dcdot(7:9,k)]; end

end