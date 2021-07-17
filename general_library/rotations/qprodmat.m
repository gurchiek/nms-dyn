function [ qmat ] = qprodmat( q, order )
%% Reed Gurchiek, 2020
%
%   computes the matrix qmat such that the quaternion product qp = q*p is
%   equivalent to qmat * p if order = 1, or if order = 2 then it computes
%   the matrix qmat such that pq = p*q = qmat * p.
%
%-----------------------------INPUTS---------------------------------------
%
%   q:
%       4 x n array of quaternions where row 4 is scalar part and rows 1 - 3 is the
%       vector part of the quaternion
%
%   order:
%       1 or 2, specifies whether q is first, e.g. q*p, or second, e.g. p*q
%
%----------------------------OUTPUTS---------------------------------------
%
%   qmat:
%       4x4 matrix such that the quaternion product q*p is equivalent to
%       qmat*p if order = 1 or such that the quaternion product p*q is
%       equivalent to qmat*p if order = 2
%
%--------------------------------------------------------------------------
%% qprodmat

% error check
[qr,qn] = size(q);
if qr ~= 4
    error('quaternion must be 4 element column vector (row 4 = scalar part, rows 1-3 = vector part)')
elseif order ~= 1 && order ~= 2
    error('order must either be 1 or 2')
end

% get matrices (scalar part = p0*q0 - <pv,qv>, vector part = p0*qv + q0*pv + pvXqv)
qmat = zeros(4,4,qn);
for k = 1:qn
    if order == 1
        qmat(:,:,k) = [ q(4,k) -q(3,k)  q(2,k) q(1,k);...
                        q(3,k)  q(4,k) -q(1,k) q(2,k);...
                       -q(2,k)  q(1,k)  q(4,k) q(3,k);...
                       -q(1,k) -q(2,k) -q(3,k) q(4,k)];
    elseif order == 2
        qmat(:,:,k) = [ q(4,k)  q(3,k) -q(2,k) q(1,k);...
                       -q(3,k)  q(4,k)  q(1,k) q(2,k);...
                        q(2,k) -q(1,k)  q(4,k) q(3,k);...
                       -q(1,k) -q(2,k) -q(3,k) q(4,k)];
    end
end

end