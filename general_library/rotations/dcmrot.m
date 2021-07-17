function [ v2 ] = dcmrot( dcm, v1, inverse)
% Reed Gurchiek, 2020
%   rotates v1 to v2 using dcm. dcmrot packages the 3 x 3 x n input dcms as
%   a rotation operator structure and calls rot
%
%----------------------------INPUTS----------------------------------------
%
%   dcm:
%       3 x 3 x n array of direction cosine matrices
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
%%  dcmrot

% package & rotate
dcm = packrot(dcm,'dcm');
if nargin == 3
    v2 = rot(dcm,v1,inverse);
else
    v2 = rot(dcm,v1);
end

end