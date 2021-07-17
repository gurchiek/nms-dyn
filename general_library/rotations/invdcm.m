function [dcminv] = invdcm(dcm)
%Reed Gurchiek, 2020
%
%   inverts direction cosines matrices (transposes)
%
%----------------------------INPUTS----------------------------------------
%
%   dcm:
%       3 x 3 x n array of dcms
%
%-----------------------------OUTPUTS--------------------------------------
%
%   dcminv:
%       3 x 3 x n array of inverted dcms s.t. dcminv(:,:,k) = dcm(:,:,k)'
%
%--------------------------------------------------------------------------
%% invdcm

dcminv = unpackrot(invrot(packrot(dcm,'dcm')));

end