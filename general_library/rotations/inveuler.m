function [einv,seq] = inveuler(e,seq)
%Reed Gurchiek, 2020
%
%   inverts euler angles (negate and reverse order)
%
%----------------------------INPUTS----------------------------------------
%
%   e:
%       3 x n array of euler angles
%
%   seq:
%       euler angle sequence:
%
%                   'xyx' 'xzx' 'xzy' 'xyz'
%                   'yzy' 'yxy' 'yzx' 'yxz'
%                   'zxz' 'zyz' 'zxy' 'zyx' 
%
%-----------------------------OUTPUTS--------------------------------------
%
%   einv, seq:
%       3 x n array of inverted euler angles and their new sequence
%
%--------------------------------------------------------------------------
%% inveuler

[einv,seq] = unpackrot(invrot(packrot(e,seq)));

end