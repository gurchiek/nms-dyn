function [ q ] = getq(a,b,w)
%Reed Gurchiek, 2020
%   getq computes the 4x1 quaternion that minimizes
%   
%           1/2 * (a - q*b*q_conj)' * diag(w) * (a - q*b*q_conj)
%
%   getq simply calls getrot with argtype = 'q' and unpacks
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
%   q:
%       4x1 quaternion, rows 1-3 are vector part and row 4 is scalar part
%
%--------------------------------------------------------------------------
%% getq
if nargin == 3; q = unpackrot(getrot(a,b,'q',w));
else; q = unpackrot(getrot(a,b,'q'));
end
end