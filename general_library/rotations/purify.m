function [ vpure ] = purify(v)
%Reed Gurchiek, 2020
%   make 3-element column vector a pure quaternion where rows 1-3 of
%   quaternion are vector part (x,y,z) and row 4 is scalar part
%
%----------------------------------INPUTS----------------------------------
%
%   v:
%       3 x n array of column vectors
%
%---------------------------------OUTPUTS----------------------------------
%
%   vpure:
%       4 x n array of quaternions s.t. q(1:3,i) = v(:,i) and q(4,i) = 0
%
%--------------------------------------------------------------------------
%% purify

vpure = [v; zeros(1,size(v,2))];

end