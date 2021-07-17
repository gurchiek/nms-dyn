function c1 = fjciha(r1,r2,p1,p2,w1,w2,v1,v2,sd)
%   
%   functional joint center estimator: mean instantaneous helical axis, 
%   Stokdijk et al. 1999, Besier et al. 2003, Ehrig et al. 2006
%
%   estimates joint center for spheroidal joint characterized by segment 1
%   and segment 2 given data during a calibration trial where the segments
%   move relative to one another in all 3 axes where the orientations
%   througout the movement are defined by the dcms r1 and r2 for segment 1
%   and 2 respectively and given body origins p1 and p2 which are relative
%   to a global frame as well as angular rates w1 and w2 in respective body
%   frames and velocities v1 and v2 in global frame
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
%   w1:
%       3xn array of angular velocity vector of frame 1 measured in frame 1
%
%   w2:
%       3xn array of angular velocity vector of frame 2 measured in frame 2
%
%   a0:
%       3x1 vector, first estimate of joint axis in frame 1, only needs to
%       point in correct half of joint plane
%
%   sd:
%       data for angular velocities that are too low are removed from the
%       averaging to reduce effects of errors at low rotation rate. All
%       samples corresponding to angular velocity magnitudes less than sd
%       standard deviations from the mean angular velocity magnitude are
%       removed
%
%---------------------------------OUTPUTS----------------------------------
%
%   c1:
%       3x1 unit vector specifying the joint center in frame 1
%
%--------------------------------------------------------------------------
%% fjciha

% initialization
if nargin == 8; sd = 3; end
n = size(p1,2);
Q = zeros(3,3,n);
s = zeros(3,n);
wmag = zeros(1,n);
I = eye(3);

% for each frame
for i = 1:n
    
    % get body 2 rate relative to body 1
    wrel = r1(:,:,i)' * r2(:,:,i) * w2(:,i) - w1(:,i);
    wrel2 = wrel' * wrel;
    wrelmag = sqrt(wrel2);
    wmag(i) = wrelmag;
    
    % get body 2 velocity relative to body 1 in body 1
    vrel = r1(:,:,i)' * (v2(:,i) - v1(:,i));
    
    % get body 2 position relative to body 1 in body 1
    prel = r1(:,:,i)' * (p2(:,i) - p1(:,i));
    
    % get instantaneous helical axis
    axis = wrel / wrelmag;
    
    % get translation point
    s(:,i) = prel + cross(wrel,vrel/wrel2);
    
    % get Q
    Q(:,:,i) = I - axis * axis';
end

% average over Q and s for rates that are large enough (stokdijk 99)
ilarge = wmag >= mean(wmag) - sd * std(wmag);

% solve linear system (eq 13 in Ehrig et al 06, eq 5 in Stokdijk et al 99)
c1 = mean(Q(:,:,ilarge),3) \ mean(s(:,ilarge),2);
            
end