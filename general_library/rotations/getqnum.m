function [ q ] = getqnum(a,b,w)
%Reed Gurchiek, 2020
%   getqnum computes the 4x1 quaternion that minimizes
%   
%           1/2 * (a - q*b*q_conj)' * diag(w) * (a - q*b*q_conj)
%
%   using fmincon. getq is faster; this mostly to verify both yield same
%   answer
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
%% getqnum

q = fmincon(@fun,[0 0 0 1]',[],[],[],[],[],[],@con,optimoptions('fmincon','Display','iter'),a,b,w);

end

function f = fun(q,a,b,w)
f = 0;
for k = 1:size(a,2)
    e = a(:,k) - qrot(q,b(:,k));
    f = f + 0.5 * w(k) * (e' * e);
end
end

function [c,ceq] = con(q,a,b,w)
c = [];
ceq = (q' * q) - 1;
end