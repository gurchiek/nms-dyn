function [c,c1,c2] = fjcrefpivot(r1,r2,p1,p2,r01,r02,p01,p02)
%   
%   same as fjcpivot except determines joint center represented in world
%   frame from a reference configuration
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
%   r01,r02:
%       3x3 rotation matrix for body 1 and 2 in reference configuration
%
%   p01,p02:
%       3x1 position of origin of body 1 and 2 in reference configuration
%
%---------------------------------OUTPUTS----------------------------------
%
%   c:
%       3x1 position vector indicating the location of the joint center
%       in the world frame in reference configuration
%
%   c1,c2:
%       c but expressed relative to frame 1/2 origin and with respect to
%       frame 1/2 bases
%
%--------------------------------------------------------------------------
%% fjcpivot

% body 2 position relative to body 1
v = tower(p1 - p2 + dcmrot(r2,r02' * p02) - dcmrot(r1,r01' * p01));

% for each observation
A = zeros(3,3,size(r1,3));
for k = 1:size(r1,3)
    
    % get transform and transform v from world to body 1
    A(:,:,k) = r2(:,:,k) * r02' - r1(:,:,k) * r01';

end
A = tower(A);

% solve
c = A \ v;
c1 = r01' * (c - p01);
c2 = r02' * (c - p02);

end