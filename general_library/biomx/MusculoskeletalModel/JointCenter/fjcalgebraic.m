function [c1,A,b,v] = fjcalgebraic(r1,p1,m2)
%   
%   functional joint center estimator: algebraic method, Gamage and Lasenby
%   2002
%
%   estimates joint center for spheroidal joint characterized by segment 1
%   and segment 2 given data during a calibration trial where the segments
%   move relative to one another in all 3 axes where the orientations of
%   body 1 througout the movement are defined by the dcm r1 and given body 
%   origins p1 for body 1 and measured points on body 2, m2, all measured
%   in global frame
%
%   can show this method is biased (Halvorsen 2003), bias compensated algo
%   is in fjcbcalgebraic
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
%---------------------------------OUTPUTS----------------------------------
%
%   c1:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1 and frame 2 respectively
%
%--------------------------------------------------------------------------
%% fjcalgebraic

% init, b and A in eq 5 determined iteratively
nmkr = size(m2,3);
b = [0; 0; 0];
A = zeros(3);
v = cell(1,nmkr);

% for each marker
for m = 1:nmkr

    % get marker m in frame 2 relative to frame 1
    v{m} = dcmrot(r1,m2(:,:,m) - p1,'inverse');

    % remove NaNs
    v{m}(:,any(isnan(v{m}))) = [];

    % vectors to update design matrix
    n = size(v{m},2);
    vbar = mean(v{m},2);
    v2 = dot(v{m},v{m});
    v2bar = mean(v2);
    v3bar = 1/n * v{m} * v2';

    % increment sums
    b = b + v3bar - vbar * v2bar;
    A = A + 1/n * (v{m} * v{m}') - (vbar * vbar');
end
A = 2*A;

% solve system
c1 = A\b;

end