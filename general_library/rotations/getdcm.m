function [ r ] = getdcm(a,b,w)
%Reed Gurchiek, 2020
%   getdcm computes the 3x3 direction cosine matrix r that minimizes
%   
%           1/2 * (a - r*b)' * diag(w) * (a - r*b)
%
%   getdcm simply calls getrot with argtype = 'dcm' and unpacks
%
%----------------------------------INPUTS----------------------------------
%
%   a, b:
%       3 x n array of column vectors expressed in frame A and 3 x n array 
%       of column vectors expressed in frame B respectively. Each column in
%       a should correspond to the same vector in the same column of b.
%
%   w (optional):
%       weights corresponding to trust given to each observation vector
%
%---------------------------------OUTPUTS----------------------------------
%
%   r:
%       3x3 rotation matrix
%
%--------------------------------------------------------------------------
%% getdcm
if nargin == 3; r = unpackrot(getrot(a,b,'dcm',w));
else; r = unpackrot(getrot(a,b,'dcm'));
end
end