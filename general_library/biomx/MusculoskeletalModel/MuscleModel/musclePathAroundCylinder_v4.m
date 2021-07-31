function [mtuLength,vp] = musclePathAroundCylinder_v4(origin,insertion,axis,position,radius)

% approimates mtu length using a single via point
% more accurate approach is to use musclePathAroundCylinder_v3 which finds
% exactly where the MTU meets the cylinder from both origin and insertion,
% but it takes very long. The current approaches models the path using a
% single VP that hits the cylinder at the tip of the minor axis of the
% elliptical cross section

% this method deviates the most from _v3 when gastrocs wrap most around
% femoral condyle (e.g., extended knee, dorsiflexed ankle). In my own
% experiments, max deviation is less than 0.5 mm so not much difference,
% but big savings in terms of computation time (especially for moment arm
% which requires 4 evaluations of this fxn for 5 point approximation...)

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

% get point on axis closest to line insertion to origin (h)
tau = ( (vhat'*n) * c - n' * a ) / (1 - c * c);
h = n + tau * a; % vector from insertion to point on cylinder axis closes to line: insertion to origin (v)

% get semi minor/major axes of ellipse that muscle path lies in
% for general cylinder cross-section the radius of the cylinder will not
% always be the length of the minor axis but since this cross section is
% for the MTU path wrapping around the cylinder in the SHORTEST distant,
% then it is
r = radius;

% muscle path plane
y = normalize(cross(a,vhat),1,'norm'); % ellipse frame y axis
oy = (v-h)'*y; % y coordinate of origin in ellipse frame

% if y components larger than radius then doesnt touch
if oy >= r
    
    vp = [];
    mtuLength = vecnorm(v);

% otherwise continue
else
    
    % mtu length
    vp = i + h + y * r;
    mtuLength = sum(vecnorm(diff([o vp i],1,2)));
    
    
end

end
