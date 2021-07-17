function [rinv] = invrot( r )
%Reed Gurchiek, 2020
%
%   inverts rotation operator r. The inverted rotation operator rinv is
%   such that,
%
%                       rot(r,v,'inv')
%
%   is equivalent to,
%
%                      rot(invrot(r),v).
%
%----------------------------INPUTS----------------------------------------
%
%   r:
%       structure, rotation operator to be inverted, can be either:
%           (1) quaternion: r.q = 4xn, rows 1-3 are vector part x,y,z and 
%               row 4 is scalar part
%           (2) direction cosine matrix: r.dcm = 3x3xn
%           (3) euler angles: r.(seq) = 3xn where seq is a char array
%               specifying the rotation sequence:
%                   'xyx' 'xzx' 'xzy' 'xyz'
%                   'yzy' 'yxy' 'yzx' 'yxz'
%                   'zxz' 'zyz' 'zxy' 'zyx'  
%
%           (c) DCM: 3x3xn where n is the number of matrices
%
%-----------------------------OUTPUTS--------------------------------------
%
%   rinv:
%       inverted rotator
%
%--------------------------------------------------------------------------
%% invrot

% error check
r_type = typerot(r);
r = r.(r_type);

% quaternion (conjugate)
if strcmpi(r_type,'q')
    nr = size(r,1);
    if nr ~= 4; error('quaternion must be 4 x n (row 4 = scalar part, rows 1-3 = vector part)'); end
    rinv.q = diag([-1 -1 -1 1]) * r;
% dcm (transpose)
elseif strcmpi(r_type,'dcm')
    [nr,nc,np] = size(r);
    if nr ~= 3 || nc ~= 3; error('dcm must be 3 x 3 x n'); end
    for k = 1:np; r(:,:,k) = r(:,:,k)'; end
    rinv.dcm = r;
% euler angle (negate and reverse order)
else
    nr = size(r,1);
    if nr ~= 3; error('euler angles must be 3 x n'); end
    r_type = [r_type(3) r_type(2) r_type(1)];
    rinv.(r_type) = -[r(3,:); r(2,:); r(1,:)];
end
