function [ r_new ] = conveuler( e, seq, new_type )
%Reed Gurchiek, 2020
%   conveuler converts the 3xn array of euler angles to a  different 
%   rotation operator r_new of the type specified by new_type. This 
%   is the same as convrot except that the input is already in the 3xn 
%   array format as opposed to the rotation operator structure format
%
%-----------------------------INPUTS---------------------------------------
%
%   e:
%       3xn array of euler angles where row i corresponds to angle i and
%       corresponds to the rotation:
%
%       v_2 = R(n3),e(3)) * R(n2,e(2)) * R(n1,e(1) * v_1
%
%       where R(ni,e(i)) = I - sin(ei)*skew(ni) + (1-cos(ei)) * skew(ni)^2
%       and ni is the axis specified by the corresponding character in seq,
%       for example, if seq = 'xyz' then n1 = x = [1 0 0]'
%
%   seq:
%       3 element char array specifying the order of rotations, can be
%       symmetric or asymmetric sequence
%
%           'xyx' 'xzx' 'yxy' 'yzy' 'zxz' 'zyz' (symmetric) or
%           'xyz' 'xzy' 'yxz' 'yzx' 'zxy' 'zyx' (asymmetric)
%
%   new_type:
%       char array describing the desired type of rotation notation to 
%       convert to.  acceptable types:
%           (1) 'q' for quaternion
%           (2) 'dcm' for direction cosine matrix
%
%----------------------------OUTPUTS---------------------------------------
%
%   r_new:
%       4xn array if converting to quaternion or 3x3xn array if 
%       converting to dcm
%
%--------------------------------------------------------------------------

%%  conveuler

% package, convert, unpack
e = packrot(e,seq);
r = convrot(e,new_type);
r_new = r.(new_type);

end