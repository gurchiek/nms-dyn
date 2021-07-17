function [jac2] = qrotjac2()
%Reed Gurchiek, 2020
%
%   returns the 2nd partial derivative of the rotation matrix (R)
%   parametrized by quaternion (q) s.t.
%
%                  v2 = q * v1 * q_conj = R * v1
%
%   q is a vector so dR/dq is a matrix and qrotjac2 computes the partial
%   wrt to q of this matrix (technically a 3rd order tensor): d/dq(dR/dq)
%
%   q1-q3 are vector part (x,y,z) and q4 is scalar part
%
%----------------------------INPUTS----------------------------------------
%
%   n/a
%
%-----------------------------OUTPUTS--------------------------------------
%
%   jac2:
%       4 element structure with field jac which is a 3 x 3 x 4 array
%       
%       e.g. jac2(i).jac(:,:,k) = d/dqi * dR/dqk
%
%--------------------------------------------------------------------------
%%  qrotjac2

% jac2(i).jac(:,:,j) = d/dqj * dR/dqi
I = eye(3);

% d/dq * dR/dq1
jac2(1).jac(:,:,1) = diag([2 -2 -2]);
jac2(1).jac(:,:,2) = 2 * symm(1,2);
jac2(1).jac(:,:,3) = 2 * symm(1,3);
jac2(1).jac(:,:,4) = 2 * skew(I(:,1));

% d/dq * dR/dq2
jac2(2).jac(:,:,1) = 2 * symm(2,1);
jac2(2).jac(:,:,2) = diag([-2 2 -2]);
jac2(2).jac(:,:,3) = 2 * symm(2,3);
jac2(2).jac(:,:,4) = 2 * skew(I(:,2));

% d/dq * dR/dq3
jac2(3).jac(:,:,1) = 2 * symm(3,1);
jac2(3).jac(:,:,2) = 2 * symm(3,2);
jac2(3).jac(:,:,3) = diag([-2 -2 2]);
jac2(3).jac(:,:,4) = 2 * skew(I(:,3));

% d/dq * dR/dq4
jac2(4).jac(:,:,1) = 2 * skew(I(:,1));
jac2(4).jac(:,:,2) = 2 * skew(I(:,2));
jac2(4).jac(:,:,3) = 2 * skew(I(:,3));
jac2(4).jac(:,:,4) = 2 * I;

end

function m = symm(i,j)
m = zeros(3);
m(i,j) = 1;
m(j,i) = 1;
end