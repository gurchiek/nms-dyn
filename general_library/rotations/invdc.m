function [dcinv] = invdc(dc)
%Reed Gurchiek, 2020
%
%   inverts direction cosines vector s.t.,
%
%                       dc2dcm(dc)' * v
%
%   is equivalent to,
%
%                      dc2dcm(invdc(dc)) * v
%
%----------------------------INPUTS----------------------------------------
%
%   dc:
%       9 x n array of direction cosines, dc(1:3) corresponds to column 1
%       of the corresponding dcm, dc(4:6) corresponds to column 2 of the
%       corresponding dcm, and dc(7:9) corresponds to column 3 of the
%       corresponding dcm
%
%-----------------------------OUTPUTS--------------------------------------
%
%   dcinv:
%       9 x n array of direction cosines s.t. dc2dcm(dc)' = dc2dcm(dcinv)
%
%--------------------------------------------------------------------------
%% invdc

dcinv = [dc(1,:);...
         dc(4,:);...
         dc(7,:);...
         dc(2,:);...
         dc(5,:);...
         dc(8,:);...
         dc(3,:);...
         dc(6,:);...
         dc(9,:)];
     
end