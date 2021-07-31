function [mtuLength,vp] = musclePathAroundCylinder_v3(origin,insertion,axis,position,radius)

% solves for exact point where MTU meets cylinder from both origin and
% insertion and creates VPs and 1 mm intervals along the elliptical arc of
% the elliptical cross section the MTU makes with the cylinder.

% WARNING: it can take a very long time, better approach is to use v4 which
% is not much of a loss of accuracy but it much faster

% origin - muscle origin in global frame, 3x1
% insertion - muscle insertion in global frame, 3x1
% axis - cylinder axis, 3x1 unit vector
% position - cylinder position, 3x1, some point on axis
% radius - cylinder radius in meters

% simplify notation
o = origin;
i = insertion;
a = normalize(axis,1,'norm');
p = position;

% vectors
v = o-i;
vhat = normalize(v,1,'norm');
n = p-i;

% cos and sin of angle between v and a
c = vhat' * a;
s = vecnorm(cross(a,vhat));

% get point on axis closest to line insertion to origin (h)
tau = ( (vhat'*n) * c - n' * a ) / (1 - c * c);
h = n + tau * a; % vector from insertion to point on cylinder axis closes to line: insertion to origin (v)

% get semi minor/major axes of ellipse that muscle path lies in
% for general cylinder cross-section the radius of the cylinder will not
% always be the length of the minor axis but since this cross section is
% for the MTU path wrapping around the cylinder in the SHORTEST distant,
% then it is
r = radius;
l = r * sqrt(1 + c * c / s / s);

% muscle path plane
x = vhat; % center of ellipse is origin, this is x axis
y = normalize(cross(a,vhat),1,'norm'); % ellipse frame y axis
ox = (v-h)'*x; % x coordinate of origin in ellipse frame
oy = (v-h)'*y; % y coordinate of origin in ellipse frame
ix = -h'*x; % x coordinate of insertion in ellipse frame
iy = oy; % y coordinate of insertion in ellipse frame

% min/max x for point on ellipse from origin
x1_min = 0;
x1_max = l;

% min/max y for point on ellipse from origin
y1_min = oy;
y1_max = r;

% min/max x for point on ellipse from insertion
x2_min = -l;
x2_max = 0;

% min/max y for point on ellipse from insertion
y2_min = iy;
y2_max = r;

% if y components larger than radius then doesnt touch
if oy >= r
    
    vp = [];
    mtuLength = vecnorm(v);

% otherwise continue
else
    
    % setup optimization for point on ellipse
    options = optimoptions('fmincon','Algorithm','interior-point','CheckGradients',false,'ConstraintTolerance',1e-6,'Display','off','SpecifyConstraintGradient',true,'SpecifyObjectiveGradient',true,'HessianFcn',@fhess);
    
    % get point where MTU touches ellipse from origin
    % initial guess
    x1 = l/10; 
    y1 = r * sqrt( 1 - x1*x1/l/l);
    z1 = [x1 y1]';
    z1 = fmincon(@fobj,z1,[],[],[],[],[x1_min, y1_min]*100,[x1_max, y1_max]*100,@fcon,options,[ox; oy]*100,r*100,l*100); % operate on values in cm
    z1 = z1/100; % convert back to m
    
    % get point where MTU touches ellipse from insertion
    % initial guess
    x2 = -l/10; 
    y2 = r * sqrt( 1 - x2*x2/l/l);
    z2 = [x2 y2]';
    z2 = fmincon(@fobj,z2,[],[],[],[],[x2_min, y2_min]*100,[x2_max, y2_max]*100,@fcon,options,[ix; iy]*100,r*100,l*100);
    z2 = z2/100;

    % instead of approximating elliptic integral of second kind, just create
    % via points at 1 mm intervals from origin contact to insertion contact
    % along x coordinate of ellipse plane
    dx = 0.001;
    if z1(2) >= 0 
        xvals1 = [z1(1) , z1(1)-dx:-dx:0+dx , 0];
        ysign1 = ones(1,length(xvals1));
    else
        xvals1a = [z1(1) , z1(1)+dx:dx:l-dx , l];
        ysign1a = -ones(1,length(xvals1a));
        xvals1b = l-dx:-dx:0;
        ysign1b = ones(1,length(xvals1b));
        xvals1 = [xvals1a xvals1b];
        ysign1 = [ysign1a ysign1b];
    end
    if z2(2) >= 0 
        xvals2 = [-dx:-dx:z2(1)+dx , z2(1)];
        ysign2 = ones(1,length(xvals2));
    else
        xvals2a = -dx:-dx:-l+dx;
        ysign2a = ones(1,length(xvals2a));
        xvals2b = [-l , -l+dx:dx:z2(1)-dx , z2(1)];
        ysign2b = -ones(1,length(xvals2b));
        xvals2 = [xvals2a xvals2b];
        ysign2 = [ysign2a ysign2b];
    end
    xvals = [xvals1 xvals2];
    ysign = [ysign1 ysign2];
    
    % construct via points
    vp = zeros(3,length(xvals));
    for k = 1:length(xvals)
        xe = xvals(k);
        ye = ysign(k) * r * sqrt( 1 - xe*xe/l/l);
        vp(:,k) = i + h + x * xe + y * ye;
    end
    
    % mtu length
    mtuLength = sum(vecnorm(diff([o vp i],1,2)));
    
    
end

end

function [f,f1,f2] = fobj(z,p,r,l)
d = z'*z - p'*z; % orthogonality condition (z orthog to z-p)
f = 1/2 * d * d; % cost
d1 = 2 * z' - p'; % partial d wrt z
f1 = d * d1; % gradient: partial f wrt z
f2 = (d1' * d1) + 2 * d * eye(2); % hessian: partial of f1 wrt z
end

function [c,ceq,c1,ceq1,ceq2] = fcon(z,p,r,l)
c = []; % no inequality constraints
c1 = []; % no inequality constraint derivs
r2 = r*r; % radius of minor axis squared
l2 = l*l; % radius of major axis squared
A = diag([1/l2,1/r2]);
ceq = z' * A * z - 1; % ellipse equation (z is point on ellipse)
ceq1 = 2 * z' * A; % constraint gradient: partial of ceq wrt z
ceq2 = 2 * A; % constraint hessian: partial of ceq1 wrt z
ceq1 = ceq1'; % transpose for matlab
end

function hess = fhess(z,lam,p,r,l)
[~,~,hess1] = fobj(z,p,r,l); % objective hessian
[~,~,~,~,hess2] =  fcon(z,p,r,l); % constraint hessian
hess = hess1 + lam.eqnonlin * hess2; % lagrangian hessian
end
