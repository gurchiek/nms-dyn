function [ q ] = qconj( q )
%Reed Gurchiek, 2020
%
%   qconj returns the quaternion conjugate of the quaternion(s) q
%
%-----------------------INPUTS---------------------------------------------
%
%   q:
%       4xn column vector of quaternions for which to compute the conjugate
%       where n is the number of quaternions; row 4 is scalar part of 
%       quaternion and rows 1-3 = qx, qy, qz are vector part of quaternion
%
%--------------------OUTPUTS-----------------------------------------------
%
%   q:
%       4xn column vector of the quaternion conjugate of input q
%
%--------------------------------------------------------------------------
%%  qconj

% error check
qr = size(q,1);
if qr ~= 4
    error('quaternion q must be 4 element column vector (row 4 = scalar part, rows 1-3 = vector part)')
end

q = diag([-1 -1 -1 1]) * q;

end

