function [ c ] = hipjchara( legLength, side)
%
%   hip joint center regressor: Hara et al. 2016
%
%   demographic: 180 subjects (60 aged 5 - 11, 30 male; 60 aged 16-19, 30
%   male; 60 aged 25-40, 30 male)
%
%   error (loocv): 5.2 mm in x, 4.4 mm in y, 3.8 mm in z
%
%---------------------------INPUTS-----------------------------------------
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
%% hipjchara

%x: anterior/posterior
x = 0.011 - 0.063 * legLength;

%y: inferior/superior
y = -0.009 - 0.078 * legLength;

%z: medial-lateral
z = 0.008 + 0.086 * legLength;

c = [x y side*z]';

end