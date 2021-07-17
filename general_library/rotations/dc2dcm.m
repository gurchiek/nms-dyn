function [ dcm ] = dc2dcm(dc)
%Reed Gurchiek, 2020
%   convert 9 x n array of direction cosines to dcm s.t.:
%
%               dcm(:,:,k) = [dc(1:3,k) dc(4:6,k) dc(7:9,k)]
%
%----------------------------------INPUTS----------------------------------
%
%   dc:
%       9 x n array of direction cosines
%
%---------------------------------OUTPUTS----------------------------------
%
%   dcm:
%       3 x 3 x n array of dcms
%
%--------------------------------------------------------------------------
%% dc2dcm

[nrow,ncol] = size(dc);
if nrow ~= 9; error('input dc must be a 9 x n array of direction cosines.'); end
dcm = zeros(3,3,ncol);
for k = 1:ncol; dcm(:,:,k) = [dc(1:3,k) dc(4:6,k) dc(7:9,k)]; end

end