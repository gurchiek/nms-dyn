function [ J ] = eulerjac(e,seq,b2w,inbody,inv)
%Reed Gurchiek, 2020
%   get 3 x 3 jacobian that maps euler angle time derivative to body frame
%   angular rate or vice versa.
%
%   note that if euler angle time derivates are mapped to the cartesian
%   angular rate in the world frame, then the columns of J are the axes
%   corresponding to the respective euler angle rotations (ie, column 1 is
%   rotation axis for seq(1), column 2 for seq(2), etc). Joint torques
%   would be projected onto these axes to return generalized torques
%   associated with the euler angles.
%
%----------------------------------INPUTS----------------------------------
%
%   e:
%       3 x n euler angles in radians
%
%   seq:
%       sequence of rotations associated with euler angles (see rot)
%
%   b2w:
%       if 1, then, v_world = eulerot(e,seq,v_body)
%       if 0, then, v_body = eulerot(e,seq,v_world)
%
%   inbody:
%       if 1, then, w is expressed in body frame: w_body = J * edot
%       if 0, then, w is expressed in world frame: w_world = J * edot
%
%   inv:
%       if 1, then returns inverse of J (maps ang rate back to edot) s.t.
%                           edot = J * w
%       if 0, then returns J (maps qdot to ang rate) s.t.
%                           w = J * edot
%
%---------------------------------OUTPUTS----------------------------------
%
%   J:
%       3 x 3 x n jacobian matrix
%
%--------------------------------------------------------------------------
%% eulerjac

% error check
[nrow,ncol] = size(e);
if nrow ~= 3; error('input e must be 3 x n array of column vector euler angles (row i = angle for rotation i)).'); end

% get rotation axes and submatrices used in euler formula: R(n,a) = I - s(a)*[nx] + (1-c(a))*[nx]^2
a = zeros(3,3);
skew1 = zeros(3,3,3);
skew2 = zeros(3,3,3);
for k = 1:3

    % column k of a is axis of rotation for the kth rotation
    a(regexp('xyz',seq(k)),k) = 1;

    % get skew symmetric matrix [nx]
    skew1(:,:,k) = [   0    -a(3,k)  a(2,k);...
                     a(3,k)    0    -a(1,k);...
                    -a(2,k)  a(1,k)    0   ];

    % get skew symmetric matrix squared [nx]^2
    skew2(:,:,k) = skew1(:,:,k)*skew1(:,:,k);

end

% symmetric or not
symm = 0;
if seq(1) == seq(3); symm = 1; end

% if body to world: v_world = R3 * R2 * R1 * v_body
if b2w
    
    % if ang rate in body frame
    if inbody
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_body = J * edot
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R1 = (eye(3) - sin(e(1,k))*skew1(:,:,1) + (1 - cos(e(1,k)))*skew2(:,:,1));
                R2 = (eye(3) - sin(e(2,k))*skew1(:,:,2) + (1 - cos(e(2,k)))*skew2(:,:,2));
                J(:,:,k) = -R1' * [a(:,1) a(:,2) R2'*a(:,3)];
            end
            
        % if return jacobian inverse
        else
            
            % get some cross products that are needed
            x12 = cross(a(:,1),a(:,2));
            
            % get inverse jacobian: edot = Jinv * w_body
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R1 = (eye(3) - sin(e(1,k))*skew1(:,:,1) + (1 - cos(e(1,k)))*skew2(:,:,1));
                R2 = (eye(3) - sin(e(2,k))*skew1(:,:,2) + (1 - cos(e(2,k)))*skew2(:,:,2));
                Sworld = -1 / (a(:,3)' * R2 * x12) * [ cross(R2'*a(:,3),a(:,2))'; cross(a(:,1),R2'*a(:,3))'; -x12'];
                J(:,:,k) = -Sworld * R1;
            end
            
        end
        
    % if angular rate expressed in world frame
    else
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_world = J * edot
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R3 = (eye(3) - sin(e(3,k))*skew1(:,:,3) + (1 - cos(e(3,k)))*skew2(:,:,3));
                R2 = (eye(3) - sin(e(2,k))*skew1(:,:,2) + (1 - cos(e(2,k)))*skew2(:,:,2));
                J(:,:,k) = -R3 * [R2 * a(:,1) a(:,2) a(:,3)];
            end
            
        % if return jacobian inverse
        else
            
            % get some cross products that are needed
            x12 = cross(a(:,1),a(:,2));
            x23 = cross(a(:,2),a(:,3));
            
            % get inverse jacobian: edot = Jinv * w_world
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R3 = (eye(3) - sin(e(3,k))*skew1(:,:,3) + (1 - cos(e(3,k)))*skew2(:,:,3));
                if symm
                    Sbody = 1/sin(e(2,k)) * [ x12'; sin(e(2,k)) * a(:,2)' ; sin(e(2,k)) * a(:,1)' - cos(e(2,k)) * x12'];
                else
                    Sbody = 1/cos(e(2,k)) * [ a(:,1)'; cos(e(2,k)) * a(:,2)' ; cos(e(2,k)) * a(:,3)' - sin(e(2,k)) * x23'];
                end
                J(:,:,k) = -Sbody * R3';
            end
            
        end
        
    end
    
% if w2b: v_body = R3 * R2 * R1 * v_world 
else
    
    % if ang rate in body frame
    if inbody
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_body = J * edot
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R3 = (eye(3) - sin(e(3,k))*skew1(:,:,3) + (1 - cos(e(3,k)))*skew2(:,:,3));
                R2 = (eye(3) - sin(e(2,k))*skew1(:,:,2) + (1 - cos(e(2,k)))*skew2(:,:,2));
                J(:,:,k) = R3 * [R2 * a(:,1) a(:,2) a(:,3)];
            end
            
        % if return jacobian inverse
        else
            
            % get some cross products that are needed
            x12 = cross(a(:,1),a(:,2));
            x23 = cross(a(:,2),a(:,3));
            
            % get inverse jacobian: edot = Jinv * w_body
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R3 = (eye(3) - sin(e(3,k))*skew1(:,:,3) + (1 - cos(e(3,k)))*skew2(:,:,3));
                if symm
                    Sbody = 1/sin(e(2,k)) * [ x12'; sin(e(2,k)) * a(:,2)' ; sin(e(2,k)) * a(:,1)' - cos(e(2,k)) * x12'];
                else
                    Sbody = 1/cos(e(2,k)) * [ a(:,1)'; cos(e(2,k)) * a(:,2)' ; cos(e(2,k)) * a(:,3)' - sin(e(2,k)) * x23'];
                end
                J(:,:,k) = Sbody * R3';
            end
            
        end
        
    % if angular rate expressed in world frame
    else
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_world = J * edot
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R1 = (eye(3) - sin(e(1,k))*skew1(:,:,1) + (1 - cos(e(1,k)))*skew2(:,:,1));
                R2 = (eye(3) - sin(e(2,k))*skew1(:,:,2) + (1 - cos(e(2,k)))*skew2(:,:,2));
                J(:,:,k) = R1' * [a(:,1) a(:,2) R2'*a(:,3)];
            end
            
        % if return jacobian inverse
        else
            
            % get some cross products that are needed
            x12 = cross(a(:,1),a(:,2));
            
            % get inverse jacobian: edot = Jinv * w_world
            J = zeros(3,3,ncol);
            for k = 1:ncol
                R1 = (eye(3) - sin(e(1,k))*skew1(:,:,1) + (1 - cos(e(1,k)))*skew2(:,:,1));
                R2 = (eye(3) - sin(e(2,k))*skew1(:,:,2) + (1 - cos(e(2,k)))*skew2(:,:,2));
                Sworld = -1 / (a(:,3)' * R2 * x12) * [ cross(R2'*a(:,3),a(:,2))'; cross(a(:,1),R2'*a(:,3))'; -x12'];
                J(:,:,k) = Sworld * R1;
            end
            
        end
        
    end
    
end  

end