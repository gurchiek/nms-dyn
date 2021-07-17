function [qinv] = invq(q)
%Reed Gurchiek, 2020
%
%   inverts quaternion q s.t. q * qinv = qinv * q = 1
%
%   note, this function does not assume quaternions are unit length. If
%   want to invert unit length quaternions (for rotation), just use qconj
%
%----------------------------INPUTS----------------------------------------
%
%   q:
%       4 x n array of quaternions where rows 1-3 are vector part (x,y,z)
%       and row 4 is scalar part
%
%-----------------------------OUTPUTS--------------------------------------
%
%   qinv:
%       4 x n array of inverted quaternions
%
%--------------------------------------------------------------------------
%% invq

qinv = qconj(q) ./ dot(q,q);
     
end