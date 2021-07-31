function [a1,a2] = fraseel12gn(w1,w2,a1,a2,maxiter,tol)
%   
%   functional rotation axis estimator: seel's 2012 method, gauss-newton
%   solution as described in seel's paper. for levenberg-marquardt, use
%   fraseel12lm
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
%% fraseel12

% optimization defaults
if nargin == 4
    maxiter = 10;
    tol = 0.0;
elseif nargin == 5
    if maxiter < inf
        tol = 0.0;
    else
        tol = 1e-4;
    end
end

% convert cartesian to spherical coordinates (a1 and a2 unit length)
a1 = normalize(a1,1,'norm');
[phi1,theta1] = cart2sphere(a1);
a2 = normalize(a2,1,'norm');
[phi2,theta2] = cart2sphere(a2);
a1init = a1;
a2init = a2;

% gauss-newton
x = [phi1 theta1 phi2 theta2]';
n = size(w1,2);
err = zeros(n,1);
jac = zeros(n,4);
iter = 1;
relative_step = inf;
while iter <= maxiter && relative_step > tol
    
    for k = 1:n

        a1 = [cos(x(1)) * cos(x(2)); cos(x(1)) * sin(x(2)); sin(x(1))];
        a2 = [cos(x(3)) * cos(x(4)); cos(x(3)) * sin(x(4)); sin(x(3))];

        da1_dphi1 =   [-sin(x(1)) * cos(x(2)); -sin(x(1)) * sin(x(2)); cos(x(1))];
        da1_dtheta1 = [-cos(x(1)) * sin(x(2));  cos(x(1)) * cos(x(2));     0    ];
        da2_dphi2 =   [-sin(x(3)) * cos(x(4)); -sin(x(3)) * sin(x(4)); cos(x(3))];
        da2_dtheta2 = [-cos(x(3)) * sin(x(4));  cos(x(3)) * cos(x(4));     0    ];

        projmag1 = vecnorm(cross(w1(:,k),a1));
        projmag2 = vecnorm(cross(w2(:,k),a2));
        err(k) = projmag1 - projmag2;

        jac(k,1) =  dot(cross(cross(w1(:,k),a1),a1)/projmag1,da1_dphi1);
        jac(k,2) =  dot(cross(cross(w1(:,k),a1),a1)/projmag1,da1_dtheta1);
        jac(k,3) = -dot(cross(cross(w2(:,k),a2),a2)/projmag2,da2_dphi2);
        jac(k,4) = -dot(cross(cross(w2(:,k),a2),a2)/projmag2,da2_dtheta2);

    end

    xnew = x - pinv(jac) * err;
    delta_x = x - xnew;
    relative_step = vecnorm(delta_x) / vecnorm(x);

    x = xnew;
    iter = iter + 1;

end

% spherical to cartesian, normalize, make sure in correct half plane
a1 = [cos(x(1)) * cos(x(2)); cos(x(1)) * sin(x(2)); sin(x(1))];
a1 = sign(a1init'*a1) * normalize(a1,1,'norm');
a2 = [cos(x(3)) * cos(x(4)); cos(x(3)) * sin(x(4)); sin(x(3))];
a2 = sign(a2init'*a2) * normalize(a2,1,'norm');

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