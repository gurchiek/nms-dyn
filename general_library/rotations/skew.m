function [ vx ] = skew( v )
%Reed Gurchiek, 2020
%   skew takes a 3xn matrix of column vectors and returns a 3x3xn skew
%   symmetric matrix for each column vector in V such that vx(3,3,i)*p =
%   cross(V(:,i),p).
%
%   e.g. if v = [x y z]', vx = [ 0 -z  y]
%                              [ z  0 -x]
%                              [-y  x  0]
%
%---------------------------------INPUTS-----------------------------------
%
%   v:
%       3xn array of column vectors.
%
%--------------------------------OUTPUTS-----------------------------------
%
%   vx:
%       3x3xn skew symmetric matrices.
%
%--------------------------------------------------------------------------

%% skew

%verify proper inputs
[vr,vc] = size(v);
if vc == 3 && vr ~= 3
    v = v';
elseif vr ~= 3 && vc ~= 3
    error('V must have 3 rows or 3 columns')
end

%for each vector
[~,n] = size(v);
vx = zeros(3,3,n);
for k = 1:n
    
    %get skew
    vx(:,:,k) = [   0    -v(3,k)  v(2,k);...
                  v(3,k)    0    -v(1,k);...
                 -v(2,k) v(1,k)     0   ];
             
end



end

