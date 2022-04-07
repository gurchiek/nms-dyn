function [ dcm ] = orthogonalize( dcm )
% Reed Gurchiek, 2020
%   orthogonalizes direction cosines matrices s.t. dcm'*dcm = I. Uses
%   SVD-based soln to wahba's problem
%
%----------------------------INPUTS----------------------------------------
%
%   dcm:
%       3 x 3 x n array of direction cosine matrices
%
%-----------------------------OUTPUTS--------------------------------------
%
%   dcm:
%       orthogonalized 3 x 3 x n array of direction cosine matrices
%
%--------------------------------------------------------------------------
%%  orthogonalize

for k = 1:size(dcm,3)
    [U,~,V] = svd(normalize(dcm(:,:,k),1,'norm'));
    dcm(:,:,k) = U*diag([1 1 det(U)*det(V)])*V'; 
end

end