function R = visdcm(type)
%Reed Gurchiek, 2021
%
%   visualize dcm parameterized by either quaternion (type = 'q') or an
%   euler angle sequence (eg 'xyz'). This useful for analysis. No error
%   checks are done to make sure input type is acceptable.
%
%----------------------------INPUTS----------------------------------------
%
%   type:
%       char, specifies type of rotation representation for parametrizing dcm:
%           (1) q: q1-q3 are x,y,z vector part and q4 is scalar part
%           (2) euler angles: si/ci are sin and cos of angle i about axis i:
%                   'xyx' 'xzx' 'xzy' 'xyz'
%                   'yzy' 'yxy' 'yzx' 'yxz'
%                   'zxz' 'zyz' 'zxy' 'zyx' 
%
%-----------------------------OUTPUTS--------------------------------------
%
%   R:
%       3 x 3 symbolic matrix parametrized by input type
%
%--------------------------------------------------------------------------

%%  vsdcm

% IF QUATERNION
if type(1) == 'q'
    
    syms q1 q2 q3 q4
    
    R = QL(q1,q2,q3,q4) * QR(q1,q2,q3,q4).';
    
    disp(R)
    
% IF EULER ANGLES
else
    
    syms s1 c1 s2 c2 s3 c3
    
    n1 = eval(type(1));
    n2 = eval(type(2));
    n3 = eval(type(3));
    
    R1 = eye(3) - s1 * skew(n1) + (1 - c1) * skew(n1) * skew(n1);
    R2 = eye(3) - s2 * skew(n2) + (1 - c2) * skew(n2) * skew(n2);
    R3 = eye(3) - s3 * skew(n3) + (1 - c3) * skew(n3) * skew(n3);
    
    R = R3 * R2 * R1;
    disp(R)
end

end

% rotation axes
function n = x(); n = [1 0 0]'; end
function n = y(); n = [0 1 0]'; end
function n = z(); n = [0 0 1]'; end

% left quaternion product matrix
function A = QL(q1,q2,q3,q4)

A = [ q4 -q3  q2 q1;...
      q3  q4 -q1 q2;...
     -q2  q1  q4 q3;...
     -q1 -q2 -q3 q4];
 
end

% right quaternion product matrix
function A = QR(q1,q2,q3,q4)


A = [ q4  q3 -q2 q1;...
     -q3  q4  q1 q2;...
      q2 -q1  q4 q3;...
     -q1 -q2 -q3 q4];

end