function [grad] = qrotjac(q)
%Reed Gurchiek, 2020
%
%   returns the partial derivative (jacobian) of the rotation matrix (R)
%   parametrized by quaternion (q) s.t.
%
%                  v2 = q * v1 * q_conj = R * v1
%
%   q is a vector so dR/dqk is a matrix called the jacobian matrix, also
%   referred to by some as the gradient
%
%----------------------------INPUTS----------------------------------------
%
%   q:
%       4 x 1 column vector, rows 1-3 are vector part (x,y,z) and row 4 is
%       scalar part
%
%-----------------------------OUTPUTS--------------------------------------
%
%   grad:
%       3 x 3 x 4 array where grad(:,:,k) = dR/dqk
%
%--------------------------------------------------------------------------
%%  qrotjac
    
grad(:,:,1) = 2 * [ q(1)  q(2)  q(3);...
                    q(2) -q(1) -q(4);...
                    q(3)  q(4) -q(1)];
      
grad(:,:,2) = 2 * [-q(2)  q(1)  q(4);...
                    q(1)  q(2)  q(3);...
                   -q(4)  q(3) -q(2)]; 
         
grad(:,:,3) = 2 * [-q(3) -q(4)  q(1);...
                    q(4) -q(3)  q(2);...
                    q(1)  q(2)  q(3)];
          
grad(:,:,4) = 2 * [ q(4) -q(3)  q(2);...
                    q(3)  q(4) -q(1);...
                   -q(2)  q(1)  q(4)];
               
end