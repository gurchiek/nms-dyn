function [ v2 ] = qrot( q, v1, inverse)
%Reed Gurchiek, 2020
%
%   qrot rotates the vector v expressed in frame 1 (v1) using the input 
%   quaternion q so that v1 is expressed in frame 2 (v2).
%
%                       v2 = q * v1 * q_conj
%
%   qrot simply packages q as an arbitrary rotation operator struct and
%   calls rot
%
%----------------------------INPUTS----------------------------------------
%
%   q:
%       4 x n array of quaternions, rows 1-3 are vector part, row 4 is 
%       scalar part
%
%   v1:
%       3xn array of column vectors expressed in frame 1 to be rotated 
%       to be expressed in frame 2 where n is the number of vectors
%
%-----------------------------OUTPUTS--------------------------------------
%
%   v2:
%       3xn image of v in frame 2
%
%--------------------------------------------------------------------------
%%  qrot

% package & rotate
q = packrot(q,'q');
if nargin == 3
    v2 = rot(q,v1,inverse);
else
    v2 = rot(q,v1);
end

end
