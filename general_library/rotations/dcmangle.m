function a = dcmangle(R)
% Reed Gurchiek, 2021
% extract angle of rotation from rotation matrix R
%
%----------------------------------INPUTS----------------------------------
%
%   R:
%       3 x 3 x n array of direction cosine matrices
%
%---------------------------------OUTPUTS----------------------------------
%
%   a:
%       1 x n array of angles of rotation for each dcm, in radians
%
%--------------------------------------------------------------------------
%% dcmangle

a = zeros(1,size(R,3));
for k = 1:length(a)
    [~,a(k)] = helical(R(:,:,k),[0 0 0]');
end

end