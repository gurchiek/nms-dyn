function [ y ] = tower( u )
%Reed Gurchiek, 2018
%   tower will stack columns of a 2-d matrix u or pages of a 3-d matrix u
%
%   for stacking columns of 2-d matrix just use y = u(:)
%
%---------------------------INPUTS-----------------------------------------
%
%   u:
%       m x n x p matrix.
%       
%
%--------------------------OUTPUTS-----------------------------------------
%
%   y:
%       stacked matrix.  if u is 2D (m x n x 1) then y will be m*n x 1.  if
%       u is 3D (m x n x p) then y will be m*p x n.
%
%--------------------------------------------------------------------------
%% tower

%size
[m,n,p] = size(u);

%2D
if p == 1
    %stack
    y = zeros(m*n,1);
    for k = 1:n
        y((k-1)*m+1:k*m,1) = u(:,k);
    end
 
%3D
else
    %stack
    y = zeros(m*p,n);
    for k = 1:p
        y((k-1)*m+1:k*m,:) = u(:,:,k);
    end
end


end