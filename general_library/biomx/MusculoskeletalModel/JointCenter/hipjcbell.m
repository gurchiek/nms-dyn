function [ c ] = hipjcbell( pelvicWidth, side)
%
%   hip joint center regressor: Bell et al. 1990
%
%   demographic: 7 healthy adult males, 38-53 yo, 5'5"-6'3", 130-210 lb
%
%   original study reported estimated hip jc was 1.90 cm from true on
%   average
%
%   method was used for comparison in Leardini et al. 1999, Harrington et
%   al. 2007, and Hara et al. 2016
%
%---------------------------INPUTS-----------------------------------------
%
%   pelvicWidth:
%       distance between right and left ASIS in meters
%
%   side:
%       1 for right side, -1 for left side
%
%--------------------------OUTPUTS-----------------------------------------
%
%   jc:
%      x,y,z coordinates of the hip joint center expressed relative to the 
%      pelvis (origin at mid ASIS, Z axis is left ASIS to right ASIS, X
%      axis is (right ASIS to mid PSIS) cross Z cross Z, and Y axis is Z 
%       cross X), units in meters
%
%--------------------------------------------------------------------------
%% hipjcbell

c = [-0.19 * pelvicWidth;...
     -0.30 * pelvicWidth;...
      0.36 * pelvicWidth * side];

end