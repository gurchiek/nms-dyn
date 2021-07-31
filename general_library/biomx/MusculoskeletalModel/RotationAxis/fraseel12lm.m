function [a1,a2] = fraseel12lm(w1,w2,a1,a2)
%   
%   functional rotation axis estimator: seel's 2012 method and levenberg
%   marquardt as opposed to gauss-newton as described in seel paper
%
%   angular velocities w1,w2 should be of two bodies (1,2) that articulate
%   via a hinge joint
%
%----------------------------------INPUTS----------------------------------
%
%   w1:
%       3xn array of angular velocity vector of frame 1 measured in frame 1
%
%   w2:
%       3xn array of angular velocity vector of frame 2 measured in frame 2
%
%   a1:
%       3x1 initial guess of rotation axis in frame 1, needs to be in
%       correct half plane
%
%   a2:
%       3x1 initial guess of rotation axis in frame 2, needs to be in
%       correct half plane
%
%---------------------------------OUTPUTS----------------------------------
%
%   a1,a2:
%       3x1 unit vector specifying the joint axis in frame 1 and frame 2
%
%--------------------------------------------------------------------------
%% fraseel12lm

% convert cartesian to spherical coordinates (a1 and a2 unit length)
a1 = normalize(a1,1,'norm');
[phi1,theta1] = cart2sphere(a1);
a2 = normalize(a2,1,'norm');
[phi2,theta2] = cart2sphere(a2);

% levenberg marquardt
x0 = [phi1, theta1, phi2, theta2]';
options = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt','SpecifyObjectiveGradient',true,'Display','none');
x = lsqnonlin(@(x)fun(x,w1,w2),x0,[],[],options);

% spherical to cartesian
n1 = [cos(x(1))*cos(x(2)); cos(x(1))*sin(x(2)); sin(x(1))];
n2 = [cos(x(3))*cos(x(4)); cos(x(3))*sin(x(4)); sin(x(3))];

% normalize and make sure in correct half plane
a1 = sign(n1'*a1) * normalize(n1,1,'norm');
a2 = sign(n2'*a2) * normalize(n2,1,'norm');

end

function [err,jac] = fun(x,w1,w2)

n1 = [cos(x(1))*cos(x(2)); cos(x(1))*sin(x(2)); sin(x(1))];
n2 = [cos(x(3))*cos(x(4)); cos(x(3))*sin(x(4)); sin(x(3))];
err = zeros(size(w1,2),1);
jac = zeros(size(w1,2),4);

for k = 1:size(w1,2)
    s1 = skew(w1(:,k));
    s2 = skew(w2(:,k));
    err(k) = n2' * s2 * s2 * n2 - n1' * s1 * s1 * n1;
    
    derr_dn1 = -2 * n1' * s1 * s1;
    derr_dn2 =  2 * n2' * s2 * s2;
    
    dn1_dx1 = [-sin(x(1))*cos(x(2)); -sin(x(1))*sin(x(2)); cos(x(1))];
    dn1_dx2 = [-cos(x(1))*sin(x(2));  cos(x(1))*cos(x(2));     0    ];
    dn2_dx3 = [-sin(x(3))*cos(x(4)); -sin(x(3))*sin(x(4)); cos(x(3))];
    dn2_dx4 = [-cos(x(3))*sin(x(4));  cos(x(3))*cos(x(4));     0    ];
    
    jac(k,1) = derr_dn1 * dn1_dx1;
    jac(k,2) = derr_dn1 * dn1_dx2;
    jac(k,3) = derr_dn2 * dn2_dx3;
    jac(k,4) = derr_dn2 * dn2_dx4;

end

end

function [phi,theta,r] = cart2sphere(u)

r = vecnorm(u);
u = u/r;
TOL = 1e-12;
phi = asin(u(3));
if abs(cos(phi)) < TOL
    theta = 0;
else
    if abs(u(1)) > TOL
        if abs(u(2)) > TOL
            theta = atan2(u(2),u(1));
        else
            theta = acos(u(1)/cos(phi));
        end
    else
        theta = asin(u(2)/cos(phi));
    end
end

end

