function [ dcm, dc ] = intdcmode45( dcm0, w, t, b2w, inbody, forward, options)
%Reed Gurchiek, 2020
%   intdcmode45 time integrates the direction cosine matrix to provide the
%   orientation at each time (t) given the angular rate (w) and the
%   initial orientation (dcm0) using ode45 (runge kutta)
%
%--------------------------INPUTS------------------------------------------
%
%   dcm0:
%       3x3, initial direction cosine matrix from which integration begins
%
%   w:
%       gyroscope measured body angular rate IN RADIANS PER SECOND. should
%       be a 3xn array where n is the number of samples
%
%   t:
%       time IN SECONDS.  should be a 1D vector of length n.
%
%   b2w:
%       boolean.  Does dcm rotate body frame referenced vectors to world
%       frame? if yes then b2w = 1. If not, b2w = 0 (i.e.
%       world to body).
%
%   inbody:
%       boolean. Is w expressed in the body frame? If yes, then inbody = 1,
%       if not, then inbody = 0.
%
%   midpoint:
%       boolean. Use midpoint approximation? If no then  midpoint = 0 and
%           w = w_k within t_k < t < t_k+1 (zero order hold) 
%       otherwise if midpoint = 1 then the assumed constant angular rate
%       during the time interval is the average of w_k and w_k+1
%
%   forward:
%       boolean. if integrate from beginning to end then forward = 1 and r0
%       corresponds to r at t = t(1). If integrate from end to beginning
%       then forward = 0 and r0 corresponds to r at t = t(end)
%
%-------------------------------OUTPUTS------------------------------------
%
%   dcm:
%       3x3xn time integrated dcm array
%
%   dc:
%       9xn time integrated direction cosines array
%
%--------------------------------------------------------------------------
%% intdcmode45

% flip and negate time/angular rate if integrating backwards
if ~forward
    t = flip(-t);
    w = flip(-w,2);
end

% integrate
[~,dc] = ode45(@(tk,dc) dcdot(tk,dc,w,t,b2w,inbody),t,dcm2dc(dcm0),options);
dc = dcm2dc(orthogonalize(dc2dcm(dc')));

% flip back?
if ~forward
    dc = flip(dc,2);

end

dcm = dc2dcm(dc);

end

function ddcdt = dcdot(tk,dc,w,t,b2w,inbody)
    
% orthogonalize
dc = dcm2dc(orthogonalize(dc2dcm(dc)));

omega = interp1(t,w',tk,'pchip')';
ddcdt = dcjac(dc,b2w,inbody,1) * omega;

end