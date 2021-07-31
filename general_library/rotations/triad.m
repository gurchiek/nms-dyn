function [ r ] = triad(a,b)
%Reed Gurchiek, 2020
%   getdcm computes the 3x3 direction cosine matrix r using the triad
%   algorithm using the reference vectors a and measured vectors b s.t.
%
%                           a = R * b
%
%   algorithm from Shuster and Oh 1981
%
%----------------------------------INPUTS----------------------------------
%
%   a, b:
%       3 x 2 array of column vectors expressed in frame A and 3 x 2 array 
%       of column vectors expressed in frame B respectively. Each column in
%       a should correspond to the same vector in the same column of b and
%       the number of columns in each must be 2. The vector in column 1 of
%       b should be the one with greater trust (less measurement
%       uncertainty)
%
%---------------------------------OUTPUTS----------------------------------
%
%   r:
%       3x3 rotation matrix
%
%--------------------------------------------------------------------------
%% triad

% reference attitude
v1 = normalize(a(:,1),1,'norm');
v2 = normalize(cross(a(:,1),a(:,2)),1,'norm');
v3 = normalize(cross(v1,v2),1,'norm');
Mref = [v1 v2 v3];

% observation attitude
w1 = normalize(b(:,1),1,'norm');
w2 = normalize(cross(b(:,1),b(:,2)),1,'norm');
w3 = normalize(cross(w1,w2),1,'norm');
Mobs = [w1 w2 w3];

% dcm
r = Mref * Mobs';

end