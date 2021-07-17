function [ J ] = dcjac(dc,b2w,inbody,inv)
%Reed Gurchiek, 2020
%   get jacobian s.t. w = J * dcdot 
%
%----------------------------------INPUTS----------------------------------
%
%   dc:
%       9 x n vector of direction cosines arranged as per:
%
%           dc = [x; y; z] where x,y,z are 3 x n unit vectors specifying
%           the basis vectors for frame A expressed in frame B where:
% 
%                           v_A = [x y z] * v_B
%           
%
%   b2w:
%       if 1, then, v_world = [x y z] * v_body, where x,y,z are the body 
%           frame basis vectors expressed in the world frame and:
%               x = dc(1:3), y = dc(4:6), z = dc(7:9)
%       if 0, then, v_body = [x y z] * v_world, where x,y,z are the world
%           frame basis vectors expressed in the bbody frame and:
%               x = dc(1:3), y = dc(4:6), z = dc(7:9)
%
%   inbody:
%       if 1, then, w is expressed in body frame: w_body = J * dcdot, where
%           w is the angular rate of the body frame
%       if 0, then, w is expressed in world frame: w_world = J * dcdot,
%           where w is the angular rate of the body frame
%
%   inv:
%       if 1, then returns inverse of J (maps ang rate back to dcdot) s.t.
%                           dcdot = J * w
%       if 0, then returns J (maps dcdot to ang rate) s.t.
%                           w = J * dcdot
%
%---------------------------------OUTPUTS----------------------------------
%
%   J:
%       3 x 9 x n jacobian matrix or 9 x 3 x n if inv = 1
%
%--------------------------------------------------------------------------
%% dcjac

% error check
[nrow,ncol] = size(dc);
if nrow ~= 9; error('input dc must be 9 x n array of column vector direction cosines (rows 1-3 = 1st col of dcm, rows 4:6 = 2nd col of dcm, rows 7-9 = 3rd col of dcm).'); end

% parse
x = dc(1:3,:);
y = dc(4:6,:);
z = dc(7:9,:);
v0 = zeros(3,1);

% if body to world: v_world = [x y z] * v_body
if b2w
    
    % if ang rate in body frame
    if inbody
        
        % if return jacobian
        if ~inv
            
            % get jacobian
            J = zeros(3,9,ncol);
            for k = 1:ncol
                J(:,:,k) = -1/2 * [   v0'    -z(:,k)'   y(:,k)';...
                                    z(:,k)'    v0'      -x(:,k)';...
                                   -y(:,k)'   x(:,k)'     v0'];
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian
            J = zeros(9,3,ncol);
            for k = 1:ncol
                J(:,:,k) = [  v0     -z(:,k)    y(:,k);...
                             z(:,k)    v0      -x(:,k);...
                            -y(:,k)   x(:,k)     v0];
            end
            
        end
        
    % if angular rate expressed in world frame
    else
        
        % if return jacobian
        if ~inv
            
            % get jacobian
            J = zeros(3,9,ncol);
            for k = 1:ncol
                J(:,:,k) = 1/2 * [ skew(x(:,k)) skew(y(:,k)) skew(z(:,k)) ];
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian
            J = zeros(9,3,ncol);
            for k = 1:ncol
                J(:,:,k) = [ skew(x(:,k)) skew(y(:,k)) skew(z(:,k)) ]';
            end
            
        end
        
    end
    
% if w2b: v_body = [x y z] * v_world 
else
    
    % if ang rate in body frame
    if inbody
        
        % if return jacobian
        if ~inv
            
            % get jacobian
            J = zeros(3,9,ncol);
            for k = 1:ncol
                J(:,:,k) = -1/2 * [ skew(x(:,k)) skew(y(:,k)) skew(z(:,k)) ];
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian
            J = zeros(9,3,ncol);
            for k = 1:ncol
                J(:,:,k) = -[ skew(x(:,k)) skew(y(:,k)) skew(z(:,k)) ]';
            end
            
        end
        
    % if angular rate expressed in world frame
    else
        
        % if return jacobian
        if ~inv
            
            % get jacobian
            J = zeros(3,9,ncol);
            for k = 1:ncol
                J(:,:,k) = 1/2 * [   v0'    -z(:,k)'   y(:,k)';...
                                   z(:,k)'    v0'      -x(:,k)';...
                                  -y(:,k)'   x(:,k)'     v0'];
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian
            J = zeros(9,3,ncol);
            for k = 1:ncol
                J(:,:,k) = [    v0      z(:,k)   -y(:,k);...
                             -z(:,k)      v0      x(:,k);...
                              y(:,k)   -x(:,k)     v0];
            end
            
        end
        
    end
    
end  

end