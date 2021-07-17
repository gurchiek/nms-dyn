function [dcm,v] = rbd1980(ref_markers_body,relative_markers_world)
%
%   computes dcm describing a rigid body rotation s.t. 
%              v_world = dcm * v_body
%   as in Spoor and Veldpaus 1980 and the translational displacement v
%
%   rbd1980: rigid body displacement from 1980 paper
%
%--------------------------------INPUTS------------------------------------
%
%   ref_markers_body:
%       3xm set of 3D position (column vector) of m markers (m columns) in
%       body frame in reference configuration
%
%   relative_markers_world:
%       3xm set of 3D positions (column vectors) of same m markers in
%       ref_markers_body except that these are measured in the world frame
%       and relative to the body frame origin in reference configuration.
%       that is, the column vector i describes the vector that points from
%       the origin of the body frame during the reference configuration to
%       marker i in the displaced configuration and this vector is
%       expressed relative to the world frame basis
%
%--------------------------------OUTPUTS-----------------------------------
%
%   dcm, v:
%       optimal dcm that minimizes
%           dcm * ref_markers_body + v - relative_markers_world
%       in the least squares sense where v is the location of the rigid
%       body origin in the world frame during the displaced configuration. 
%
%--------------------------------------------------------------------------
%% rdb1980

% init
a = ref_markers_body;
p = relative_markers_world;
n = size(a,2);

% eq 4
abar = mean(a,2);
pbar = mean(p,2);

% eq 5
M = 1/n * p * a' - pbar * abar';

% eq 14, eq 16
[~,D,V] = svd(M);
D = diag(D);

% eq 23
m = M*V;

% eq 24 (also ref eq 16 - solve for R)
m(:,3) = cross(m(:,1),m(:,2));
D(3) = D(1) * D(2);
Dinv = diag(1./D);
dcm = m * Dinv * V';

% translational displacement, eq 10
v = pbar - dcm * abar;

end