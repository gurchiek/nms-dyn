function [ A ] = dcstatemat(w,b2w,inbody)
%Reed Gurchiek, 2020
%   returns state matrix A s.t. dc_dot = A * dc where A is a function of w (angular rate) 
%
%----------------------------------INPUTS----------------------------------
%
%   w:
%       3 x n array of angular rates in radians/second
%
%   b2w:
%       if 1, then, v_world = dc2dcm(dc) * v_body
%       if 0, then, v_body = dc2dcm(dc) * v_world
%
%   inbody:
%       if 1, then, w is expressed in body frame
%       if 0, then, w is expressed in world frame
%
%---------------------------------OUTPUTS----------------------------------
%
%   A:
%       9 x 9 x n matrix s.t. dc_dot = A * dc
%
%--------------------------------------------------------------------------
%% dcstatemat

% initialize
Z3 = zeros(3);
I3 = eye(3);
n = size(w,2);
A = zeros(9,9,n);

% if v_world = R * v_body and omega expressed wrt body axes
if b2w && inbody
    
    for k = 1:n
        A(:,:,k) = [    Z3       w(3,k)*I3  -w(2,k)*I3;...
                    -w(3,k)*I3      Z3       w(1,k)*I3;...
                     w(2,k)*I3  -w(1,k)*I3      Z3    ];
    end
    
% if v_world = R * v_body and omega expressed wrt world axes    
elseif b2w && ~inbody
    
    for k = 1:n
        skw = skew(w(:,k));
        A(:,:,k) = [skw   Z3   Z3;...
                    Z3   skw   Z3;...
                    Z3    Z3  skw];
    end
    
% if v_body = R * v_world and omega expressed wrt body axes    
elseif ~b2w && inbody
    
    for k = 1:n
        skw = skew(w(:,k));
        A(:,:,k) = [-skw   Z3   Z3;...
                     Z3   -skw  Z3;...
                     Z3    Z3  -skw];
    end
    
% if v_body = R * v_world and omega expressed wrt world axes     
elseif ~b2w && ~inbody
    
    for k = 1:n
        A(:,:,k) = [    Z3      -w(3,k)*I3   w(2,k)*I3;...
                     w(3,k)*I3      Z3      -w(1,k)*I3;...
                    -w(2,k)*I3   w(1,k)*I3      Z3    ];
    end
    
end

end