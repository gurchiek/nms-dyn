function [ r2 ] = convrot( r1, r2_type )
%Reed Gurchiek, 2020
%   convrot converts the rotation operator r1 to a different rotation 
%   operator r2 of the type specified by r2_type. The type of r1 is
%   specified by its fieldname. If quaternion then it must be named r1.q,
%   if dcm then it must be named r1.dcm, and if euler angle sequence then
%   it must be named r1.xyz or r1.zxy or whatever the sequence is.
%
%-----------------------------INPUTS---------------------------------------
%
%   r1:
%       structure, rotation operator to be converted, can be either:
%           (1) quaternion: r1.q = 4xn, rows 1-3 are vector part x,y,z and 
%               row 4 is scalar part
%           (2) direction cosine matrix: r1.dcm = 3x3xn
%           (3) euler angles: r1.(seq) = 3xn where seq is a char array
%               specifying the rotation sequence:
%                   'xyx' 'xzx' 'xzy' 'xyz'
%                   'yzy' 'yxy' 'yzx' 'yxz'
%                   'zxz' 'zyz' 'zxy' 'zyx'      
%
%   r2_type:
%       char array describing the desired type of rotation operator to 
%       convert to.  The output rotation operator (r2) will be of this type
%           (1) 'q' for quaternion
%           (2) 'dcm' for direction cosine matrix
%           (3) 'xyx' 'xzx' 'yxy' 'yzy' 'zxz' 'zyz' (symmetric) or
%               'xyz' 'xzy' 'yxz' 'yzx' 'zxy' 'zyx' (asymmetric) euler
%               angles
%
%----------------------------OUTPUTS---------------------------------------
%
%   r2:
%       structure, rotation operator equivalent to r1 but of type r2_type
%
%--------------------------------------------------------------------------

%%  convrot

% error check
r1_type = typerot(r1);
acceptableTypes = {'q' 'dcm' 'xyx' 'xzx' 'yzy' 'yxy' 'zxz' 'zyz' 'xyz' 'xzy' 'yxz' 'yzx' 'zxy' 'zyx'};
r1 = r1.(r1_type);
[nrow,ncol,npag] = size(r1);
if ~any(strcmpi(r2_type,acceptableTypes)); error('rotation operator r2 type (fieldname) is unrecognized. See convrot description.'); end

% CONVERT FROM QUATERNION
if strcmpi(r1_type,'q')
    
    % init
    if nrow ~= 4; error('quaternion must be 4 x n. See convrot description.'); end
    n = ncol;
    
    % CONVERT TO DCM
    if strcmpi(r2_type,'dcm')
        
        % for each rotator
        rnew = zeros(3,3,n);
        for k = 1:n
            
            % ME 304, eq 75
            rnew(1:3,1:3,k) = [r1(1,k)^2 - r1(2,k)^2 - r1(3,k)^2 + r1(4,k)^2     2*(r1(1,k)*r1(2,k) - r1(4,k)*r1(3,k))            2*(r1(1,k)*r1(3,k) + r1(4,k)*r1(2,k)) ;...
                                  2*(r1(1,k)*r1(2,k) + r1(4,k)*r1(3,k))      -r1(1,k)^2 + r1(2,k)^2 - r1(3,k)^2 + r1(4,k)^2       2*(r1(2,k)*r1(3,k) - r1(4,k)*r1(1,k)) ;...
                                  2*(r1(1,k)*r1(3,k) - r1(4,k)*r1(2,k))          2*(r1(2,k)*r1(3,k) + r1(4,k)*r1(1,k))        -r1(1,k)^2 - r1(2,k)^2 + r1(3,k)^2 + r1(4,k)^2];
        end
        
    % CONVERT TO EULER ANGLES
    elseif strcmpi(r2_type(1),'x')||strcmpi(r2_type(1),'y')||strcmpi(r2_type(1),'z')
        
        % conjugate to agree with shuster notation
        r1 = qconj(r1);
        
        % get rotation axes 
        ax = zeros(3,3);
        for k = 1:3

            % column k is axis of rotation for the kth rotation
            ax(regexp('xyz',r2_type(k)),k) = 1;

        end
        
        % sign of some terms from levi civita symb (Shuster 1993, eq 135)
        vi = [ax(:,1) ax(:,1) ax(:,1)];
        vj = [ax(:,2) ax(:,2) ax(:,2)];
        vk = eye(3);
        a = sum(levicivita(vi,vj,vk));
        
        % space allocation
        rnew = zeros(3,n);
        
        %if symmetric (Shuster 1993 eq 191)
        if strcmpi(r2_type(1),r2_type(3))
            
            % get missing axis
            ax(:,3) = cross(ax(:,1),ax(:,2)); % might be negative here, but will be forced positive in next loop
            
            % get indices of quaternion corresponding to rotation axes (see sentence after eq 192 Shuster 1993)
            i = zeros(3,1);
            d = diag([1 2 3]);
            for k = 1:3
                i(k) = ax(:,k)'*d*ax(:,k); %compared to eq 191 and 192 in Shuster 1993, i(1) = i, i(2) = j, i(3) = k
            end
            
            % for each rotator
            for k = 1:n
                
                % angle 2 (eq 193)
                rnew(2,k) = acos(r1(4,k)^2 + r1(i(1),k)^2 - r1(i(2),k)^2 - r1(i(3),k)^2);
                
                % angle 1 & 3
                if sin(rnew(2,k)) ~= 0
                    
                    % eq 194
                    rnew(1,k) = atan2(r1(i(1),k),r1(4,k)) + atan2(a*r1(i(3),k),r1(i(2),k));
                    rnew(3,k) = atan2(r1(i(1),k),r1(4,k)) - atan2(a*r1(i(3),k),r1(i(2),k));
                 
                else
                    
                    % angle 3, eq 195
                    rnew(3,k) = 0;
                    
                    % angle 1, eq 195
                    if rnew(2,k) == 0
                        rnew(1,k) = atan2(r1(i(1),k),r1(4,k));
                    else
                        rnew(1,k) = atan2(a*r1(i(3),k),r1(i(2),k));
                    end
                end
            end
        
        % if asymmetric (Shuster 1993 eq 192)   
        else
            
            % get indices of quaternion corresponding to rotation axes (see sentence after eq 192 Shuster 1993)
            i = zeros(3,1);
            d = diag([1 2 3]);
            for k = 1:3
                i(k) = ax(:,k)'*d*ax(:,k); % compared to eq 191 and 192 in Shuster 1993, i(1) = i, i(2) = j, i(3) = k
            end
            
            % for each rotator
            for k = 1:n
                
                % angle 2, eq 196
                rnew(2,k) = asin(2*(r1(4,k)*r1(i(2),k) + a*r1(i(3),k)*r1(i(1),k)));
                
                % angle 1 & 3
                if cos(rnew(2,k)) ~= 0
                    
                    % angle 1, eq 197a
                    rnew(1,k) = atan2(r1(i(1),k) + r1(i(3),k),r1(4,k) + a*r1(i(2),k)) + ...
                                atan2(r1(i(1),k) - r1(i(3),k),r1(4,k) - a*r1(i(2),k));
                            
                    % angle 3, eq 197b
                    rnew(3,k) = atan2(r1(i(1),k) + r1(i(3),k),r1(4,k) + a*r1(i(2),k)) - ...
                                atan2(r1(i(1),k) - r1(i(3),k),r1(4,k) - a*r1(i(2),k));
                            
                % eq 198
                else
                    
                    % angle 3
                    rnew(3,k) = 0;
                    
                    % angle 1
                    if rnew(2,k) > 0
                        rnew(1,k) = atan2(r1(i(1),k) + a*r1(i(3),k),r1(4,k) + a*r1(i(2),k));
                    else
                        rnew(1,k) = atan2(r1(i(1),k) - a*r1(i(3),k),r1(4,k) - a*r1(i(2),k));
                    end
                    
                end
                
            end
            
        end
        
    % otherwise identity
    else
        rnew = r1;
    end
    
% CONVERT FROM EULER ANGLES
elseif strcmpi(r1_type(1),'x')||strcmpi(r1_type(1),'y')||strcmpi(r1_type(1),'z')
    
    % init
    if nrow ~= 3; error('euler angles must be 3 x n. See convrot description.'); end
    n = ncol;
    
    % get rotation axes 
    ax = zeros(3,3);
    for k = 1:3
        
        % column k is axis of rotation for the kth rotation
        ax(regexp('xyz',r1_type(k)),k) = 1;
        
    end
    
    % CONVERT TO DCM
    if strcmpi(r2_type,'dcm')
        
        % get submatrices used in euler formula: R(n,a) = I - s(a)*[nx] + (1-c(a))*[nx]^2
        skew1 = zeros(3,3,3);
        skew2 = zeros(3,3,3);
        for k = 1:3

            % get skew symmetric matrix [nx]
            skew1(:,:,k) = [   0    -ax(3,k)  ax(2,k);...
                             ax(3,k)    0    -ax(1,k);...
                            -ax(2,k)  ax(1,k)    0   ];

            % get skew symmetric matrix squared [nx]^2
            skew2(:,:,k) = skew1(:,:,k)*skew1(:,:,k);

        end
        
        % for each rotator
        rnew = zeros(3,3,n);
        for k = 1:n

            % construct composite dcm by composition of individual dcms using euler formula
            rnew(:,:,k) = (eye(3) - sin(r1(3,k))*skew1(:,:,3) + (1 - cos(r1(3,k)))*skew2(:,:,3))*...
                          (eye(3) - sin(r1(2,k))*skew1(:,:,2) + (1 - cos(r1(2,k)))*skew2(:,:,2))*...
                          (eye(3) - sin(r1(1,k))*skew1(:,:,1) + (1 - cos(r1(1,k)))*skew2(:,:,1));

        end
        
    % CONVERT TO QUATERNION
    elseif strcmpi(r2_type,'q')
        
        % space allocation
        rnew = zeros(4,n);
        
        % sign of some terms from levi civita (Shuster 1993, eq 135)
        vi = zeros(3,3);
        vj = zeros(3,3);
        vi(regexpi('xyz',r1_type(1)),:) = 1;
        vj(regexpi('xyz',r1_type(2)),:) = 1;
        vk = eye(3);
        a = sum(levicivita(vi,vj,vk));
        
        % if symmetric, eq 191
        if strcmpi(r1_type(1),r1_type(3))
            
            % get missing axis
            ax(:,3) = cross(ax(:,1),ax(:,2)); % might be negative here, but will be forced positive in next loop
            
            % get indices of quaternion based on rotation axes (see sentence after eq 192 Shuster 1993)
            i = zeros(3,1);
            d = diag([1 2 3]);
            for k = 1:3
                i(k) = ax(:,k)'*d*ax(:,k);
            end
            
            % for each rotator
            for k = 1:n
                
                % build quaternion (Shuster 1993 eq 191)
                % note the /2 is due to line after Shuster 1993 eq 190a
                rnew(i(1),k) =   cos(r1(2,k)/2)*sin(r1(1,k)/2 + r1(3,k)/2);
                rnew(i(2),k) =   sin(r1(2,k)/2)*cos(r1(1,k)/2 - r1(3,k)/2);
                rnew(i(3),k) = a*sin(r1(2,k)/2)*sin(r1(1,k)/2 - r1(3,k)/2);
                rnew(4,k)    =   cos(r1(2,k)/2)*cos(r1(1,k)/2 + r1(3,k)/2);
                
                %normalize and conjugate since to agree with our notation
                rnew(:,k) = qconj(rnew(:,k)./vecnorm(rnew(:,k)));
                
            end
                
                
        % if asymmetric, eq 192   
        else
            
            % get indices of quaternion based on rotation axes (see sentence after eq 192 Shuster 1993)
            i = zeros(3,1);
            d = diag([1 2 3]);
            for k = 1:3
                i(k) = ax(:,k)'*d*ax(:,k);
            end
            
            % for each rotator
            for k = 1:n
                
                % build quaternion (Shuster 1993 eq 192)
                % note the /2 is due to line after Shuster 1993 eq 190a
                rnew(i(1),k) = cos(r1(3,k)/2)*cos(r1(2,k)/2)*sin(r1(1,k)/2) + a*sin(r1(3,k)/2)*sin(r1(2,k)/2)*cos(r1(1,k)/2);
                rnew(i(2),k) = cos(r1(3,k)/2)*sin(r1(2,k)/2)*cos(r1(1,k)/2) - a*sin(r1(3,k)/2)*cos(r1(2,k)/2)*sin(r1(1,k)/2);
                rnew(i(3),k) = sin(r1(3,k)/2)*cos(r1(2,k)/2)*cos(r1(1,k)/2) + a*cos(r1(3,k)/2)*sin(r1(2,k)/2)*sin(r1(1,k)/2);
                rnew(4,k)    = cos(r1(3,k)/2)*cos(r1(2,k)/2)*cos(r1(1,k)/2) - a*sin(r1(3,k)/2)*sin(r1(2,k)/2)*sin(r1(1,k)/2);
                
                %normalize and conjugate to agree with our notations
                rnew(:,k) = qconj(rnew(:,k)./vecnorm(rnew(:,k)));
                
            end
            
        end
        
    % otherwise identity
    else
        rnew = r1;
    end
    
% CONVERT FROM DCM
else
    
    % init
    if nrow ~= 3 && ncol ~= 3; error('direction cosine matrix must be 3 x 3 x n. See convrot description.'); end
    n = npag;
    
    % CONVERT TO EULER ANGLES
    if strcmpi(r2_type(1),'x')||strcmpi(r2_type(1),'y')||strcmpi(r2_type(1),'z')
        
        % sign of some terms for extracting euler angles (Shuster 1993 eq 135)
        vi = zeros(3,3);
        vj = zeros(3,3);
        vi(regexpi('xyz',r2_type(1)),:) = 1;
        vj(regexpi('xyz',r2_type(2)),:) = 1;
        vk = eye(3);
        a = sum(levicivita(vi,vj,vk));
        rnew = zeros(3,n);
        
        % get rotation axes 
        ax = zeros(3,3);
        for k = 1:3

            % column k is axis of rotation for the kth rotation
            ax(regexp('xyz',r2_type(k)),k) = 1;

        end
        
        % if symmetric (Shuster 1993 eq 134)
        if strcmpi(r2_type(1),r2_type(3))
            
            % get missing axis
            ax(:,3) = cross(ax(:,1),ax(:,2)); % might be negative here, but will be forced positive in next loop
            
            % get indices of quaternion corresponding to rotation axes (see sentence after eq 192 Shuster 1993)
            i = zeros(3,1);
            d = diag([1 2 3]);
            for k = 1:3
                i(k) = ax(:,k)'*d*ax(:,k); % compared to eq 191 and 192 in Shuster 1993, i(1) = i, i(2) = j, i(3) = k
            end
            
            % for each rotator
            for k = 1:n
                
                % angle 2 (Shuster 1993 eq 137)
                rnew(2,k) = acos(r1(i(1),i(1),k));
                
                % angles 1 & 3
                if sin(rnew(2,k)) ~= 0
                    
                    % Shuster 1993 eq 138
                    rnew(1,k) = atan2(r1(i(1),i(2),k),-a*r1(i(1),i(3),k));
                    rnew(3,k) = atan2(r1(i(2),i(1),k),a*r1(i(3),i(1),k));
                else
                    
                    % Shuster 1993 eq 139
                    rnew(1,k) = atan2(a*r1(i(2),i(3),k),r1(i(2),i(2),k));
                    rnew(3,k) = 0;
                end
            end
        
        % if asymmetric (Shuster 1993 eq 136) 
        else
            
            % get indices of quaternion corresponding to rotation axes (see sentence after eq 192 Shuster 1993)
            i = zeros(3,1);
            d = diag([1 2 3]);
            for k = 1:3
                i(k) = ax(:,k)'*d*ax(:,k); % compared to eq 191 and 192 in Shuster 1993, i(1) = i, i(2) = j, i(3) = k
            end
            
            for k = 1:n
                
                % angle 2 (Shuster 1993 eq 140)
                rnew(2,k) = asin(a*r1(i(3),i(1),k));
                
                % angles 1 & 3
                if cos(rnew(2,k)) ~= 0
                    
                    % Shuster 1993 eq 141
                    rnew(1,k) = atan2(-a*r1(i(3),i(2),k),r1(i(3),i(3),k));
                    rnew(3,k) = atan2(-a*r1(i(2),i(1),k),r1(i(1),i(1),k));
                else
                    
                    % Shuster 1993 eq 142
                    rnew(1,k) = atan2(a*r1(i(2),i(3),k),r1(i(2),i(2),k));
                    rnew(3,k) = 0;
                end
            end
        end
        
    % CONVERT TO QUATERNION
    elseif strcmpi(r2_type,'q')
        
        % for each rotator
        rnew = zeros(4,n);
        for k = 1:n
            
            % any of the quaternion parameters can be determined from the
            % dcm and the others computed from that.  The greatest numerical
            % accuracy is obtained depending on which has the greatest
            % argument in the square root (see paragraph after eq 168cd in
            % Shuster 1993 and sentence before eq 165).  Here we get the 
            % square root arguments and use the largest to compute the other
            % elements
            rnew(1,k) = 1 + r1(1,1,k) - r1(2,2,k) - r1(3,3,k); % eq 166
            rnew(2,k) = 1 - r1(1,1,k) + r1(2,2,k) - r1(3,3,k); % eq 167
            rnew(3,k) = 1 - r1(1,1,k) - r1(2,2,k) + r1(3,3,k); % eq 168
            rnew(4,k) = 1 + r1(1,1,k) + r1(2,2,k) + r1(3,3,k); % eq 163
            
            % use largest sqrt arg to compute quaternion
            [~,i] = max(rnew(:,k));
            rnew(i,k) = sqrt(rnew(i,k))/2;
            sc = 1/(4*rnew(i,k)); % scalar value used in all computations
            
            % eq 163-164
            if i == 4
                rnew(1,k) = sc*(r1(2,3,k) - r1(3,2,k));
                rnew(2,k) = sc*(r1(3,1,k) - r1(1,3,k));
                rnew(3,k) = sc*(r1(1,2,k) - r1(2,1,k));
                
            % eq 166
            elseif i == 1
                rnew(2,k) = sc*(r1(1,2,k) + r1(2,1,k));
                rnew(3,k) = sc*(r1(1,3,k) + r1(3,1,k));
                rnew(4,k) = sc*(r1(2,3,k) - r1(3,2,k));
                
            % eq 167
            elseif i == 2
                rnew(1,k) = sc*(r1(2,1,k) + r1(1,2,k));
                rnew(3,k) = sc*(r1(2,3,k) + r1(3,2,k));
                rnew(4,k) = sc*(r1(3,1,k) - r1(1,3,k));
                
            % eq 168
            elseif i == 3
                rnew(1,k) = sc*(r1(3,1,k) + r1(1,3,k));
                rnew(2,k) = sc*(r1(3,2,k) + r1(2,3,k));
                rnew(4,k) = sc*(r1(1,2,k) - r1(2,1,k));
            end
            
            %normalize and conjugate to agree with our notation
            rnew(:,k) = qconj(rnew(:,k)./vecnorm(rnew(:,k)));
            
        end
        
    % otherwise identity
    else
        rnew = r1;
    end
    
end

% package
r2.(r2_type) = rnew;

end