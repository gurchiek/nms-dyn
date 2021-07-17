function [ edot, w, J ] = diffeuler(e,seq,b2w,t,npoint)
%Reed Gurchiek, 2020
%   numerically differentiates euler angle vector
%
%----------------------------------INPUTS----------------------------------
%
%   e:
%       3 x n euler angles in radians
%
%   seq:
%       sequence of euler angle rotation (see rot)
%       
%
%   b2w:
%       if 1, then, v_world = eulerot(e,seq,v_body)
%       if 0, then, v_body = eulerot(e,seq,v_world)
%
%   t, npoint:
%       see input to fdiff
%
%---------------------------------OUTPUTS----------------------------------
%
%   edot:
%       euler angle derivative
%
%   w:
%       anguluar rate of body frame expressed in body frame
%
%   J:
%       3 x 3 x n jacobian s.t. w_body = J * edot
%
%--------------------------------------------------------------------------
%% diffeuler

% euler derivative
edot = fdiff(e,t,npoint);

% jacobian
J = eulerjac(e,seq,b2w,1,0);

% angular rate
n = size(e,2);
w = zeros(3,n);
for k = 1:n
    w(:,k) = J(:,:,k) * edot(:,k);
end

end