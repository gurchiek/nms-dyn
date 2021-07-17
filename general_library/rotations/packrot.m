function [ rpack ] = packrot(r,rtype)
%Reed Gurchiek, 2020
%   returns the rotation operator r given the rotation operator numeric
%   array r and type rtype
%
%----------------------------------INPUTS----------------------------------
%
%   r:
%       numeric array of rotation operator:
%           (1) quaternion: r = 4xn, rows 1-3 are vector part x,y,z and 
%               row 4 is scalar part
%           (2) direction cosine matrix: r = 3x3xn
%           (3) euler angles: r = 3xn
%
%   rtype:
%       char array, rotation operator type
%           (1) quaternion => 'q'
%           (2) direction cosine matrix => 'dcm'
%           (3) euler angles => rotation sequence:
%
%                   'xyx' 'xzx' 'xzy' 'xyz'
%                   'yzy' 'yxy' 'yzx' 'yxz'
%                   'zxz' 'zyz' 'zxy' 'zyx'  
%
%---------------------------------OUTPUTS----------------------------------
%
%   rpack:
%       structure, field corresponds to rtype
%
%--------------------------------------------------------------------------
%% packrot

% error check
acceptableTypes = {'q' 'dcm' 'xyx' 'xzx' 'yzy' 'yxy' 'zxz' 'zyz' 'xyz' 'xzy' 'yxz' 'yzx' 'zxy' 'zyx'};
if ~any(strcmpi(rtype,acceptableTypes)); error('rtype is unrecognized. See description.'); end
[nr,nc] = size(r,1,2);
if strcmpi(rtype,'q')
    if nr ~= 4
        error('quaternion must have 4 rows (row 4 = scalar part, rows 1-3 = vector part).');
    end
elseif strcmpi(rtype,'dcm')
    if nr ~= 3 || nc ~= 3
        error('direction cosine matrix must be 3 x 3 x n.');
    end
else
    if nr ~= 3
        error('euler angles must be 3 x n.');
    end
end
rpack.(rtype) = r;

end