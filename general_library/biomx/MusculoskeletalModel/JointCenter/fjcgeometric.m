function [c1,r] = fjcgeometric(r1,p1,m2,c0)
%   
%   functional joint center estimator: geometric method, piazza et al. 2001
%   Ehrig et al. 2006, Shakarji 1998
%
%   estimates joint center for spheroidal joint characterized by segment 1
%   and segment 2 given data during a calibration trial where the segments
%   move relative to one another in all 3 axes where the orientations
%   througout the movement are defined by the dcms r1 and r2 for segment 1
%   and 2 respectively and given body origins p1 and p2 which are relative
%   to a global frame
%
%   requires starting guess: c0 for center
%
%   method uses fact that all points in body 2 should be a constant radial
%   distance from joint center. This approach minimizes this cost, involves
%   sqrt, no closed form, uses levenberg-marquardt and analytical jacobian 
%   to find solution
%
%----------------------------------INPUTS----------------------------------
%
%   r1:
%       3x3xn array of direction cosine matrices such that:
%               v_world(:,i) = r1(:,:,i) * v_frame1(:,i)
%   p1:
%       3xn array of column vectors specifying the location of the origin
%       in the world frame
%
%   m2:
%       3x3xn array of column vectors of marker positions. Each page is for
%       a different marker. Marker positions should be for markers placed
%       on rigid body 2 but expressed in the world frame
%
%   c0:
%       3x1 vector, first estimate of position of joint center relative to
%       frame 1
%
%---------------------------------OUTPUTS----------------------------------
%
%   c1:
%       3x1 position vector indicating the location of the joint center
%       relative to frame 1
%
%   r:
%       radial distances from joint center to markers in m2
%
%--------------------------------------------------------------------------
%% frageometric

% globalization for obj fxn
global u
global imkr

% get markers in body 2 relative to body 1 in body 1
nframes = size(p1,2);
nmkr = size(m2,3);
x0 = zeros(1,nmkr);
u = zeros(3,nmkr*nframes);
imkr = zeros(1,nmkr*nframes);
i = 1;
while i <= size(u,2)
    for m = 1:nmkr
        mag = zeros(1,nframes);
        for f = 1:nframes
            if any(isnan(m2(:,f,m))) || any(isnan(p1(:,f)))
                u(:,i) = [];
                mag(f) = [];
                imkr(i) = [];
            else
                u(:,i) = r1(:,:,f)' * ( m2(:,f,m) - p1(:,f) );
                mag(f) = sqrt(sum((u(:,i) - c0).^2));
                imkr(i) = m;
                i = i + 1;
            end
        end
        x0(m) = mean(mag);
    end
end

% levenberg-marquardt
x0 = [x0 c0'];
options = optimoptions('lsqnonlin','SpecifyObjectiveGradient',true,'Algorithm','levenberg-marquardt','Display','off');
x = lsqnonlin(@objfun,x0,[],[],options);

% parse soln
c1 = x(end-2:end)';
r = x(1:end-3);

end

function [err,jac] = objfun(x)

% see shakarji 1998 section 3.3 

global u
global imkr

err = zeros(length(imkr),1);
jac = zeros(length(imkr),length(x));
c = x(end-2:end)';
r = x(1:end-3);
for i = 1:length(imkr)
    
    % coordinate-wise distances
    d1 = u(1,i) - c(1);
    d2 = u(2,i) - c(2);
    d3 = u(3,i) - c(3);
    
    % length: center to marker (should be constant)
    mag = sqrt( d1^2 + d2^2 + d3^2 );
    err(i) = mag - r(imkr(i));
    
    % derivs
    jac(i,imkr(i)) = -1;
    jac(i,end-2) = -d1 / mag;
    jac(i,end-1) = -d2 / mag;
    jac(i,end) = -d3 / mag;
end

end