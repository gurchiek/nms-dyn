function [ v2 ] = rot( r, v1, inverse)
%Reed Gurchiek, 2020
%
%   rot rotates the vector v expressed in frame 1 (v1) using the rotation
%   operator r (quaternion, direction cosine matrix, or euler angles) so 
%   that v1 is expressed in frame 2 (v2).
%
%   for dcm: v2 = dcm * v1;
%
%   for quaternion: v2 = q * v1 * q_conj
%       where q_conj is the quaternion conjugate and the products are
%       quaternion products
%
%   for euler angles: v2 = R(e3,a3) * R(e2,a2) * R(e1,a1) * v1
%       where R(ei,ai) is the rotation matrix corresponding to rotation
%       axis ei (unit vector) and angle ai (in radians) where:
%           R(ei,ai) = I - s(ai)*[ei] + (1-c(ai))*[ei]^2
%       and [ei] is ei in skew symmetric form s.t. u = cross(ei,w) = [ei]*w
%
%----------------------------INPUTS----------------------------------------
%
%   r:
%       structure, rotation operator to be converted, can be either:
%           (1) quaternion: r.q = 4xn, rows 1-3 are vector part x,y,z and 
%               row 4 is scalar part
%           (2) direction cosine matrix: r.dcm = 3x3xn
%           (3) euler angles: r.(seq) = 3xn where seq is a char array
%               specifying the rotation sequence:
%                   'xyx' 'xzx' 'xzy' 'xyz'
%                   'yzy' 'yxy' 'yzx' 'yxz'
%                   'zxz' 'zyz' 'zxy' 'zyx'  
%
%       NOTE: if there is one rotator and multiple column vectors in v1,
%       then rot will still work, it will rotate all column vectors in v1
%       using the single rotator. Also if there is one vector v1 and 
%       multiple rotators, each rotator will rotate the single v1.
%       otherwise, any mismatch in the number of rotators and vectors to 
%       rotate will throw an error
%
%   v1:
%       3xn array of column vectors expressed in frame 1 to be rotated 
%       to be expressed in frame 2 where n is the number of vectors
%
%   inverse (optional):
%       string specifying whether to use the inverse of the input operator
%       or not. 'inv' 'inverse' or 'invert'
%
%-----------------------------OUTPUTS--------------------------------------
%
%   v2:
%       3xn image of v in frame 2
%
%--------------------------------------------------------------------------

%%  rot

% error check
r_type = typerot(r);
r = r.(r_type);
[nrow,ncol,npag] = size(r);
[vecdim,n] = size(v1);
if vecdim ~= 3; error('input vector v1 must be 3xn array of column vectors. See rot description.'); end

% if inverse specified
invf = 1;
if nargin == 3
    
    % and use inverse
    if any(strcmpi(inverse,{'inv','inverse','invert'}))
        
        % then flag
        invf = -1;
        
    end
end

% IF QUATERNION
if strcmpi(r_type,'q')
    
    % init
    if nrow ~= 4; error('quaternion must be 4 x n. See rot description.'); end
    if ncol ~= n
        if ncol == 1
            r = repmat(r,[1 n]);
        elseif n == 1
            n = ncol;
            v1 = repmat(v1,[1 n]);
        else
            error('number of quaternions must be equal to the number of input vectors in v1. See rot description.')
        end
    end
    
    % allocate
    v2 = zeros(3,n);
    
    % for each vector
    for k = 1:n
        
        % parametrize matrix and rotate
        v2(:,k) = [r(1,k)^2 - r(2,k)^2 - r(3,k)^2 + r(4,k)^2          2*(r(1,k)*r(2,k) - invf*r(4,k)*r(3,k))            2*(r(1,k)*r(3,k) + invf*r(4,k)*r(2,k)) ;...
                      2*(r(1,k)*r(2,k) + invf*r(4,k)*r(3,k))      -r(1,k)^2 + r(2,k)^2 - r(3,k)^2 + r(4,k)^2            2*(r(2,k)*r(3,k) - invf*r(4,k)*r(1,k)) ;...
                      2*(r(1,k)*r(3,k) - invf*r(4,k)*r(2,k))          2*(r(2,k)*r(3,k) + invf*r(4,k)*r(1,k))        -r(1,k)^2 - r(2,k)^2 + r(3,k)^2 + r(4,k)^2]*v1(:,k);
        
    end
    
% IF DCM
elseif strcmpi(r_type,'dcm')
    
    % init
    if nrow ~= 3 && ncol ~= 3; error('direction cosine matrix must be 3 x 3 x n. See rot description.'); end
    if npag ~= n
        if npag == 1
            r = repmat(r,[1 1 n]);
        elseif n == 1
            n = npag;
            v1 = repmat(v1,[1 n]);
        else
            error('number of dcms must be equal to the number of input vectors in v1. See rot description.')
        end
    end
    
    % allocate
    v2 = zeros(3,n);
    
    % for each vector
    for k = 1:n
        
        % if invert
        if invf == -1
        
            % invert (transpose) and rotate
            v2(1:3,k) = r(1:3,1:3,k)'*v1(:,k);
        
        % otherwise
        else
        
            % leave as is and rotate
            v2(1:3,k) = r(1:3,1:3,k)*v1(:,k);
            
        end
        
    end
    
% IF EULER ANGLES
else
    
    % init
    if nrow ~= 3; error('euler angles must be 3 x n. See rot description.'); end
    if ncol ~= n
        if ncol == 1
            r = repmat(r,[1 n]);
        elseif n == 1
            n = ncol;
            v1 = repmat(v1,[1 n]);
        else
            error('number of euler angle vectors must be equal to the number of input vectors in v1. See rot description.')
        end
    end
    
    % allocate
    v2 = zeros(3,n);
    
    % if inverse then reverse sequence, angles negated later
    seq = [1 2 3];
    if invf == -1
        seq = [3 2 1];
    end
    
    % get rotation axes and submatrices used in euler formula: R(n,a) = I - s(a)*[nx] + (1-c(a))*[nx]^2
    a = zeros(3,3);
    skew1 = zeros(3,3,3);
    skew2 = zeros(3,3,3);
    for k = 1:3
        
        % column k of a is axis of rotation for the kth rotation
        a(regexp('xyz',r_type(seq(k))),k) = 1;
        
        % get skew symmetric matrix [nx]
        skew1(:,:,k) = [   0    -a(3,k)  a(2,k);...
                         a(3,k)    0    -a(1,k);...
                        -a(2,k)  a(1,k)    0   ];
        
        % get skew symmetric matrix squared [nx]^2
        skew2(:,:,k) = skew1(:,:,k)*skew1(:,:,k);
        
    end
    
    % for each vector
    for k = 1:n
        
        % rotate v1 one rotation at a time
        v2(:,k) = (eye(3) - sin(invf*r(seq(3),k))*skew1(:,:,3) + (1 - cos(invf*r(seq(3),k)))*skew2(:,:,3))*...
                  (eye(3) - sin(invf*r(seq(2),k))*skew1(:,:,2) + (1 - cos(invf*r(seq(2),k)))*skew2(:,:,2))*...
                  (eye(3) - sin(invf*r(seq(1),k))*skew1(:,:,1) + (1 - cos(invf*r(seq(1),k)))*skew2(:,:,1))*v1(:,k);
              
    end
    
end

end

