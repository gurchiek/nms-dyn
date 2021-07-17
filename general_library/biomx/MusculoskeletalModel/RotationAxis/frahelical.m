function a1 = frahelical(r1,r2,p1,p2,a0,weight,allPossible)
%   
%   functional rotation axis estimator: mean finite helical axis,
%   Spoor and Veldpaus 1980, Woltring et al. 1985, Ehrig et al. 2007
%
%   estimates rotation axis for joint characterized by two bodies (body 1,
%   body 2) with associated orientations (r1, r2) and origins p1,p2
%   measured in global frame for planar joint
%
%   assuming a hinge joint, the configuration of rigid body 2 relative to
%   rigid body 1, expressed relative to rigid body 1, can be parametrized
%   as a screw displacement where the rotation axis is constant
%
%   this also called mean finite helical axis approach. The instantaneous
%   helical axis is related to the angular velocity whereas here, the
%   finite helical axis can described the rigid body displacement between
%   any two configurations (even with large angles)
%
%   this method does not return a joint center estimate. Besier et al. 2003
%   use mean of femoral epicondyles
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   r2:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r2(:,:,i) * v_frame2(:,i)
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       in the world frame
%
%   p2:
%       3xn array of column vectors specifying a point in body 2 expressed
%       in the world frame
%
%   a0:
%       3x1 vector, first estimate of joint axis in frame 1, only needs to
%       point in correct half of joint plane
%
%   weight (optional: default = 2):
%       weight for weighted average
%           -weight = 0, all weighted equally
%           -weight = 1, weight is sin(angle/2)
%           -weight = 2, weight is sin(angle/2)^2
%
%   allPossible (optional: default = 1):
%       1 if use all possible rigid body displacements (between every
%       possible combination of two system configurations in dataset)
%
%       0 if use all rigid body displacements in dataset relative to first
%       configuration
%
%---------------------------------OUTPUTS----------------------------------
%
%   a1:
%       3x1 unit vector specifying the joint axis in frame 1
%
%--------------------------------------------------------------------------
%% frahelical

% defaults
if nargin == 5
    weight = 2;
    allPossible = 1;
elseif nargin == 6
    allPossible = 1;
end

% initialization
n = size(p1,2);
if allPossible
    m = n-1; % ehrig 06, results in n * (n - 1)/2 observations (see also holtzreiter approach in ehrig 06)
else
    m = 1; % stokdijk 99, results in n-1 observations
end
a1 = [0 0 0]';

% for each 'reference' configuration
for i = 1:m
    
    % get Ri s.t. v1(i) = Ri * v2(i)
    Ri = r1(:,:,i)' * r2(:,:,i);
    
    % get p2 in frame 1
    pi = r1(:,:,i)' * (p2(:,i) - p1(:,i));
    
    % for each subsequent configuration
    for j = i+1:n
        
        % get Rj s.t. v1(j) = Rj * v2(j)
        Rj = r1(:,:,j)' * r2(:,:,j);
        
        % get p2 in frame 1
        pj = r1(:,:,j)' * (p2(:,j) - p1(:,j));
        
        % get rigid body displacement relative to config i (Ri, pi)
        R = Ri' * Rj;
        v = Ri' * (pj - pi);
        
        % get helical params
        [axis,angle] = helical(R,v,1e-4);
        
        % these relative to config i, transform to frame 1
        axis = Ri * axis;
        
        % get weight
        if weight == 1; w = sin(angle/2);
        elseif weight == 2; w = sin(angle/2) * sin(angle/2);
        else; w = 1;
        end
        
        % correct side
        axis = sign(axis' * a0) * axis;
        
        % increment weighted sum
        a1 = a1 + w * axis;
        
    end
end

% normalize
a1 = a1 / vecnorm(a1);
            
end