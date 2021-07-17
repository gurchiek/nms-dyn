function [ r, rtype ] = unpackrot(r)
%Reed Gurchiek, 2020
%   returns the numeric array of the rotation operator r and its type
%
%----------------------------------INPUTS----------------------------------
%
%   r:
%       structure, rotation operator, type corresponds to field name:
%           (1) quaternion: r.q = 4xn, rows 1-3 are vector part x,y,z and 
%               row 4 is scalar part
%           (2) direction cosine matrix: r.dcm = 3x3xn
%           (3) euler angles: r.(seq) = 3xn where seq is a char array
%               specifying the rotation sequence:
%                   'xyx' 'xzx' 'xzy' 'xyz'
%                   'yzy' 'yxy' 'yzx' 'yxz'
%                   'zxz' 'zyz' 'zxy' 'zyx'  
%
%---------------------------------OUTPUTS----------------------------------
%
%   r:
%       rotation operator in array format
%
%   rtype:
%       character array, rotation operator type
%
%--------------------------------------------------------------------------
%% unpackrot

% type
rtype = typerot(r);
nr = size(r.(rtype),1);
if nr ~= 3 && nr ~= 4; error('numeric array of rotation operator must be either 3 or 4. Check rotation operator.'); end
r = r.(rtype);

end