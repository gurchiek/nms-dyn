function [ options ] = opt( varargin )
%Reed Gurchiek, 2017
%
%   opt returns an n x 2 cell array which describes options for various
%   functions.
%
%----------------------------------INPUTS----------------------------------
%
%   varargin:
%       should be option type followed by option value separated by a
%       comma.  Example, opt('LPcutoff', 10, 'output','angle').  The option
%       type and value will vary depending on the function.
%
%---------------------------------OUTPUTS----------------------------------
%
%   options:
%       n x 2 cell array with option type in first column and option value
%       in second column on corresponding rows.
%
%--------------------------------------------------------------------------

%% opt

%must be even number of arguments
if mod(nargin,2)
    error('Input arguments must be even number')
end

%for each argument type
options = cell([nargin/2,2]);
for k = 1:nargin/2
    
    %arrange options
    options{k,1} = varargin{2*k-1};
    options{k,2} = varargin{2*k};
    
end


end

