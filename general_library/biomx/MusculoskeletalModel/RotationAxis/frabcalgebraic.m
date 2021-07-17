function [a1,c1,smin,iter,relative_step] = frabcalgebraic(r1,p1,p2,m2,maxiter,tol)
%   
%   functional rotation axis estimator: Gamage and Lasenby 2002 with bias
%   compensation algorithm specified in Halvorsen 2003
%
%   estimates rotation axis for joint characterized by two bodies (body 1,
%   body 2) where body 1 has associated orientations (r1) throughtout a
%   calibration trial as well as origin locations p1,p2 in the global frame
%   and marker positions in the global frame on body 2 (m2)
%
%   is same method as fraalgebraic except with iterative bias compensation
%   algo
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
%   maxiter (optional: default = 10):
%       maximum iterations for bias compensation
%
%   tol (optional: default = 0):
%       tolerance for terminating search in bias compensation. If the
%       relative step size is ever less than tol, then optimization is
%       terminated
%
%   NOTE: iteration terminates when either relative_step <= tol or iter >
%   maxiter
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
%   smin:
%       the least singular value of the design matrix, provides some
%       insight into what extent the joint actually acts as a hinge; the 
%       closer smin is to 0, the more the joint acts as a hinge; larger 
%       smin values may suggest the joint is better represented 
%       spheroidally
%
%   iter:
%       number of iterations before termination in bias compensation
%       algorithm
%
%   relative_step:
%       relative step size for last step of iterative bias compensation
%       algorithm
%
%--------------------------------------------------------------------------
%% frabcalgebraic

% set defaults for terminating bias compensation estimation
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

% get biased estimate
[a1,c1,smin,Ainv,b,v] = fraalgebraic(r1,p1,p2,m2);
nmkr = numel(v);

% bias compensation algorithm
iter = 1;
relative_step = inf;
while iter <= maxiter && relative_step > tol

    % initialize sum of wbar (eq 30 in Halvorsen 03)
    sum_wbar = [0 0 0]';

    % intialize variance in (eq 37 Halvorsen 03)
    % need average, average computed iteratively
    sigma2 = 0;

    % for each marker
    for m = 1:nmkr

        % get marker positions (in frame 1) relative to estimated center
        w = v{m} - c1;
        n = size(w,2);

        % increment average variance (eq 37 halvorsen 03)
        wbar = mean(w,2);
        w2 = dot(w,w)';
        w2bar = mean(w2);
        sigma2 = sigma2 + 1/4/w2bar/n * (w2-w2bar)'*(w2-w2bar) / nmkr;

        % increment wbar sum (eq 38 halvorsen 03)
        sum_wbar = sum_wbar + wbar;
    end

    % eq 38 halvorsen 03
    delta_b = 2 * sigma2 * sum_wbar;

    % eq 40 halvorsen 03
    c1new = Ainv * (b - delta_b);

    % get step measure for convergence criterion
    delta_c1 = c1 - c1new;
    relative_step = vecnorm(delta_c1) / vecnorm(c1);

    % update
    c1 = c1new;
    iter = iter + 1;

end
iter = iter-1;

% get p2 in frame 1
p2 = dcmrot(r1,p2 - p1,'inverse');

% get point on both joint axis and radius of p2 in frame 1
p2bar = mean(p2,2);
c1 = c1 + a1' * (p2bar - c1) * a1;

end