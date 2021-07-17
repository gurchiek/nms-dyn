function [ v ] = impurify(vpure)
%Reed Gurchiek, 2020
%   make 4D pure quaternion a 3D column vector
%
%----------------------------------INPUTS----------------------------------
%
%   vpure:
%       4 x n array of pure quaternion column vectors, row 4 is scalar part
%       (for pure quaternions, scalar is 0), rows 1-3 are vector part
%
%---------------------------------OUTPUTS----------------------------------
%
%   v:
%       3 x n array of vector part of input quaternions
%
%--------------------------------------------------------------------------
%% impurify

v = vpure(1:3,:);

end