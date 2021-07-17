function [c2] = fjclmpga(r1,r2,p1,m2,c2init,c2lb,c2ub,maxgen)
%
%   functional joint center estimator: least moving point, Marin et al.
%   2003, genetic algorithm
%
%   also called minimum amplitude point. Joint center in frame 1 should be
%   constant, wont be perfect, so best estimate associated with that for
%   which the range of values in each axis (x,y,z) independently is least.
%   
%   this being non-differentiable requires global optimization. Marin
%   originally used genetic algorithm, Ehrig 07 used simulated annealing,
%   also could used Bayes opt
%
%   requires initial guess
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
%       of frame 1 in the world frame
%
%   m2:
%       3x3xn array of column vectors of marker positions. Each page is for
%       a different marker. Marker positions should be for markers placed
%       on rigid body 2 but expressed in the world frame
%
%   c2init:
%       initial estimate of c2 (joint center in frame 2)
%
%   c2lb,c2ub:
%       lower and upper bounds for c2 
%
%   maxiter:
%       MaxGenerations argument in ga() function
%
%---------------------------------OUTPUTS----------------------------------
%
%   c2:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 2
%
%--------------------------------------------------------------------------
%% fjclmpga


% globalize vars for use in obj fxn
global u
global r

% get markers on body 2 relative to body 1
nframes = size(p1,2);
nmkr = size(m2,3);
u = zeros(3,nmkr*nframes); % markers of body 2 relative to body 1
r = zeros(3,3,nmkr*nframes); % dcm: body 2 to body 1

% for each observation
i = 1;
while i <= size(u,2)
    
    % for each marker
    for m = 1:nmkr
        
        % for each frame
        for f = 1:nframes
            
            % remove NaNs (occlusion)
            if any(isnan(m2(:,f,m))) || any(isnan(p1(:,f)))
                u(:,i) = [];
                r(:,:,i) = [];
            else
                
                % get u and r
                u(:,i) = r1(:,:,f)' * ( m2(:,f,m) - p1(:,f) );
                r(:,:,i) = r1(:,:,f)' * r2(:,:,f);
                i = i + 1;
            end
        end
    end
end

% genetic algorithm
options = optimoptions('ga','Display','iter','InitialPopulationMatrix',c2init','MaxGenerations',maxgen,'PopulationSize',size(c2init,2));
c2 = ga(@objfun,3,[],[],[],[],c2lb',c2ub',[],options);
c2 = c2';

end

function [cost] = objfun(x)

global u
global r

% initalize c1
c1 = zeros(3,size(u,2));

% for each observation
for i = 1:size(u,2)
    
    % estimate c1 given current c2 estimate (x)
    c1(:,i) = r(:,:,i) * x' + u(:,i);
    
end

% sum of coordinate-wise ranges
cost = (max(c1(1,:)) - min(c1(1,:))) + (max(c1(2,:)) - min(c1(2,:))) + (max(c1(3,:)) - min(c1(3,:)));

end