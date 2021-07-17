function [ v2 ] = eulerot( e, seq, v1, inverse)
%Reed Gurchiek, 2020
%   rotate v1 to v2 using euler angle vectors e and corresponding sequence
%   seq. eulerrot simply packs e as a rotation operator structure and calls
%   rot. See rot for more
%
%----------------------------INPUTS----------------------------------------
%
%   e:
%       3 x n array of euler angles
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
%%  eulerrot

% package & rotate
e = packrot(e,seq);
if nargin == 4
    v2 = rot(e,v1,inverse);
else
    v2 = rot(e,v1);
end

end