function [ tline ] = trendline(varargin)
%Reed Gurchiek, 2019
%   fits a trendline to the data in the current figure.  If more than one
%   series is plotted, a line is fit to the most recent one
%
%----------------------------------INPUTS----------------------------------
%
%   varargin:
%       matlab 'Name,Value' pair arguments for plot() to customize line
%
%----------------------------------OUTPUTS---------------------------------
%
%   tline:
%       trendline object handle
%
%--------------------------------------------------------------------------
%% trendline

% axes handle
f = gca;

% get x,y data for most recent series
x = f.Children(1).XData;
y = f.Children(1).YData;

% fit
p = polyfit(x,y,1);

% add line
hold on
tline = plot([min(x) max(x)],polyval(p,[min(x) max(x)]),varargin{:});
end