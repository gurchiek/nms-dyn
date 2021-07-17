function [a1,c1] = frageometric(r1,p1,p2,m2,a0,c0)
%   
%   functional rotation axis estimator: geometric method, Shakarji 1998,
%   section 3.5 (3D circle fitting)
%
%   estimates rotation axis for joint characterized by two bodies (body 1,
%   body 2) with associated orientations of body 1, r1, during calibration
%   movement as well as body 1 and 2 origins (p1,p2), marker positions in
%   body 2, all measured globally. 
%
%   requires starting guess: a0 for axis, c0 for center
%
%   method uses fact that all points in body 2 should be a constant radial
%   distance from joint axis and a particular point on the axis. This
%   approach minimizes this cost, involves sqrt, no closed form, uses
%   levenberg-marquardt and analytical jacobian to find solution
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       in the world frame
%
%   p2:
%       3xn array of column vectors specifying a point in body 2 expressed
%       in the world frame. the joint center argument (c1 in body 1) is the
%       point on the joint axis (a1 in body 1) such that:
%           (p2_frame1 - c1) is orthogonal to a1
%
%   m2:
%       3x3xn array of column vectors of marker positions. Each page is for
%       a different marker. Marker positions should be for markers placed
%       on rigid body 2 but expressed in the world frame
%
%   a0:
%       3x1 vector, first estimate of joint axis in frame 1, only needs to
%       point in correct half of joint plane
%
%   c0:
%       3x1 vector, first estimate of position of joint center relative to
%       frame 1
%
%---------------------------------OUTPUTS----------------------------------
%
%   a1:
%       3x1 unit vector specifying the joint axis in frame 1
%
%   c1:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1
%
%--------------------------------------------------------------------------
%% frageometric

% globalize vars for objective function
global v
global imkr
global nmkr

% normalize a0
a0 = a0/vecnorm(a0);

% get markers positions on body 2 relative to body 1
nframes = size(p1,2); % num frames
nmkr = size(m2,3); % num markers
x0 = zeros(1,2*nmkr); % obj fxn args, 2/marker: (1) radius length from joint axis, (2) distance of center of circle from joint center
v = zeros(3,nmkr*nframes); % observations
imkr = zeros(1,nmkr*nframes); % marker index associated with each observation
i = 1;
while i <= size(v,2)
    
    % for each marker
    for m = 1:nmkr
        
        % r and d are the obj fxn args per marker
        % r is var (1) and d is var (2) in x0 comment (line 92)
        % initialize in this loop as average based on initial a0,c0
        r = zeros(1,nframes);
        d = zeros(1,nframes);
        
        % for each frame
        for f = 1:nframes
            
            if any(isnan(m2(:,f,m))) || any(isnan(p1(:,f)))
            
                % remove NaNs (from marker occlusion)
                v(:,i) = [];
                r(f) = [];
                d(f) = [];
                imkr(i) = [];
            else
                
                % marker m, frame f, relative to body 1
                v(:,i) = r1(:,:,f)' * ( m2(:,f,m) - p1(:,f) );
                w = v(:,i) - c0; % joint center to point
                d(f) = w' * a0; % var (2) line 92
                r(f) = sqrt(w'*w - d(f)*d(f)); % var (1) line 92
                imkr(i) = m;
                i = i + 1;
            end
        end
        x0(m) = mean(r);
        x0(nmkr + m) = mean(d);
    end
end

% augment x0 with initial c0 and a0 (also obj fxn args)
x0 = [x0 c0' a0'];

% LM
options = optimoptions('lsqnonlin','SpecifyObjectiveGradient',true,'Algorithm','levenberg-marquardt','Display','off');
x = lsqnonlin(@objfun,x0,[],[],options);

% parse
a1 = x(end-2:end)'; a1 = a1/vecnorm(a1);
c1 = x(end-5:end-3)';

% get p2 in frame 1
p2 = dcmrot(r1,p2 - p1,'inverse');

% get point on both joint axis and radius of p2 in frame 1
p2bar = mean(p2,2);
c1 = c1 + a1' * (p2bar - c1) * a1;

end

function [err,jac] = objfun(x)

global v
global imkr
global nmkr

% initialize error vector and jacobian
err = zeros(length(imkr),1);
jac = zeros(length(imkr),length(x));

% parse args
r = x(1:nmkr);
d = x(nmkr+1 : end-6);
c = x(end-5 : end-3)';
a = x(end-2:end)';
a = a/vecnorm(a);

% for each observations
for i = 1:length(imkr)
    
    % get d/r for this observation (vars (2) and (1) line 92)
    di = d(imkr(i));
    ri = r(imkr(i));
    
    % vector, joint center to marker
    w = v(:,i) - c;
    
    % sub-objective g(), orthogonality
    g = w' * a - di;
    
    % radial vector and magnitude (marker centered on own circle)
    rvec = w - di*a;
    rhat = sqrt(w'*w - di*di);
    
    % sub-objective f(), radius is constant
    f = rhat - ri;
    
    % error is norm of both sub-objectives
    mag = sqrt(g*g + f*f);
    err(i) = mag;
    
    % partials
    jac(i,imkr(i)) = -f/mag;
    jac(i,nmkr + imkr(i)) = -1/mag * (g + f/rhat * rvec' * a);
    jac(i,end-5) = -1/mag * (g * a(1) + f * rvec(1)/rhat);
    jac(i,end-4) = -1/mag * (g * a(2) + f * rvec(2)/rhat);
    jac(i,end-3) = -1/mag * (g * a(3) + f * rvec(3)/rhat);
    jac(i,end-2) = 1/mag * (g * w(1) - f * di/rhat * rvec(1));
    jac(i,end-1) = 1/mag * (g * w(2) - f * di/rhat * rvec(2));
    jac(i,end) = 1/mag * (g * w(3) - f * di/rhat * rvec(3));
end

end