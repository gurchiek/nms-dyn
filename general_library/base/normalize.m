function [ v ] = normalize( v )
%Reed Gurchiek, 2017
%   normalize normalizes column vectors in v.
%
%   most of my stuff uses normc, didnt realize this is a part of matlabs
%   deep learning toolbox (not the base package)??? If dont have this
%   toolbox, just change this function name to normc and everything should
%   run same
%
%----------------------------------INPUTS----------------------------------
%
%   v:
%       mxn matrix of column column vectors
%
%---------------------------------OUTPUTS----------------------------------
%
%   v:
%       matrix of vectors (input v) of unit length
%
%--------------------------------------------------------------------------

%% normalize

v = v./vecnorm(v,2,1);
    
end