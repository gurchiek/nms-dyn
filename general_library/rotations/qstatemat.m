function [ A ] = qstatemat(w,b2w,inbody)
%Reed Gurchiek, 2020
%   returns state matrix A s.t. q_dot = A * q where A is a function of w 
%   (angular rate) 
%
%----------------------------------INPUTS----------------------------------
%
%   w:
%       3 x n array of angular rates in radians/second
%
%   b2w:
%       if 1, then, v_world = q * v_body * qconj
%       if 0, then, v_body = q * v_world * qconj
%
%   inbody:
%       if 1, then, w is expressed in body frame
%       if 0, then, w is expressed in world frame
%
%---------------------------------OUTPUTS----------------------------------
%
%   A:
%       4 x 4 x n matrix s.t. q_dot = A * q
%
%--------------------------------------------------------------------------
%% qstatemat

% order for matrix multiplication
if b2w && inbody
    order = 2;
elseif b2w && ~inbody
    order = 1;
elseif ~b2w && inbody
    order = 1;
elseif ~b2w && ~inbody
    order = 2;
end

% negate if world to body
if ~b2w; w = -w; end

% get state matrix
A = qprodmat(1/2 * purify(w),order);

end