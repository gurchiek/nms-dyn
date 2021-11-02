function [crw,clw,crR,clL,crA,clB] = fjcrefpivotsymy(RR,RL,RA,RB,PR,PL,PA,PB,RR0,RL0,RA0,RB0,PR0,PL0,PA0,PB0)
%   
%   same as fjcrefpivot except assumes the y coordinate is the same in both
%   the left and right sides
%
%----------------------------------INPUTS----------------------------------
%
%   RR,RL,RA,RB:
%       3x3xn rotation matrix for right/left parent and right/left child
%       respectively
%
%   PR,PL,PA,PB:
%       3xn position of right/left parent and right/left child
%
%   RR0,RL0,RA0,RB0:
%       same as RR,RL,RA,RB except in the reference configuration (3x3x1)
%
%   PR0,PL0,PA0,PB0:
%       same as PR,PL,PA,PB except in the reference configuration (3x1)
%
%---------------------------------OUTPUTS----------------------------------
%
%   crw,clw,crR,clL:
%       joint center location for right (r) and left (l) sides expressed in
%       the world frame (w) or parent frame (R/L)
%
%--------------------------------------------------------------------------
%% fjcrefpivotsymy

% v = A * x
v = tower([PR - PA + dcmrot(RA,RA0' * PA0) - dcmrot(RR,RR0' * PR0);...
           PL - PB + dcmrot(RB,RB0' * PB0) - dcmrot(RL,RL0' * PL0)]);

% for each observation
A = zeros(6,5,size(RR,3));
Z = [0 0 0]';
for k = 1:size(RR,3)
    
    % design matrix
    M = RA(:,:,k) * RA0' - RR(:,:,k) * RR0';
    N = RB(:,:,k) * RB0' - RL(:,:,k) * RL0';
    A(:,:,k) = [M(:,1) M(:,3)   Z      Z    M(:,2);...
                  Z      Z    N(:,1) N(:,3) N(:,2)];

end
A = tower(A);

% solve
x = A \ v;
crw = [x(1); x(5); x(2)];
clw = [x(3); x(5); x(4)];
crR = RR0' * (crw - PR0);
clL = RL0' * (clw - PL0);
crA = RA0' * (crw - PA0);
clB = RB0' * (clw - PB0);

end