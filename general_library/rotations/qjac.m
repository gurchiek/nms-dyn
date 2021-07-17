function [ J ] = qjac(q,b2w,inbody,inv)
%Reed Gurchiek, 2020
%   get 3 x 4 jacobian that maps quaternion derivative to body frame 
%   angular rate vector
%
%----------------------------------INPUTS----------------------------------
%
%   q:
%       4 x n array of column vector quaternions, row 4 is scalar part,
%       rows 1-3 are vector part
%
%   b2w:
%       if 1, then, v_world = q * v_body * qconj
%       if 0, then, v_body = q * v_world * qconj
%
%   inbody:
%       if 1, then, w is expressed in body frame: w_body = J * qdot
%       if 0, then, w is expressed in world frame: w_world = J * qdot
%
%   inv:
%       if 1, then returns inverse of J (maps ang rate back to qdot) s.t.
%                           qdot = J * w
%       if 0, then returns J (maps qdot to ang rate) s.t.
%                           w = J * qdot
%
%---------------------------------OUTPUTS----------------------------------
%
%   J:
%       3 x 4 x n jacobian matrix or 4 x 3 x n if inv = 1
%
%--------------------------------------------------------------------------
%% qjac

% error check
[nrow,ncol] = size(q);
if nrow ~= 4; error('input q must be 4 x n array of column vector quaternions (row 4 = scalar part, rows 1-3 = vector part).'); end

% if body to world: v_world = q * v_body * qconj
if b2w
    
    % if ang rate in body frame
    if inbody
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_body = 2 * qconj * qdot
            J = zeros(3,4,ncol);
            for k = 1:ncol
                purejac = 2 * qprodmat(qconj(q(:,k)),1);
                J(:,:,k) = purejac(1:3,:);
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian: qdot = 1/2 * q * w_body
            J = zeros(4,3,ncol);
            for k = 1:ncol
                purejac = 1/2 * qprodmat(q(:,k),1);
                J(:,:,k) = purejac(:,1:3);
            end
            
        end
        
    % if angular rate expressed in world frame
    else
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_world = 2 * qdot * qconj
            J = zeros(3,4,ncol);
            for k = 1:ncol
                purejac = 2 * qprodmat(qconj(q(:,k)),2);
                J(:,:,k) = purejac(1:3,:);
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian: qdot = 1/2 * w_world * q
            J = zeros(4,3,ncol);
            for k = 1:ncol
                purejac = 1/2 * qprodmat(q(:,k),2);
                J(:,:,k) = purejac(:,1:3);
            end
            
        end
        
    end
    
% if w2b: v_body = q * v_world * qconj  
else
    
    % if ang rate in body frame
    if inbody
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_body = -2 * qdot * qconj
            J = zeros(3,4,ncol);
            for k = 1:ncol
                purejac = -2 * qprodmat(qconj(q(:,k)),2);
                J(:,:,k) = purejac(1:3,:);
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian: qdot = -1/2 * w_body * q
            J = zeros(4,3,ncol);
            for k = 1:ncol
                purejac = -1/2 * qprodmat(q(:,k),2);
                J(:,:,k) = purejac(:,1:3);
            end
            
        end
        
    % if angular rate expressed in world frame
    else
        
        % if return jacobian
        if ~inv
            
            % get jacobian: w_world = -2 * qconj * qdot
            J = zeros(3,4,ncol);
            for k = 1:ncol
                purejac = -2 * qprodmat(qconj(q(:,k)),1);
                J(:,:,k) = purejac(1:3,:);
            end
            
        % if return jacobian inverse
        else
            
            % get inverse jacobian: qdot = -1/2 * q * w_world
            J = zeros(4,3,ncol);
            for k = 1:ncol
                purejac = -1/2 * qprodmat(q(:,k),1);
                J(:,:,k) = purejac(:,1:3);
            end
            
        end
        
    end
    
end  

end