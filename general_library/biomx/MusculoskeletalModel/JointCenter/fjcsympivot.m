function [cPR,cR,cL] = fjcsympivot(RP,RR,RL,pP,pR,pL)
%   
%   same as fjcpivot except determines location of right/left joint
%   center in parent frame simultaneously assuming symmetricity. For
%   example, to determine hip joint center assuming symmetricity then RP
%   would be pelvis orientation throughout movement and RR/RL would be the
%   right and left thigh orientation throughout movement
%
%----------------------------------INPUTS----------------------------------
%
%   RP, RR, RL:
%       3x3xn array of rotation matrices for the parent, right segment, and
%       left segment respectively such that: 
%               v_world(:,i) = R(:,:,i) * v_body(:,i)
%   pP, pR, pL:
%       3xn array of column vectors specifying the location of the origin
%       of the parent, right segment, and left segment respectively in the
%       world frame
%
%---------------------------------OUTPUTS----------------------------------
%
%   cPR,cR,cL:
%       3x1 position vector indicating the location of the right joint
%       center in the parent frame, the right joint center in the right
%       segment frame and the left joint center in the left segnebt frame
%       respectively
%
%--------------------------------------------------------------------------
%% fjcsympivot

% body 2 position relative to body 1
v = tower([pR - pP; pL - pP]);

% initialize matrix s.t. v_body1 = r21 * v_body2
A = zeros(6, 9, size(RP,3));

% for each observation
Z = zeros(3,3);
L = diag([1 1 -1]);
for k = 1:size(RP,3)
    
    % get transfer matrix
    A(:,:,k) = [RP(:,:,k)  , -RR(:,:,k),      Z     ;...
                RP(:,:,k)*L,      Z    , -RL(:,:,k)];
    
end
A = tower(A);

% solve
x = A \ v;
cPR = x(1:3);
cR = x(4:6);
cL = x(7:9);

end