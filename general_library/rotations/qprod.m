function [ pq ] = qprod( p, q )
%% Reed Gurchiek, 2020
%   qprod computes the quaternion product pq = p*q.  
%
%   note that qprod(p,q) = qprodmat(p,1) * q = qprodmat(q,2) * p
%
%-----------------------------INPUTS---------------------------------------
%
%   p & q:
%       4 x n quaternion where row 4 is scalar part and rows 1 - 3 are the
%       vector part of the quaternion and n is the number of quaternions
%
%----------------------------OUTPUTS---------------------------------------
%
%   pq:
%       4 x n, product p*q
%
%--------------------------------------------------------------------------
%% qprod

% error check
[pr,pn] = size(p);
[qr,qn] = size(q);
if pr ~= 4
    error('quaternion p must be 4 element column vector (row 4 = scalar part, rows 1-3 = vector part)')
elseif qr ~= 4
    error('quaternion q must be 4 element column vector (row 4 = scalar part, rows 1-3 = vector part)')
elseif pn ~= qn
    if pn == 1
        p = repmat(p,[1 qn]);
        pn = qn;
    elseif qn == 1
        q = repmat(q,[1 pn]);
    else
        error('p and q must have same number of columns (number of quaternions)')
    end
end

% get product (scalar part = p0*q0 - <pv,qv>, vector part = p0*qv + q0*pv + pv x qv)
pq = zeros(4,pn);
for k = 1:pn
    
    %pq = p*q
    pq(:,k) = [ p(4,k) -p(3,k)  p(2,k) p(1,k);...
                p(3,k)  p(4,k) -p(1,k) p(2,k);...
               -p(2,k)  p(1,k)  p(4,k) p(3,k);...
               -p(1,k) -p(2,k) -p(3,k) p(4,k)]*q(:,k);

end