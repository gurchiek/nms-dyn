function [ qdot, w, J ] = diffq(q,b2w,t,npoint)
%Reed Gurchiek, 2020
%   numerically differentiates quaternions
%
%----------------------------------INPUTS----------------------------------
%
%   q:
%       4 x n array of quaternion column vectors, row 4 = scalar part, rows
%       1-3 = vector part
%
%   b2w:
%       if 1 then v_world = q * v_body * q_conj
%       if 0 then v_body = q * v_world * q_conj
%
%   t, npoint:
%       see input to fdiff
%
%---------------------------------OUTPUTS----------------------------------
%
%   qdot:
%       quaternion derivative
%
%   w:
%       anguluar rate of body frame expressed in body frame
%
%   J:
%       3 x 4 x n jacobian s.t. w_body = J * qdot
%
%--------------------------------------------------------------------------
%% diffq

% qdot
qdot = fdiff(q,t,npoint);

% jacobian
J = qjac(q,b2w,1,0);

% angular rate
n = size(qdot,2);
w = zeros(3,n);
for k = 1:n
    w(:,k) = J(:,:,k) * qdot(:,k);
end

end