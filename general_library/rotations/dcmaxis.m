function n = dcmaxis(R)
% Reed Gurchiek, 2021
% extract axis of rotation from rotation matrix R
%
%----------------------------------INPUTS----------------------------------
%
%   R:
%       3 x 3 x n array of direction cosine matrices
%
%---------------------------------OUTPUTS----------------------------------
%
%   n:
%       3 x n array of axes of rotation for each dcm, each is unit length
%
%--------------------------------------------------------------------------
%% dcmaxis

n = zeros(3,size(R,3));
for k = 1:size(R,3)
    n(:,k) = helical(R(:,:,k),[0 0 0]');
end

end