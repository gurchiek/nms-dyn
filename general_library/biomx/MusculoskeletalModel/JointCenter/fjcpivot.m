function [c1,c2] = fjcpivot(r1,r2,p1,p2)
%   
%   functional joint center estimator: pivot method, Siston and Delp 2006
%
%   estimates joint center for spheroidal joint characterized by segment 1
%   and segment 2 given data during a calibration trial where the segments
%   move relative to one another in all 3 axes where the orientations
%   througout the movement are defined by the dcms r1 and r2 for segment 1
%   and 2 respectively and given body origins p1 and p2 which are relative
%   to a global frame
%
%   compared in Dardenne et al. 2019, found to be preferred method
%
%   basically same as SCORE up to a coordinate transform
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   r2:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r2(:,:,i) * v_frame2(:,i)
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       of frame 1 in the world frame
%   p2:
%       3xn array of column vectors specifying the location of the origin
%       of frame 2 in the world frame
%
%---------------------------------OUTPUTS----------------------------------
%
%   c1,c2:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1 and frame 2 respectively
%
%--------------------------------------------------------------------------
%% fjcpivot

% body 2 position relative to body 1
v = p2 - p1;

% initialize matrix s.t. v_body1 = r21 * v_body2
r21 = r2;

% for each observation
for k = 1:size(v,2)
    
    % get transform and transform v from world to body 1
    r21(:,:,k) = r1(:,:,k)' * r2(:,:,k);
    v(:,k) = r1(:,:,k)' * v(:,k);
end

% setup/solve system
x = lsqlin([tower(repmat(eye(3),[1 1 size(v,2)])) -tower(r21)],tower(v));
c1 = x(1:3);
c2 = x(4:6);

end