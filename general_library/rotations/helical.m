function [n,a,s,t] = helical(R,v,tol)
%Reed Gurchiek, 2020
%   convert rigid body displacement in terms of rotation matrix R and
%   linear displacement v into helical parameters where
%
%                   v_world = R * v_body + v
%
%   and
%
%       v_world = v_body + t * n + (1 - cos(a)) * n X (n X (v_body - s)) + sin(a) * n X (v_body - s)
%
%   where X is cross product and n, a, s, t are output from helical
%
%   see Spoor and Veldpaus (1980)
%
%----------------------------------INPUTS----------------------------------
%
%   R:
%       3 x 3 rotation matrix
%
%   v:
%       3 x 1 displacement vector
%
%   tol (optional: default = 1e-4):
%       denominator tolerance, may divide by values larger than this
%
%---------------------------------OUTPUTS----------------------------------
%
%   n, a, s, t:
%       parameters which parametrize the helical representation of rigid
%       body displacement (see description)
%
%--------------------------------------------------------------------------
%% helical

if nargin == 2; tol = 1e-4; end

% sin(angle) * n
san = 1/2 * [R(3,2) - R(2,3);...
             R(1,3) - R(3,1);...
             R(2,1) - R(1,2)];

% angle of rotation
sa = sqrt(san'*san); % sin(angle)
ca = 1/2 * (trace(R) - 1); % cos(angle)
% if sa <= 1/2 * sqrt(2) % spoor and veldpaus recommend this conditional (see statement after eq 34), but I prefer to use acos since the range of asin is -pi to pi
%     a = asin(sa);
% else
%     a = acos(ca);
% end
a = acos(ca);

% helical axis
if a > 3/4 * pi % see statement just before eq 35 in spoor and veldpaus
    B = 1/2 * (R + R') - ca * eye(3);
    Bmag = vecnorm(B);
    [mag,imax] = max(Bmag);
    n = B(:,imax) / mag;
    
    % make n s.t. sin(angle) is positive
    n = sign(san'*n*sa) * n;
    
elseif abs(a) > tol
    n = san/sa;
end

% translation component (t) and rotation point (s)

% if effectively no rotation
if abs(a) < tol
    
    % just displacement
    t = sqrt(v'*v);
    n = v/t;
    s = [0 0 0]';
    
% rotation + translation
else
    t = n'*v;
    s = -1/2 * cross(n,cross(n,v)) + sa / 2 / (1 - ca) * cross(n,v);
end

end