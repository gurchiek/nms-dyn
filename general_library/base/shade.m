function [ ] = shade(x,ub,lb,color,alpha)
%Reed Gurchiek, 2019
%   plots ubber bound ub and lower bound lb and shades area between
%
%----------------------------------INPUTS----------------------------------
%
%   x:
%       1 x n, x-axis values corresponding to each element in ub/lb
%
%   ub:
%       1 x n, ubber bound
%
%   lb:
%       1 x n, lower bound
%
%   color/alpha:
%       plot() 'Values' for 'color' and 'alpha' properties
%
%--------------------------------------------------------------------------
%% shade

a = [lb fliplr(ub)];
b = [x fliplr(x)];
shade = fill(b,a,color);
hold on
shade.FaceAlpha = alpha;
shade.EdgeColor = shade.FaceColor;
shade.EdgeAlpha = alpha;

end