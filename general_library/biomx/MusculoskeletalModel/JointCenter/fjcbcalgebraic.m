function [c1,iter,relative_step] = fjcbcalgebraic(r1,p1,m2,maxiter,tol)
%   
%   functional joint center estimator: bias compensated algebraic method, 
%   Halvorsen 2003
%
%   estimates joint center for spheroidal joint characterized by segment 1
%   and segment 2 given data during a calibration trial where the segments
%   move relative to one another in all 3 axes where the orientation of
%   body 1 througout the movement are defined by the dcm r1 and given body 
%   origins p1 for body 1 and measured points on body 2, m2, all measured
%   in global frame
%
%   is same method as fraalgebraic except with iterative bias compensation
%   algo, algo termination controlled by maxiter and tol
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
%   c1:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1 and frame 2 respectively
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
%% fjcbcalgebraic

% set defaults for terminating bias compensation estimation
if nargin == 3
    maxiter = 10;
    tol = 0.0;
elseif nargin == 4
    if maxiter < inf
        tol = 0.0;
    else
        tol = 1e-4;
    end
end

% get biased estimate
[c1,A,b,v] = fjcalgebraic(r1,p1,m2);
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
    c1new = A \ (b - delta_b);

    % get step measure for convergence criterion
    delta_c1 = c1 - c1new;
    relative_step = vecnorm(delta_c1) / vecnorm(c1);

    % update
    c1 = c1new;
    iter = iter + 1;

end
iter = iter-1;
end