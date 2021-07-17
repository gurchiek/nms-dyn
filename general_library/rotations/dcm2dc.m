function [ dc ] = dcm2dc(dcm)
%Reed Gurchiek, 2020
%   convert 3 x 3 x n array of direction cosines matrices to 9 x n
%   direction cosines s.t.:
%
%               dcm(:,:,k) = [dc(1:3,k) dc(4:6,k) dc(7:9,k)]
%
%----------------------------------INPUTS----------------------------------
%
%   dcm:
%       3 x 3 x n array of dcms
%       9 x n array of direction cosines
%
%---------------------------------OUTPUTS----------------------------------
%
%   dc:
%       9 x n array of direction cosines
%
%--------------------------------------------------------------------------
%% dcm2dc

[nrow,ncol,npag] = size(dcm);
if nrow ~= 3 || ncol ~= 3; error('input dcm must be a 3 x 3 x n array of direction cosine matrices.'); end
dc = zeros(9,npag);
for k = 1:npag; dc(:,k) = [dcm(:,1,k); dcm(:,2,k); dcm(:,3,k)]; end

end