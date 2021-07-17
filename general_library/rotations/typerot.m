function [ rtype ] = typerot(r)
%Reed Gurchiek, 2020
%   returns the rotation operator type of the rotation operator r
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
%   rtype:
%       character array, rotation operator type
%
%--------------------------------------------------------------------------
%% typerot

% error check
acceptableTypes = {'q' 'dcm' 'xyx' 'xzx' 'yzy' 'yxy' 'zxz' 'zyz' 'xyz' 'xzy' 'yxz' 'yzx' 'zxy' 'zyx'};
if ~isstruct(r); error('rotation operator r must be a structure with one field. See description.'); end
rtype = fieldnames(r);
if length(rtype) ~= 1; error('rotation operator r must be a structure with one field. See description.'); end
if ~any(strcmpi(rtype{1},acceptableTypes)); error('rotation operator r type (fieldname) is unrecognized. See description.'); end
rtype = rtype{1};

end