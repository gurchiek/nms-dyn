function [ r_new ] = convdcm( dcm, new_type )
%Reed Gurchiek, 2020
%   convdcm converts the 3x3xn array of direction cosine matrices to a 
%   different rotation operator r2 of the type specified by r2_type. This 
%   is the same as convrot except that the input dcms are already in the 
%   3x3xn array format as opposed to the rotation operator structure format
%
%   convdcm works by converting dcm to the rotation operater structure and
%   calling convrot. Thus it is faster to use convrot if the user is
%   familiar with the format.
%
%-----------------------------INPUTS---------------------------------------
%
%   dcm:
%       3x3xn array of rotation matrices
%
%   new_type:
%       char array describing the desired type of rotation notation to 
%       convert to.  acceptable types:
%           (1) 'q' for quaternion
%           (2) 'xyx' 'xzx' 'yxy' 'yzy' 'zxz' 'zyz' (symmetric) or
%               'xyz' 'xzy' 'yxz' 'yzx' 'zxy' 'zyx' (asymmetric) euler
%               angles
%
%----------------------------OUTPUTS---------------------------------------
%
%   r_new:
%       3xn array if converting to euler angles or 3x3xn array if 
%       converting to dcm
%
%--------------------------------------------------------------------------

%%  convdcm

% package, convert, unpack
dcm = packrot(dcm,'dcm');
r = convrot(dcm,new_type);
r_new = r.(new_type);

end