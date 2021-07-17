function jac = qprodmatjac(order)
%Reed Gurchiek, 2020
%
%   returns derivative of matrix (Q) with respect to quaternion q 
%   corresponding to the quaternion product
%
%                       q*p = Q*p if order = 1
%   or 
%                       p*q = Q*p if order = 2
%
%----------------------------INPUTS----------------------------------------
%
%   order:
%       1 or 2, same as that in qprodmat
%
%-----------------------------OUTPUTS--------------------------------------
%
%   jac:
%       4 x 4 x 4 array where jac(:,:,k) = dQ/dqk where Q is the matrix
%       corresponding to the quaternion product (see description)
%
%--------------------------------------------------------------------------
%%  qprodmatjac

I = eye(3);
jac(:,:,4) = eye(4);
c = 1;
if order == 2; c = -1; end
for k = 1:3
    jac(:,:,k) = [c * skew(I(:,k)), I(:,k);...
                       -I(:,k)'        0  ];
end

end