function c1 = fjchelical(r1,r2,p1,p2,weight,allPossible)
%   
%   functional joint center estimator: finite helical displacement, 
%   Spoor and Veldpaus 1980, Woltring et al. 1985, Ehrig et al. 2006
%
%   estimates joint center for spheroidal joint characterized by segment 1
%   and segment 2 given data during a calibration trial where the segments
%   move relative to one another in all 3 axes where the orientations
%   througout the movement are defined by the dcms r1 and r2 for segment 1
%   and 2 respectively and given body origins p1 and p2 which are relative
%   to a global frame as well as angular rates w1 and w2 in respective body
%   frames and velocities v1 and v2 in global frame
%
%   method based on fact that a rigid body displacement parametrized by
%   screw displacement requires a rotation axis and a pivot point. For
%   spheroidal joint, the pivot point should be constant in the parent
%   body. This method then computes the joint center as the weighted
%   average of all computed pivot points for all rigid body displacements
%   throughout the calibration trial
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%
%   r2:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r2(:,:,i) * v_frame2(:,i)
%
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       of frame 1 in the world frame
%
%   p2:
%       3xn array of column vectors specifying the location of the origin
%       of frame 2 in the world frame
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
%   c1:
%       3x1 unit vector specifying the joint center in frame 1
%
%--------------------------------------------------------------------------
%% fjchelical

% initialization
n = size(p1,2);
if allPossible
    m = n-1; % ehrig 06, results in n * (n - 1)/2 observations (see also holtzreiter approach in ehrig 06)
else
    m = 1; % stokdijk 99, results in n-1 observations
end
Q = zeros(3);
s = [0 0 0]';
I = eye(3);

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
        [axis,angle,point] = helical(R,v,1e-4);
        
        % these relative to config i, transform to frame 1
        axis = Ri * axis;
        point = pi + Ri * point;
        
        % get weight
        if weight == 1; w = sin(angle/2);
        elseif weight == 2; w = sin(angle/2) * sin(angle/2);
        else; w = 1;
        end
        
        % increment weighted sum
        Q = Q + w * (I - axis * axis');
        s = s + w * point;
        
    end
end

% solve linear system
c1 = Q\s;
            
end