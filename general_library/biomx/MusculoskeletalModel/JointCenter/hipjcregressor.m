function [ c ] = hipjcregressor( name, pelvicDepth, pelvicWidth, legLength, side)
%
%   hip joint center regressor: implements regression equation of hara,
%   harrington, or bell depending on 'name' inputs
%
%---------------------------INPUTS-----------------------------------------
%
%   name:
%       char array specifying name of regression equation:
%           (1) bell
%           (2) harrington
%           (3) hara
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
%      axis is (left ASIS to mid PSIS) cross Z cross Z, and Y axis is Z 
%       cross X), units in meters
%
%--------------------------------------------------------------------------
%% hipjcregressor

% hara default
if ~any(strcmpi(name,{'hara','harrington','bell'})); name = 'hara'; end

% hara
if strcmpi(name,'hara'); c = hipjchara(legLength,side);
    
% harrington    
elseif strcmpi(name,'harrington'); c = hipjcharrington(pelvicDepth,pelvicWidth,legLength,side);
    
% bell
elseif strcmpi(name,'bell'); c = hipjcbell(pelvicWidth,side);
    
end

end