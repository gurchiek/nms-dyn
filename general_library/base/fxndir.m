function [ functionDirectory ] = fxndir(functionName)
%Reed Gurchiek, 2018
%   returns the directory within which contains the function 'functionName'
%
%---------------------------INPUTS-----------------------------------------
%
%   functionName:
%       string, name of function. Example) 'cross' or 'dot'
%
%--------------------------OUTPUTS-----------------------------------------
%
%   functionDirectory:
%       string, path to directory containing functionName
%
%--------------------------------------------------------------------------
%% fxndir

% get dir
functionDirectory = replace(which(functionName),strcat(filesep,functionName,'.m'),'');

end