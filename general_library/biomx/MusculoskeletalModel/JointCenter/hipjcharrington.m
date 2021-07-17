function [ c ] = hipjcharrington( pelvicDepth, pelvicWidth, legLength, side)
%
%   hip joint center regressor: Harrington et al. 2007
%
%   demographic: 
%       -8 adults (3 F, aged 22.9-40.1 yo, mass: 54-81 kg)
%       -14 healthy children (7 F, aged 5.9-13 yo, mass: 15.5-47 kg)
%       -10 children with spastic diplegic cerebral palsy (5 F, aged
%           6.1-12.5 yo, mass: 20-40 kg)
%
%   error (loocv): 5.24 mm in x, 3.58 mm in y, 3.22 mm in z
%
%---------------------------INPUTS-----------------------------------------
%
%   pelvicDepth:
%       distance between ASIS midpoint and PSIS midpoint in meters
%
%   pelvicWidth:
%       distance between right and left ASIS in meters
%
%   legLength:
%       distance between ASIS and medial malleolus in meters
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
%% hipjcharrington

%x: anterior/posterior
x = -0.0099 - 0.24 * pelvicDepth;

%y: inferior/superior
y = -0.0071 - 0.16 * pelvicWidth - 0.04 * legLength;

%z: medial-lateral
z = 0.0079 + 0.28 * pelvicDepth + 0.16 * pelvicWidth;

c = [x y side*z]';

end