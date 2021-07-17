function [ r_new ] = convq( q, new_type )
%Reed Gurchiek, 2020
%   convq converts the 4xn array of quaternions to a different rotation 
%   operator r2 of the type specified by r2_type. This is the same as
%   convrot except that the input quaternions are already in the 4xn array
%   format as opposed to the rotation operator structure format
%
%   convq works by converting q to the rotation operater structure and
%   calling convrot. Thus it is faster to use convrot if the user is
%   familiar with the format.
%
%-----------------------------INPUTS---------------------------------------
%
%   q:
%       4xn array of quaternions, rows 1-3 are vector part and row 4 is
%       scalar part, q is such that v2 = q*v1*q_conj = R*v, the R here
%       would be returned for convq(q,'dcm')
%
%   new_type:
%       char array describing the desired type of rotation notation to 
%       convert to.  acceptable types:
%           (1) 'dcm' for direction cosine matrix
%           (2) 'xyx' 'xzx' 'yxy' 'yzy' 'zxz' 'zyz' (symmetric) or
%               'xyz' 'xzy' 'yxz' 'yzx' 'zxy' 'zyx' (asymmetric) euler
%               angles
%
%----------------------------OUTPUTS---------------------------------------
%
%   r:
%       3xn array if converting to euler angles or 3x3xn array if 
%       converting to dcm
%
%--------------------------------------------------------------------------
%%  convq

% package, convert, unpack
q = packrot(q,'q');
r = convrot(q,new_type);
r_new = r.(new_type);

end